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

import './easy_tree_tuple.dart';
import './easy_tree_configuration.dart';

class EasyTreeNode<E> {
  final E data;
  final List<EasyTreeNode<E>> children;
  Key key;
  int level;
  bool selected;
  bool indeterminate;
  bool expanded;
  EasyTreeNode<E> parent;

  EasyTreeNode({
    @required this.data,
    this.children,
    this.key,
    this.level = 0,
    this.selected = false,
    this.indeterminate = false,
    this.expanded = false,
    this.parent,
  });

  EasyTreeNode copyWith({
    E data,
    List<EasyTreeNode<E>> children,
    Key key,
    int level,
    bool selected,
    bool indeterminate,
    bool expanded,
    EasyTreeNode<E> parent,
  }) {
    return EasyTreeNode(
      data: data ?? this.data,
      children: children ?? this.children,
      key: key ?? this.key,
      level: level ?? this.level,
      selected: selected ?? this.selected,
      indeterminate: indeterminate ?? this.indeterminate,
      expanded: expanded ?? this.expanded,
      parent: parent ?? this.parent,
    );
  }

  bool get isLeaf => this.children?.isEmpty ?? true;

  EasyTreeTuple<bool, bool, bool> get getChildState {
    bool all = true, none = true;
    List<EasyTreeNode> stack = [];
    if (!this.isLeaf) stack.addAll(this.children);
    while (stack.length > 0) {
      EasyTreeNode node = stack.removeAt(0);
      if (!node.selected) all = false;
      if (node.selected) none = false;
      if (!node.isLeaf) stack.insertAll(0, node.children);
    }
    return EasyTreeTuple(all, none, !all && !none);
  }

  List<EasyTreeNode> get getModifiedChildren {
    if (this.isLeaf) return [];
    List<EasyTreeNode> _nodes = _flatTree(this.children), _children = [];
    for (EasyTreeNode item in _nodes) {
      if (item.parent == this || item.parent.expanded) {
        if (!_children.contains(item)) _children.add(item);
      }
    }
    return _children;
  }

  void select(
    bool selected, {
    EasyTreeConfiguration configuration,
  }) {
    this.selected = selected;
    if (configuration.selectStrictly) return;
    List<EasyTreeNode> stack = [];
    if (!this.isLeaf) stack.addAll(this.children);
    while (stack.length > 0) {
      EasyTreeNode temp = stack.removeAt(0);
      temp.selected = this.selected;
      if (!temp.isLeaf) stack.insertAll(0, temp.children);
    }
    _updateParentState();
  }

  void remove() {
    this.parent?.removeChild(this);
  }

  void removeChild(EasyTreeNode child) {
    this.children?.remove(child);
  }

  List<EasyTreeNode> _flatTree(List<EasyTreeNode> nodes) {
    if (nodes == null) return [];
    List<EasyTreeNode> stack = [], result = [];
    stack.addAll(nodes);
    while (stack.length > 0) {
      EasyTreeNode node = stack.removeAt(0);
      if (!result.contains(node)) result.add(node);
      if (!node.isLeaf) stack.insertAll(0, node.children);
    }
    return result;
  }

  void _updateParentState() {
    if (this.level == 0) return;
    EasyTreeNode parent = this.parent;
    while (parent != null) {
      EasyTreeTuple<bool, bool, bool> tuple = parent.getChildState;
      bool all = tuple.item1, none = tuple.item2, half = tuple.item3;
      if (all) {
        parent.selected = true;
        parent.indeterminate = false;
      } else if (half) {
        parent.selected = false;
        parent.indeterminate = true;
      } else if (none) {
        parent.selected = false;
        parent.indeterminate = false;
      }
      parent = parent.parent;
    }
  }
}
