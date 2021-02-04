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

import './easy_tree_node.dart';
import './easy_tree_key_provider.dart';
import './easy_tree_configuration.dart';

List<EasyTreeNode<E>> configurationNodes<E>(
  List<EasyTreeNode<E>> nodes,
  EasyTreeConfiguration configuration,
) {
  if (nodes == null) return [];
  List<EasyTreeNode<E>> stack = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode<E> node = stack.removeAt(0);
    bool expanded = node.expanded ?? false;
    if (configuration.defaultExpandAll) expanded = true;
    if (node.isLeaf) expanded = false;
    node.expanded = expanded;
    if (!node.isLeaf) stack.insertAll(0, node.children);
  }
  return nodes;
}

List<EasyTreeNode<E>> initializeNodes<E>(
  List<EasyTreeNode<E>> nodes, {
  EasyTreeKeyProvider keyProvider,
  EasyTreeConfiguration configuration,
}) {
  if (nodes == null) return [];
  if (keyProvider == null) keyProvider = EasyTreeKeyProvider();
  List<EasyTreeNode<E>> stack = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode<E> node = stack.removeAt(0);
    node.key = keyProvider.key(node.key);
    if (!node.isLeaf) {
      for (EasyTreeNode<E> item in node.children) {
        item
          ..level = node.level + 1
          ..parent = node
          ..key = keyProvider.key(item.key);
      }
      stack.insertAll(0, node.children);
    }
  }
  return nodes;
}

List<EasyTreeNode<E>> listToTree<E>(List<EasyTreeNode<E>> nodes) {
  return [];
}

List<EasyTreeNode<E>> flatTree<E>(List<EasyTreeNode<E>> nodes) {
  if (nodes == null) return [];
  List<EasyTreeNode<E>> stack = [], result = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode<E> node = stack.removeAt(0);
    if (!result.contains(node)) result.add(node);
    if (!node.isLeaf) stack.insertAll(0, node.children);
  }
  return result;
}

List<EasyTreeNode<E>> treeToList<E>(List<EasyTreeNode<E>> nodes) {
  if (nodes == null) return [];
  List<EasyTreeNode<E>> result = flatTree<E>(nodes);
  result.retainWhere((element) => element.level == 0 || element.parentExpanded);
  return result;
}

void toggleNodeExpanded<E>(List<EasyTreeNode<E>> nodes, bool expanded) {
  assert(expanded != null);
  if (nodes == null) return;
  List<EasyTreeNode<E>> result = flatTree<E>(nodes);
  result.forEach((element) {
    if (!element.isLeaf) element.expanded = expanded;
  });
}

EasyTreeNode<E> searchNode<E>(List<EasyTreeNode<E>> nodes, Key key) {
  if (key == null || nodes == null) return null;
  List<EasyTreeNode<E>> stack = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode<E> temp = stack.removeAt(0);
    if (!temp.isLeaf) stack.insertAll(0, temp.children);
    if (key == temp.key) return temp;
  }
  return null;
}
