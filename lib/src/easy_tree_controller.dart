// The MIT License (MIT)
//
// Copyright (c) 2021 kokohuang
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'package:flutter/material.dart';

import './easy_tree_view.dart';
import './easy_tree_node.dart';
import './easy_tree_util.dart';
import './easy_tree_configuration.dart';
import './easy_tree_key_provider.dart';

class EasyTreeValue {
  const EasyTreeValue({
    this.isInitialized,
    this.initialNodes,
    this.nodes,
    this.selectedNodes,
    this.configuration,
  });

  /// Returns an instance with `false` [isInitialized].
  const EasyTreeValue.uninitialized() : this(isInitialized: false);

  final bool isInitialized;
  final List<EasyTreeNode> initialNodes;
  final List<EasyTreeNode> nodes;
  final List<EasyTreeNode> selectedNodes;
  final EasyTreeConfiguration configuration;

  EasyTreeValue copyWith({
    bool isInitialized,
    List<EasyTreeNode> initialNodes,
    List<EasyTreeNode> nodes,
    List<EasyTreeNode> selectedNodes,
    EasyTreeConfiguration configuration,
  }) {
    return EasyTreeValue(
      isInitialized: isInitialized ?? this.isInitialized,
      initialNodes: initialNodes ?? this.initialNodes,
      nodes: nodes ?? this.nodes,
      selectedNodes: selectedNodes ?? this.selectedNodes,
      configuration: configuration ?? this.configuration,
    );
  }
}

class EasyTreeController<T> extends ValueNotifier<EasyTreeValue> {
  final EasyTreeKeyProvider _keyProvider = EasyTreeKeyProvider();
  GlobalKey<AnimatedListState> _listKey;
  EasyTreeItemRemovedBuilder<EasyTreeNode<T>> _removedItemBuilder;

  EasyTreeController() : super(const EasyTreeValue.uninitialized());

  void initialize({
    @required List<EasyTreeNode> initialNodes,
    @required EasyTreeConfiguration configuration,
    @required GlobalKey<AnimatedListState> key,
    @required EasyTreeItemRemovedBuilder<EasyTreeNode<T>> removedItemBuilder,
  }) async {
    assert(key != null);
    assert(removedItemBuilder != null);
    _listKey = key;
    _removedItemBuilder = removedItemBuilder;
    List<EasyTreeNode> nodes = initializeNodes(
      initialNodes,
      keyProvider: _keyProvider,
      configuration: configuration,
    );
    value = value.copyWith(
      isInitialized: true,
      initialNodes: nodes,
      nodes: treeToList(nodes),
      configuration: configuration,
    );
  }

  void unInitialize() {
    value = value.copyWith(isInitialized: false);
  }

  int get length => value.nodes.length;
  bool get isInitialized => value.isInitialized;
  List<EasyTreeNode> get nodes => value.nodes;
  List<EasyTreeNode> get selectedNodes => value.selectedNodes;

  @override
  void dispose() {
    super.dispose();
  }

  void onClick(EasyTreeNode node) {
    assert(value.isInitialized);
    if (node.isLeaf) {
      this.select(node);
      return;
    }
    node.expanded ? collapse(node) : expand(node);
  }

  /// 展开 node
  void expand(EasyTreeNode node) {
    assert(value.isInitialized);
    if (node != null && !node.expanded && !node.isLeaf) {
      node.expanded = true;
      List<EasyTreeNode> modified = node.getModifiedChildren;
      int index = value.nodes.indexOf(node);
      if (index != -1 && modified.length > 0) {
        index += 1;
        value.nodes.insertAll(index, modified);
        int total = modified.length;
        for (int offset = 0; offset < total; offset++) {
          _listKey.currentState.insertItem(index + offset);
        }
      }
    }
  }

  /// 展开所有 node
  void expandAll() {
    assert(value.isInitialized);
    List<EasyTreeNode> nodes =
        value.nodes.where((element) => element.level == 0).toList();
    if (nodes != null && nodes.length > 0) {
      List<EasyTreeNode> stack = [];
      stack.addAll(nodes);
      while (stack.length > 0) {
        EasyTreeNode node = stack.removeAt(0);
        if (!node.expanded) this.expand(node);
        if (!node.isLeaf) stack.insertAll(0, node.children);
      }
    }
    toggleNodeExpanded(value.initialNodes, true);
  }

  /// 关闭 node
  void collapse(EasyTreeNode node) {
    assert(value.isInitialized);
    if (node != null && node.expanded) {
      node.expanded = false;
      List<EasyTreeNode> modified = node.getModifiedChildren;
      for (EasyTreeNode item in modified) {
        int index =
            value.nodes.indexWhere((element) => element.key == item.key);
        if (index != -1) {
          _listKey.currentState.removeItem(index, (context, animation) {
            return _removedItemBuilder(item, context, animation);
          });
          value.nodes.removeWhere((element) => item.key == element.key);
        }
      }
    }
  }

  /// 关闭所有 node
  void collapseAll() {
    assert(value.isInitialized);
    List<EasyTreeNode> nodes =
        value.nodes.where((element) => element.level == 0).toList();
    for (EasyTreeNode node in nodes) if (node.expanded) this.collapse(node);
    toggleNodeExpanded(value.initialNodes, false);
  }

  /// 选中 node
  void select(
    EasyTreeNode node, {
    bool selected,
    bool selectAll = false,
  }) {
    assert(value.isInitialized);
    node.select(
      selected ?? !node.selected,
      configuration: value.configuration,
    );
    if (!selectAll) _updateSelectedNodes();
  }

  /// 选中所有 node, [selected], 是否选中
  void selectAll({bool selected = true}) {
    assert(value.isInitialized);
    List<EasyTreeNode> nodes =
        value.nodes.where((element) => element.level == 0).toList();
    for (EasyTreeNode node in nodes) {
      this.select(node, selected: selected, selectAll: true);
    }
    _updateSelectedNodes();
  }

  void _updateSelectedNodes() {
    List<EasyTreeNode> nodes = [], stack = [];
    if (value.initialNodes != null) stack.addAll(value.initialNodes);
    while (stack.length > 0) {
      EasyTreeNode node = stack.removeAt(0);
      if (node.selected) nodes.add(node);
      if (!node.isLeaf) stack.insertAll(0, node.children);
    }
    value = value.copyWith(selectedNodes: nodes);
  }
}
