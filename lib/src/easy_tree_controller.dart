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

class EasyTreeController<E> {
  bool _isInitialized;
  List<VoidCallback> _listeners = [];
  GlobalKey<AnimatedListState> _listKey;
  List<EasyTreeNode<E>> _initialNodes;
  List<EasyTreeNode<E>> _nodes;
  List<EasyTreeNode<E>> _selectedNodes;
  EasyTreeConfiguration _configuration;
  EasyTreeItemRemovedBuilder<EasyTreeNode<E>> _removedItemBuilder;

  EasyTreeController();

  bool get isInitialized => _isInitialized ?? false;
  List<EasyTreeNode<E>> get nodes => _nodes ?? [];
  List<EasyTreeNode<E>> get selectedNodes => _selectedNodes ?? [];
  int get length => nodes.length;

  void initialize({
    @required List<EasyTreeNode<E>> initialNodes,
    @required EasyTreeConfiguration configuration,
    @required GlobalKey<AnimatedListState> key,
    @required EasyTreeItemRemovedBuilder<EasyTreeNode<E>> removedItemBuilder,
  }) async {
    assert(key != null);
    assert(removedItemBuilder != null);
    _listKey = key;
    _removedItemBuilder = removedItemBuilder;
    _isInitialized = true;
    _initialNodes = initializeNodes<E>(
      initialNodes,
      configuration: configuration,
    );
    _nodes = treeToList(_initialNodes);
    _configuration = configuration;
  }

  void unInitialize() {
    _isInitialized = false;
  }

  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(VoidCallback listener) {
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }

  void dispose() {
    if (_listeners != null) _listeners.clear();
  }

  void onClick(EasyTreeNode<E> node) {
    assert(_isInitialized);
    if (node.isLeaf) {
      this.select(node);
      return;
    }
    node.expanded ? collapse(node) : expand(node);
  }

  /// 展开 node
  void expand(EasyTreeNode<E> node) {
    assert(_isInitialized);
    print(node.data);
    if (node != null && !node.expanded && !node.isLeaf) {
      node.expanded = true;
      List<EasyTreeNode<E>> modified = node.getModifiedChildren;
      int index = _nodes.indexOf(node);
      if (index != -1 && modified.length > 0) {
        index += 1;
        _nodes.insertAll(index, modified);
        int total = modified.length;
        for (int offset = 0; offset < total; offset++) {
          _listKey?.currentState?.insertItem(index + offset);
        }
      }
    }
  }

  /// 展开所有 node
  void expandAll() {
    assert(_isInitialized);
    List<EasyTreeNode<E>> result = flatTree(_initialNodes);
    for (EasyTreeNode<E> item in result) {
      if (!item.expanded && !item.isLeaf) this.expand(item);
    }
    toggleNodeExpanded(_initialNodes, true);
  }

  /// 关闭 node
  void collapse(EasyTreeNode<E> node) {
    assert(_isInitialized);
    if (node != null && node.expanded) {
      node.expanded = false;
      List<EasyTreeNode<E>> modified = node.getModifiedChildren;
      for (EasyTreeNode<E> item in modified) {
        int index = _nodes.indexWhere((element) => element.key == item.key);
        if (index != -1) {
          _listKey?.currentState?.removeItem(index, (context, animation) {
            return _removedItemBuilder(item, context, animation);
          });
          _nodes.removeWhere((element) => item.key == element.key);
        }
      }
    }
  }

  /// 关闭所有 node
  void collapseAll() {
    assert(_isInitialized);
    List<EasyTreeNode<E>> result =
        _nodes.where((element) => element.level == 0).toList();
    for (EasyTreeNode<E> node in result) if (node.expanded) this.collapse(node);
    toggleNodeExpanded(_initialNodes, false);
  }

  /// 选中 node
  void select(
    EasyTreeNode<E> node, {
    bool selected,
    bool selectAll = false,
  }) {
    assert(_isInitialized);
    node.select(
      selected ?? !node.selected,
      configuration: _configuration,
    );
    if (!selectAll) _updateSelectedNodes();
  }

  /// 选中所有 node, [selected], 是否选中
  void selectAll({bool selected = true}) {
    assert(_isInitialized);
    List<EasyTreeNode<E>> result =
        _nodes.where((element) => element.level == 0).toList();
    for (EasyTreeNode<E> node in result) {
      this.select(node, selected: selected, selectAll: true);
    }
    _updateSelectedNodes();
  }

  void _updateSelectedNodes() {
    _selectedNodes = flatTree<E>(_initialNodes);
    _selectedNodes.retainWhere((element) => element.selected);
    _notifyListeners();
  }

  void _notifyListeners() {
    for (VoidCallback listener in _listeners) {
      if (listener != null) listener();
    }
  }
}
