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

typedef ListViewWidgetBuilder = Widget Function(BuildContext context);

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
  ListViewReusableWidgetBuilder sectionHeaderBuilder;

  /// Footer for each section builder, null by default.
  ListViewReusableWidgetBuilder sectionFooterBuilder;

  /// The item callback is OnTaped, which defaults to null.
  /// If it is null, all items cannot be clicked, and there is no ripple effect
  ListViewItemOnTapCallback itemOnTap;

  /// Determines whether the item callback can be clicked on.
  /// If itemOnTap == null, none of them are clickable.
  /// If itemOnTap! = null, the return value of itemShouldTap determines whether an item can be clicked or not.
  ListViewItemShouldTapCallback itemShouldTap;

  /// The header widget builder for the entire listView, which defaults to null.
  ListViewWidgetBuilder headerWidgetBuilder;

  /// The footer widget builder for the entire listView, which defaults to null.
  ListViewWidgetBuilder footerWidgetBuilder;

  /// The load more widget builder for the entire listView, which defaults to null.
  ListViewWidgetBuilder loadMoreWidgetBuilder;

  /// Gets the Context of the listView.
  BuildContext get listViewContext => _listViewContext;

  /// listViewContext
  BuildContext _listViewContext;

  ListViewItemBuilder({
    this.rowCountBuilder,
    this.itemsBuilder,
    ListViewSectionCountBuilder sectionCountBuilder,
    ListViewItemShouldTapCallback itemShouldTap,
    this.sectionHeaderBuilder,
    this.sectionFooterBuilder,
    this.headerWidgetBuilder,
    this.footerWidgetBuilder,
    this.loadMoreWidgetBuilder,
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

    if (headerWidgetBuilder != null) {
      var headerWidget = headerWidgetBuilder(_listViewContext);
      if (headerWidget != null) {
        count += 1;
        if (getWidget && index == 0) {
          return headerWidget;
        }
      }
    }

    for (int i = 0; i < section; i++) {
      // header
      count++;
      if (getWidget) {
        var sectionHeader;
        if (sectionHeaderBuilder != null) {
          sectionHeader = sectionHeaderBuilder(_listViewContext, i);
        }
        if (count == (index + 1)) {
          return sectionHeader ??
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
        var sectionFooter;
        if (sectionFooterBuilder != null) {
          sectionFooter = sectionFooterBuilder(_listViewContext, i);
        }

        if (count == index + 1) {
          return sectionFooter ??
              Container(
                height: 0,
                color: Colors.transparent,
              );
        }
      }
    }

    Widget footerWidget;
    if (footerWidgetBuilder != null) {
      footerWidget = footerWidgetBuilder(_listViewContext);
      if (footerWidget != null) {
        count += 1;
      }
    }

    Widget loadMoreWidget;
    if (loadMoreWidgetBuilder != null) {
      loadMoreWidget = loadMoreWidgetBuilder(_listViewContext);
      if (loadMoreWidget != null) {
        count += 1;
      }
    }

    if (getWidget) {
      if (footerWidget != null && loadMoreWidget != null) {
        if (count == index + 2) {
          return footerWidget;
        } else {
          return loadMoreWidget;
        }
      } else if (footerWidget != null && loadMoreWidget == null) {
        return footerWidget;
      } else if (footerWidget == null && loadMoreWidget != null) {
        return loadMoreWidget;
      } else {
        return Container(
          height: 0,
          color: Colors.transparent,
        );
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
