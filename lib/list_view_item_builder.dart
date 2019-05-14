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

///  The item builder of the listView.
///  Example:
///  1.Create an instance of the ListViewItemBuilder
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
/// 2.Pass the values of itemBuilder and itemCount of _itemBuilder to the ListView
///  ListView.builder(
///      itemBuilder: _itemBuilder.itemBuilder,
///      itemCount: _itemBuilder.itemCount,
///    );
///
class ListViewItemBuilder {
  /// How many sections are there in total. If null. Default is 1 section.
  ListViewSectionCountBuilder sectionCountBuilder;

  /// How many rows are in each section.
  ListViewRowCountBuilder rowCountBuilder;

  /// Builder of items for each section.
  ListViewItemWidgetBuilder itemsBuilder;

  /// Header for each section builder, null by default.
  ListViewReusableWidgetBuilder headerBuilder;

  /// Footer for each section builder, null by default.
  ListViewReusableWidgetBuilder footerBuilder;

  /// The item callback is OnTaped, which defaults to null.
  /// If it is null, all items cannot be clicked, and there is no ripple effect
  ListViewItemOnTapCallback itemOnTap;

  /// Determines whether the item callback can be clicked on.
  /// If itemOnTap == null, none of them are clickable.
  /// If itemOnTap! = null, the return value of itemShouldTap determines whether an item can be clicked or not.
  ListViewItemShouldTapCallback itemShouldTap;

  /// The header widget for the entire listView, which defaults to null.
  Widget headerWidget;

  /// The footer widget for the entire listView, which defaults to null.
  Widget footerWidget;

  /// Gets the Context of the listView.
  BuildContext get listViewContext => _listViewContext;

  /// listViewContext
  BuildContext _listViewContext;

  ListViewItemBuilder({
    this.rowCountBuilder,
    this.itemsBuilder,
    ListViewSectionCountBuilder sectionCountBuilder,
    ListViewItemShouldTapCallback itemShouldTap,
    this.headerBuilder,
    this.footerBuilder,
    this.headerWidget,
    this.footerWidget,
    this.itemOnTap,
  })  : sectionCountBuilder =
            sectionCountBuilder ?? ListViewItemBuilder._sectionCountBuilder,
        itemShouldTap = itemShouldTap ?? ListViewItemBuilder._itemShouldTap,
        super();

  int get itemCount {
    return _iterateItems(false, null) as int;
  }

  Widget itemBuilder(BuildContext context, int index) {
    _listViewContext = context;
    return _iterateItems(
      true,
      index,
    ) as Widget;
  }

  dynamic _iterateItems(bool getWidget, int index) {
    assert(rowCountBuilder != null);
    assert(itemsBuilder != null);

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
      if (getWidget) {
        var header;
        if (headerBuilder != null) {
          header = headerBuilder(_listViewContext, i);
        }
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
      if (getWidget) {
        var footer;
        if (footerBuilder != null) {
          footer = footerBuilder(_listViewContext, i);
        }

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
