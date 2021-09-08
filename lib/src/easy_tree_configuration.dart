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

class EasyTreeConfiguration {
  /// 缩进距离
  final double indent;

  /// 初始滚动距离
  final double initialScrollOffset;

  /// 是否每次只打开一个同级树节点展开(暂未实现)
  final bool accordion;

  /// 是否严格的遵循父子不互相关联的做法，默认为 false
  final bool selectStrictly;

  /// 是否在点击节点的时候展开或者收缩节点，默认值为 true(暂未实现)
  final bool expandOnClickNode;

  /// 是否默认展开全部节点，默认 false
  final bool defaultExpandAll;

  /// node 边距
  final EdgeInsets padding;

  const EasyTreeConfiguration({
    this.indent = 10,
    this.initialScrollOffset = 0,
    this.accordion = false,
    this.selectStrictly = false,
    this.expandOnClickNode = true,
    this.defaultExpandAll = false,
    this.padding = EdgeInsets.zero,
  })  : assert(indent != null),
        assert(initialScrollOffset != null),
        assert(accordion != null),
        assert(selectStrictly != null),
        assert(expandOnClickNode != null),
        assert(defaultExpandAll != null);
}
