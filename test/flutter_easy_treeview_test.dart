import 'package:flutter_test/flutter_test.dart';
import '../lib/src/easy_tree_util.dart';
import '../lib/src/easy_tree_node.dart';

void main() {
  test('tree to list', () {
    List<EasyTreeNode<String>> nodes = [
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

    List<EasyTreeNode> result = treeToList(nodes);
    result.forEach((element) {
      print('element.data ${element.data}');
      print('element.level ${element.level}');
      print('================');
    });
  });
}
