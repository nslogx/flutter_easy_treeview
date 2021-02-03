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
import './easy_tree_controller.dart';
import './easy_tree_configuration.dart';
import './easy_tree_node_item.dart';

typedef EasyTreeItemBuilder = Widget Function(
    BuildContext context, EasyTreeNode node);
typedef EasyTreeItemRemovedBuilder = Widget Function(
    EasyTreeNode node, BuildContext context, Animation<double> animation);
typedef EasyTreeNodeCallback = void Function(EasyTreeNode node);

class EasyTreeView extends StatefulWidget {
  final List<EasyTreeNode> nodes;
  final EasyTreeController controller;
  final EasyTreeItemBuilder itemBuilder;
  final EasyTreeNodeCallback callback;
  final EasyTreeConfiguration configuration;

  const EasyTreeView({
    Key key,
    @required this.nodes,
    @required this.itemBuilder,
    @required this.controller,
    this.callback,
    this.configuration,
  })  : assert(nodes != null),
        assert(itemBuilder != null),
        assert(controller != null),
        super(key: key);

  @override
  _EasyTreeViewState createState() => _EasyTreeViewState();
}

class _EasyTreeViewState extends State<EasyTreeView> {
  GlobalKey<AnimatedListState> _listKey;
  EasyTreeConfiguration _configuration;
  VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _configuration = widget.configuration ?? EasyTreeConfiguration();
    _listener = () {
      setState(() {});
    };
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(EasyTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    widget.controller.unInitialize();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _initialize() {
    _listKey = GlobalKey<AnimatedListState>();
    widget.controller.initialize(
      initialNodes: widget.nodes,
      configuration: _configuration,
      key: _listKey,
      removedItemBuilder: _removedItemBuilder,
    );
    widget.controller.addListener(_listener);
  }

  Widget _removedItemBuilder(
    EasyTreeNode node,
    BuildContext context,
    Animation<double> animation,
  ) {
    return _buildItem(context, node, animation);
  }

  Widget _buildItem(
    BuildContext context,
    EasyTreeNode node,
    Animation<double> animation,
  ) {
    double indent = widget.configuration.indent ?? 10;
    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        child: Container(
          margin: EdgeInsets.only(left: indent * node.level),
          child: Container(
            padding: widget.configuration.padding ?? EdgeInsets.zero,
            child: EasyTreeNodeItem(
              child: widget.itemBuilder(context, node),
            ),
          ),
        ),
        onTap: () => widget.callback != null
            ? widget.callback(node)
            : widget.controller.onClick(node),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isInitialized) _initialize();
    return AnimatedList(
      key: _listKey,
      initialItemCount: widget.controller.length,
      itemBuilder: (context, index, animation) {
        return _buildItem(context, widget.controller.nodes[index], animation);
      },
    );
  }
}
