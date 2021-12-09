// The MIT License (MIT)
//
// Copyright (c) 2021 nslog11
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
import './easy_tree_util.dart';
import './easy_tree_key_provider.dart';

class EasyTreeNode<E> {
  final E data;
  final List<EasyTreeNode<E>>? children;
  Key? key;
  int level;
  bool selected;
  bool indeterminate;
  bool expanded;
  EasyTreeNode<E>? parent;

  EasyTreeNode({
    required this.data,
    this.children,
    this.key,
    this.level = 0,
    this.selected = false,
    this.indeterminate = false,
    this.expanded = false,
    this.parent,
  });

  EasyTreeNode<E> copyWith({
    E? data,
    List<EasyTreeNode<E>>? children,
    Key? key,
    int? level,
    bool? selected,
    bool? indeterminate,
    bool? expanded,
    EasyTreeNode<E>? parent,
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
  bool get parentExpanded => this.parent?.expanded ?? false;
  bool get isFirst =>
      level == 0 ? false : (this.parent?.children?.first == this);
  bool get isLast => level == 0 ? false : (this.parent?.children?.last == this);

  EasyTreeTuple<bool, bool, bool> get getChildState {
    bool all = true, none = true;
    List<EasyTreeNode<E>> _nodes = flatTree<E>(this.children);
    _nodes.forEach((element) {
      if (!element.selected) all = false;
      if (element.selected) none = false;
    });
    return EasyTreeTuple(all, none, !all && !none);
  }

  List<EasyTreeNode<E>> get getModifiedChildren {
    if (this.isLeaf) return [];
    List<EasyTreeNode<E>> _nodes = flatTree<E>(this.children);
    _nodes.retainWhere(
        (element) => element.parent == this || element.parentExpanded);
    return _nodes;
  }

  void select(
    bool selected, {
    EasyTreeConfiguration? configuration,
  }) {
    this.selected = selected;
    if (configuration?.selectStrictly ?? false) return;
    List<EasyTreeNode<E>> _nodes = flatTree<E>(this.children);
    _nodes.forEach((element) {
      element.selected = this.selected;
    });
    _updateParentState();
  }

  void remove() {
    this.parent?.removeChild(this);
  }

  void removeChildren() {
    this.children?.clear();
  }

  void removeChild(EasyTreeNode<E> child) {
    this.children?.remove(child);
  }

  void insert(List<EasyTreeNode<E>> children) {
    children.forEach((element) {
      element.parent = this;
      element.level = this.level + 1;
      element.key = EasyTreeKeyProvider.instance.key;
    });
    this.children?.addAll(children);
  }

  void _updateParentState() {
    if (this.level == 0) return;
    EasyTreeNode<E>? parent = this.parent;
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
