import 'package:quiver/core.dart';

class EasyTreeTuple<T1, T2, T3> {
  /// Returns the first item of the tuple
  final T1 item1;

  /// Returns the second item of the tuple
  final T2 item2;

  /// Returns the third item of the tuple
  final T3 item3;

  /// Creates a new tuple value with the specified items.
  const EasyTreeTuple(this.item1, this.item2, this.item3);

  /// Create a new tuple value with the specified list [items].
  factory EasyTreeTuple.fromList(List items) {
    if (items.length != 3) {
      throw ArgumentError('items must have length 3');
    }

    return EasyTreeTuple<T1, T2, T3>(
        items[0] as T1, items[1] as T2, items[2] as T3);
  }

  /// Returns a tuple with the first item set to the specified value.
  EasyTreeTuple<T1, T2, T3> withItem1(T1 v) =>
      EasyTreeTuple<T1, T2, T3>(v, item2, item3);

  /// Returns a tuple with the second item set to the specified value.
  EasyTreeTuple<T1, T2, T3> withItem2(T2 v) =>
      EasyTreeTuple<T1, T2, T3>(item1, v, item3);

  /// Returns a tuple with the third item set to the specified value.
  EasyTreeTuple<T1, T2, T3> withItem3(T3 v) =>
      EasyTreeTuple<T1, T2, T3>(item1, item2, v);

  /// Creates a [List] containing the items of this [EasyTreeTuple].
  ///
  /// The elements are in item order. The list is variable-length
  /// if [growable] is true.
  List toList({bool growable = false}) =>
      List.from([item1, item2, item3], growable: growable);

  @override
  String toString() => '[$item1, $item2, $item3]';

  @override
  bool operator ==(Object other) =>
      other is EasyTreeTuple &&
      other.item1 == item1 &&
      other.item2 == item2 &&
      other.item3 == item3;

  @override
  int get hashCode => hash3(item1.hashCode, item2.hashCode, item3.hashCode);
}
