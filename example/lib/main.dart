import 'package:flutter/material.dart';
import 'package:flutter_easy_treeview/flutter_easy_treeview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Easy TreeView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Easy TreeView'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EasyTreeController<String> treeController = EasyTreeController<String>();
  EasyTreeConfiguration configuration = EasyTreeConfiguration(
    // defaultExpandAll: true,
    padding: EdgeInsets.only(bottom: 5),
  );

  List<EasyTreeNode<String>> nodes;
  @override
  void initState() {
    super.initState();
    nodes = [
      EasyTreeNode<String>(
        data: '0',
        children: [
          EasyTreeNode<String>(
            data: '00',
            children: [
              EasyTreeNode<String>(
                data: '000',
                children: [
                  EasyTreeNode<String>(data: '0000'),
                  EasyTreeNode<String>(data: '0001'),
                  EasyTreeNode<String>(data: '0002'),
                  EasyTreeNode<String>(data: '0003'),
                  EasyTreeNode<String>(data: '0004'),
                  EasyTreeNode<String>(data: '0005'),
                ],
              ),
              EasyTreeNode<String>(data: '001'),
            ],
          ),
          EasyTreeNode<String>(data: '01'),
        ],
      ),
      EasyTreeNode<String>(
        data: '1',
        children: [
          EasyTreeNode<String>(data: '10'),
        ],
      ),
      EasyTreeNode<String>(
        data: '2',
        children: [
          EasyTreeNode<String>(data: '20'),
          EasyTreeNode<String>(
            data: '21',
            children: [
              EasyTreeNode<String>(data: '210'),
              EasyTreeNode<String>(data: '211'),
            ],
          ),
        ],
      ),
    ];
    treeController.addListener(() {
      print(treeController.selectedNodes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              nodes.add(EasyTreeNode<String>(data: '3'));
              setState(() {});
            },
            child: Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => treeController.collapseAll(),
                child: Text('Collapse All'),
              ),
              FlatButton(
                onPressed: () => treeController.expandAll(),
                child: Text('Expand All'),
              ),
              FlatButton(
                onPressed: () => treeController.selectAll(),
                child: Text('Select All'),
              ),
              FlatButton(
                onPressed: () => treeController.selectAll(selected: false),
                child: Text('UnSelect All'),
              ),
            ],
          ),
          Expanded(
            child: EasyTreeView<String>(
              nodes: nodes,
              controller: treeController,
              configuration: configuration,
              callback: (EasyTreeNode<String> node) {
                if (node.isLeaf) {
                  treeController.select(node);
                } else {
                  treeController.onClick(node);
                }
              },
              itemBuilder: (BuildContext context, EasyTreeNode<String> node) {
                Color color = Colors.red;
                if (node.level == 1) {
                  color = Colors.orange;
                } else if (node.level == 2) {
                  color = Colors.blue;
                } else if (node.level == 3) {
                  color = Colors.purple;
                }
                if (node.selected) color = Colors.green;
                return Container(
                  height: 44.0,
                  color: color,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Text('${node.expanded.toString()} ${node.data}'),
                        margin: const EdgeInsets.only(left: 10),
                      ),
                      FlatButton(
                        onPressed: () => treeController.select(node),
                        child: Text(
                          'Select',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
