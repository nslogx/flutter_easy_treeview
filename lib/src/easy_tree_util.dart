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

List<EasyTreeNode> initializeNodes(
  List<EasyTreeNode> nodes, {
  EasyTreeKeyProvider keyProvider,
  EasyTreeNode parent,
  EasyTreeConfiguration configuration,
}) {
  if (nodes == null) return [];
  if (keyProvider == null) keyProvider = EasyTreeKeyProvider();
  List<EasyTreeNode> stack = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode temp = stack.removeAt(0);
    bool expanded = temp.level == 0;
    if (configuration.defaultExpandAll) expanded = true;
    temp
      ..expanded = expanded
      ..key = keyProvider.key(temp.key);
    if (!temp.isLeaf) {
      for (EasyTreeNode item in temp.children) {
        bool expanded = item.level == 0;
        if (configuration.defaultExpandAll) expanded = true;
        item
          ..level = temp.level + 1
          ..expanded = expanded
          ..parent = temp
          ..key = keyProvider.key(item.key);
      }
      stack.insertAll(0, temp.children);
    }
  }
  return nodes;
}

List<EasyTreeNode> listToTree(List<EasyTreeNode> nodes) {
  return [];
}

List<EasyTreeNode> treeToList(List<EasyTreeNode> nodes) {
  if (nodes == null) return [];
  List<EasyTreeNode> stack = [], result = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode node = stack.removeAt(0);
    if (node.level == 0 || node.expanded) {
      result.add(node);
      if (!node.isLeaf) stack.insertAll(0, node.children);
    }
  }
  return result;
}

void toggleNodeExpanded(List<EasyTreeNode> nodes, bool expanded) {
  if (nodes == null) return;
  List<EasyTreeNode> stack = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode node = stack.removeAt(0);
    if (!node.isLeaf) {
      node.expanded = expanded;
      stack.insertAll(0, node.children);
    }
  }
}

EasyTreeNode searchNode(List<EasyTreeNode> nodes, Key key) {
  if (key == null || nodes == null) return null;
  List<EasyTreeNode> stack = [];
  stack.addAll(nodes);
  while (stack.length > 0) {
    EasyTreeNode temp = stack.removeAt(0);
    if (!temp.isLeaf) stack.insertAll(0, temp.children);
    if (key == temp.key) return temp;
  }
  return null;
}
