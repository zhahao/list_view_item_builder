/// @author : 查昊
/// @date : 2019.05.08

library list_view_item_builder;

import 'package:flutter/material.dart';

typedef ListViewSectionCountBuilder = int Function();

typedef ListViewRowCountBuilder = int Function(int section);

typedef ListViewItemWidgetBuilder = Widget Function(
    BuildContext context, int section, int index);

typedef ListViewReusableWidgetBuilder = Widget Function(
    BuildContext context, int section);

typedef ListViewItemOnTapCallback = void Function(
    BuildContext context, int section, int index);

typedef ListViewItemShouldTapCallback = bool Function(
    BuildContext context, int section, int index);

///  ListView.builder的item构造器
///  example:
///  1.创建一个ListViewItemBuilder实例
///  _itemBuilder = ListViewItemBuilder(
///        rowCountBuilder: (section) => 10,
///        itemsBuilder: (BuildContext context, int section, int index) {
///                    return Container(
///                           height: 44,
///                           child: Text('item:${section.toString()}+${index.toString()}'),
///                           );
///                    },
///        );
///
/// 2.将_itemBuilder的itemBuilder和itemCount传值给ListView
///  ListView.builder(
///      itemBuilder: _itemBuilder.itemBuilder,
///      itemCount: _itemBuilder.itemCount,
///    );
///
class ListViewItemBuilder {
  /// 总共有多少个section,如果为null.默认1个
  ListViewSectionCountBuilder sectionCountBuilder;

  /// 每一个section有多少行
  ListViewRowCountBuilder rowCountBuilder;

  /// 每一个section的item的构建
  ListViewItemWidgetBuilder itemsBuilder;

  /// 每一个section的header构建,默认null
  ListViewReusableWidgetBuilder headerBuilder;

  /// 每一个section的footer构建,默认null
  ListViewReusableWidgetBuilder footerBuilder;

  /// 点击了item的回调,默认null.
  /// 如果为null,则所有item不能点击,没有点击的波纹效果
  ListViewItemOnTapCallback itemOnTap;

  /// 是否可以点击item
  /// 如果itemOnTap == null,则都不可点击
  /// 如果itemOnTap != null,则根据itemShouldTap的返回值决定单个item是否可以点击.
  ListViewItemShouldTapCallback itemShouldTap;

  /// 整个listView的头部widget,默认null.
  Widget headerWidget;

  /// 整个listView的底部widget,默认null.
  Widget footerWidget;

  /// 获取listView的Context
  BuildContext get listViewContext => _listViewContext;

  /// listViewContext
  BuildContext _listViewContext;

  ListViewItemBuilder({
    @required this.rowCountBuilder,
    @required this.itemsBuilder,
    ListViewSectionCountBuilder sectionCountBuilder,
    ListViewItemShouldTapCallback itemShouldTap,
    this.headerBuilder,
    this.footerBuilder,
    this.headerWidget,
    this.footerWidget,
    this.itemOnTap,
  })  : assert(rowCountBuilder != null),
        assert(itemsBuilder != null),
        sectionCountBuilder =
            sectionCountBuilder ?? ListViewItemBuilder._sectionCountBuilder,
        itemShouldTap = itemShouldTap ?? ListViewItemBuilder._itemShouldTap,
        super();

  /// 获取item的count
  int get itemCount {
    return _iterateItems(false, null) as int;
  }

  /// 构建item
  Widget itemBuilder(BuildContext context, int index) {
    _listViewContext = context;
    return _iterateItems(
      true,
      index,
    ) as Widget;
  }

  dynamic _iterateItems(bool getWidget, int index) {
    int section = sectionCountBuilder();

    int count = 0;

    if (headerWidget != null) {
      count += 1;
      if (getWidget && index == 0) {
        return headerWidget;
      }
    }

    for (int i = 0; i < section; i++) {
      // header
      count++;
      if (getWidget && headerBuilder != null) {
        var header = headerBuilder(_listViewContext, i);
        if (count == (index + 1)) {
          return header ??
              Container(
                height: 0,
                color: Colors.transparent,
              );
        }
      }

      // item
      var rowCount = rowCountBuilder(i);
      if (getWidget) {
        for (int j = 0; j < rowCount; j++) {
          if (index == (count + j)) {
            Widget item = itemsBuilder(_listViewContext, i, j);
            return _itemWrapper(item, i, j);
          }
        }
      }
      count += rowCount;

      // footer
      count++;
      if (getWidget && footerBuilder != null) {
        var footer = footerBuilder(_listViewContext, i);
        if (count == index + 1) {
          return footer ??
              Container(
                height: 0,
                color: Colors.transparent,
              );
        }
      }
    }
    if (footerWidget != null) {
      count += 1;
      if (getWidget) {
        return footerWidget;
      }
    }

    return count;
  }

  Widget _itemWrapper(Widget widget, int section, int index) {
    bool canTap = itemOnTap != null &&
        itemShouldTap != null &&
        itemShouldTap(_listViewContext, section, index) == true;
    return InkWell(
      child: widget,
      onTap: !canTap
          ? null
          : () {
              itemOnTap(_listViewContext, section, index);
            },
    );
  }

  static int _sectionCountBuilder() => 1;

  static bool _itemShouldTap(BuildContext context, int section, int index) =>
      true;
}
