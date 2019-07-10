library list_view_item_builder;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

typedef ListViewSectionCountBuilder = int Function();

typedef ListViewRowCountBuilder = int Function(int section);

typedef ListViewItemWidgetBuilder = Widget Function(
    BuildContext context, int section, int index);

typedef ListViewItemHeightBuilder = double Function(
    BuildContext context, int section, int index);

typedef ListViewSectionHeightBuilder = double Function(
    BuildContext context, int section);

typedef ListViewReusableWidgetBuilder = Widget Function(
    BuildContext context, int section);

typedef ListViewItemOnTapCallback = void Function(
    BuildContext context, int section, int index);

typedef ListViewItemShouldTapCallback = bool Function(
    BuildContext context, int section, int index);

typedef ListViewWidgetBuilder = Widget Function(BuildContext context);

enum ListViewItemPosition { top, middle, bottom }

const int _sectionHeaderIndex = -1;

///  Usage:
///  1.Create an instance of the ListViewItemBuilder.
///  2.Set the values of itemBuilder and itemCount of _itemBuilder to the ListView.
///  {@tool sample}
///  ```dart
///  ScrollController _scrollController = ScrollController();
///  _itemBuilder = ListViewItemBuilder(
///        // If you want use [jumpTo] or [animateTo], need a ScrollController relative listView.
///        scrollController:_scrollController,
///        rowCountBuilder: (section) => 10,
///        itemsBuilder: (BuildContext context, int section, int index) {
///                    return Container(
///                           height: 44,
///                           child: Text('item:${section.toString()}+${index.toString()}'),
///                           );
///                    },
///        );
///
///  ListView.builder(
///      itemBuilder: _itemBuilder.itemBuilder,
///      itemCount: _itemBuilder.itemCount,
///      controller: _scrollController,
///    );
///
///  // jumpTo:
///  _itemBuilder.jumpTo(int section, int index, {ListViewItemPosition position = ListViewItemPosition.top})
///
///  // animateTo:
///  _itemBuilder.animateTo(int section, int index,
///      {@required Duration duration,
///      @required Curve curve,
///      ListViewItemPosition position = ListViewItemPosition.top})
/// ```
/// {@end-tool}
class ListViewItemBuilder {
  /// listView scrollController
  /// If you want to use [animateTo] or [jumpTo] ,scrollController must not be null.
  ScrollController scrollController;

  /// How many sections are there in total. If null, Default is 1 section.
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
  /// If itemOnTap != null, the return value of itemShouldTap determines whether an item can be clicked or not.
  ListViewItemShouldTapCallback itemShouldTap;

  /// The header widget builder for the entire listView, which defaults to null.
  ListViewWidgetBuilder headerWidgetBuilder;

  /// The footer widget builder for the entire listView, which defaults to null.
  ListViewWidgetBuilder footerWidgetBuilder;

  /// The load more widget builder for the entire listView, which defaults to null.
  ListViewWidgetBuilder loadMoreWidgetBuilder;

  /// Get the Context of the listView.
  BuildContext get listViewContext => _listViewContext;

  /// ListView context
  BuildContext _listViewContext;

  /// All item height cache.
  Map<String, double> _itemsHeightCache = <String, double>{};

  ListViewItemBuilder(
      {this.rowCountBuilder,
      this.itemsBuilder,
      ListViewSectionCountBuilder sectionCountBuilder,
      ListViewItemShouldTapCallback itemShouldTap,
      this.sectionHeaderBuilder,
      this.sectionFooterBuilder,
      this.headerWidgetBuilder,
      this.footerWidgetBuilder,
      this.loadMoreWidgetBuilder,
      this.itemOnTap,
      this.scrollController})
      : sectionCountBuilder =
            sectionCountBuilder ?? ListViewItemBuilder._sectionCountBuilder,
        itemShouldTap = itemShouldTap ?? ListViewItemBuilder._itemShouldTap,
        super();

  /// Set this value to [ListView.builder.itemCount].
  int get itemCount => _iterateItems(
        false,
        null,
      ) as int;

  /// Set this value to [ListView.builder.itemBuilder].
  Widget itemBuilder(BuildContext context, int index) {
    _listViewContext = context;
    return _iterateItems(
      true,
      index,
    ) as Widget;
  }

  /// Jumps the scroll position from its current value to the given section and index.
  /// [scrollController] must not be null.
  Future<void> jumpTo(int section, int index,
      {ListViewItemPosition position = ListViewItemPosition.top}) async {
    return _jumpTo(section, index, position: position);
  }

  /// Animates the position from its current value to the given section and index.
  /// [scrollController] must not be null.
  Future<void> animateTo(int section, int index,
      {@required Duration duration,
      @required Curve curve,
      ListViewItemPosition position = ListViewItemPosition.top}) async {
    var startOffset = scrollController.offset;
    await _jumpTo(section, index, position: position);
    var endOffset = scrollController.offset;
    await scrollController.position.moveTo(startOffset);
    return scrollController.animateTo(endOffset,
        duration: duration, curve: curve);
  }

  Future<void> _jumpTo(int section, int index,
      {ListViewItemPosition position = ListViewItemPosition.top}) async {
    assert(section != null && index != null);
    assert(scrollController != null);
    assert(scrollController.hasClients == true);
    assert(_listViewContext?.findRenderObject()?.paintBounds != null,
        "The listView must already be laid out.");
    assert(() {
      var totalSection = sectionCountBuilder();
      if (section >= totalSection || section < 0) return false;

      var rowCount = rowCountBuilder(section);
      if (index >= rowCount || index < 0) return false;

      return true;
    }(),
        "section:${section.toString()} and index:${index.toString()} was beyond range of listView");

    /// current max visible item position
    int maxSection = _sectionHeaderIndex;
    int maxIndex = _sectionHeaderIndex;

    double itemsHeight = 0.0;
    double targetItemHeight = 0.0;
    double targetItemTop = 0;

    _itemsHeightCache.forEach((key, height) {
      var keys = key.split("+");
      var cacheSection = int.parse(keys.first);
      var cacheIndex = int.parse(keys.last);
      var itemHeight = height ?? 0;

      /// find max maxSection and maxIndex
      if (cacheSection > maxSection ||
          (cacheSection == maxSection && cacheIndex > maxIndex)) {
        maxSection = cacheSection;
        maxIndex = cacheIndex;
        itemsHeight += itemHeight;
      }

      if (cacheSection < section ||
          (cacheSection == section && cacheIndex < index)) {
        targetItemTop += itemHeight;
      }

      if (index == cacheIndex && section == cacheSection) {
        targetItemHeight = itemHeight;
      }
    });

    /// Target item is visible,we can get it's size info.
    if (section < maxSection || (section == maxSection && index < maxIndex)) {
      return scrollController.position.moveTo(_calculateOffset(
          targetItemTop, targetItemHeight,
          position: position));
    }

    /// Target item is invisible,It hasn't been laid out yet.
    else {
      var listViewHeight =
          _listViewContext?.findRenderObject()?.paintBounds?.size?.height;
      var invisibleKeys = [];

      var totalSectionCount = sectionCountBuilder();

      var targetKey = _cacheKey(section: section, index: index);

      for (int i = maxSection; i < totalSectionCount; i++) {
        var rowCount = rowCountBuilder(i);

        /// add sectionFooter
        rowCount += 1;
        int beginRowIndex =
            (i == maxSection) ? (maxIndex + 1) : _sectionHeaderIndex;
        for (int j = beginRowIndex; j < rowCount; j++) {
          invisibleKeys.add(_cacheKey(section: i, index: j));
        }
      }

      int currentCacheIndex = 0;
      double tryPixel = 1;
      double tryOffset = itemsHeight - listViewHeight;
      bool isTargetIndex = false;
      int targetKeyIndex = invisibleKeys.indexOf(targetKey);

      /// Each time we ask the scrollController to try to scroll down tryPixel to start the listView's preload mechanism,
      /// we will get the latest item layout result after the item layout is finished,
      /// and accumulate itemsHeight until the boundary is triggered and the loop is finished.
      while (true) {
        tryOffset += tryPixel;

        if (isTargetIndex) break;
        if (currentCacheIndex >= invisibleKeys.length) break;
        if (tryOffset >= scrollController.position.maxScrollExtent) break;

        /// Wait scrollController move finished
        await scrollController.position.moveTo(tryOffset);

        /// Wait items layout finished
        await SchedulerBinding.instance.endOfFrame;

        var nextHeights = 0.0;

        /// ListView maybe layout many items
        var _currentCacheIndex = currentCacheIndex;
        for (int i = currentCacheIndex; i < invisibleKeys.length; i++) {
          var nextCacheKey = invisibleKeys[i];
          var nextHeight = _itemsHeightCache[nextCacheKey];

          if (nextHeight != null) {
            if (i == targetKeyIndex) {
              isTargetIndex = true;
              targetItemHeight = nextHeight;
              break;
            } else {
              nextHeights += nextHeight;
              _currentCacheIndex = i;
            }
          } else {
            break;
          }
        }
        currentCacheIndex = _currentCacheIndex;

        itemsHeight += nextHeights;
        currentCacheIndex++;
        tryOffset = itemsHeight - listViewHeight;
      }

      return scrollController.position.moveTo(
          _calculateOffset(itemsHeight, targetItemHeight, position: position));
    }
  }

  dynamic _iterateItems(bool getWidget, int index) {
    assert(rowCountBuilder != null);
    assert(itemsBuilder != null);

    /// All item key cache. When listView setState invoked we should update _itemsHeightCache.
    Set<String> itemKeyCache = Set<String>();

    int section = sectionCountBuilder();

    int count = 0;

    if (headerWidgetBuilder != null) {
      var headerWidget = headerWidgetBuilder(_listViewContext);
      if (headerWidget != null) {
        count += 1;
        var cacheKey = _cacheKey(section: _sectionHeaderIndex, index: 0);
        itemKeyCache.add(cacheKey);
        if (getWidget && index == 0) {
          return _buildWidgetContainer(
              cacheKey,
              false,
              headerWidget ??
                  Container(
                    height: 0,
                    color: Colors.transparent,
                  ));
        }
      }
    }

    for (int i = 0; i < section; i++) {
      // SectionHeader
      count++;
      var cacheKey = _cacheKey(section: i, index: _sectionHeaderIndex);
      if (getWidget) {
        var sectionHeader;
        if (sectionHeaderBuilder != null) {
          sectionHeader = sectionHeaderBuilder(_listViewContext, i);
        }
        if (count == (index + 1)) {
          return _buildWidgetContainer(
              cacheKey,
              false,
              sectionHeader ??
                  Container(
                    height: 0,
                    color: Colors.transparent,
                  ));
        }
      } else {
        itemKeyCache.add(cacheKey);
      }

      // Item
      var rowCount = rowCountBuilder(i);
      if (getWidget) {
        for (int j = 0; j < rowCount; j++) {
          if (index == (count + j)) {
            Widget item = itemsBuilder(_listViewContext, i, j);
            bool canTap = itemOnTap != null &&
                itemShouldTap != null &&
                itemShouldTap(_listViewContext, i, j) == true;
            var cacheKey = _cacheKey(section: i, index: j);
            return _buildWidgetContainer(cacheKey, canTap, item);
          }
        }
      } else {
        for (int j = 0; j < rowCount; j++) {
          itemKeyCache.add(_cacheKey(section: i, index: j));
        }
      }
      count += rowCount;

      // SectionFooter
      count++;
      if (getWidget) {
        var sectionFooter;
        if (sectionFooterBuilder != null) {
          sectionFooter = sectionFooterBuilder(_listViewContext, i);
        }

        if (count == index + 1) {
          var cacheKey = _cacheKey(section: i, index: rowCount);
          return _buildWidgetContainer(
              cacheKey,
              false,
              sectionFooter ??
                  Container(
                    height: 0,
                    color: Colors.transparent,
                  ));
        }
      } else {
        itemKeyCache.add(_cacheKey(section: i, index: rowCount));
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

    /// Remove extra item keys.
    if (!getWidget) {
      _itemsHeightCache.removeWhere((k, v) => !itemKeyCache.contains(k));
    }

    return count;
  }

  double _calculateOffset(double top, double itemHeight,
      {ListViewItemPosition position = ListViewItemPosition.top}) {
    switch (position) {
      case ListViewItemPosition.top:
        return top;
      case ListViewItemPosition.middle:
        return top + itemHeight * 0.5;
      case ListViewItemPosition.bottom:
        return top + itemHeight;
    }
    return top;
  }

  Widget _buildWidgetContainer(String cacheKey, bool canTap, Widget widget) {
    return _ListViewItemContainer(
      cacheKey: cacheKey,
      child: widget,
      canTap: canTap,
      itemOnTap: itemOnTap,
      listViewContext: _listViewContext,
      itemHeightCache: _itemsHeightCache,
    );
  }

  String _cacheKey({int section, int index}) =>
      "${section.toString()}+${index.toString()}";

  static int _sectionCountBuilder() => 1;

  static bool _itemShouldTap(BuildContext context, int section, int index) =>
      true;
}

class _ListViewItemContainer extends StatefulWidget {
  final String cacheKey;
  final bool canTap;
  final ListViewItemOnTapCallback itemOnTap;
  final BuildContext listViewContext;
  final Widget child;
  final Map<String, double> itemHeightCache;

  @override
  State<StatefulWidget> createState() => _ListViewItemContainerState();

  _ListViewItemContainer({
    this.canTap,
    this.itemOnTap,
    this.listViewContext,
    this.child,
    this.cacheKey,
    this.itemHeightCache,
  });
}

class _ListViewItemContainerState extends State<_ListViewItemContainer> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<LayoutChangedNotification>(
      onNotification: (notification) {
        _saveHeightToCache();
      },
      child: InitialSizeChangedLayoutNotifier(
        child: widget.canTap
            ? InkWell(
                child: widget.child,
                onTap: () {
                  var keys = widget.cacheKey.split("+");

                  var section = int.parse(keys.first);
                  var index = int.parse(keys.last);
                  widget.itemOnTap(widget.listViewContext, section, index);
                },
              )
            : Container(
                color: Colors.transparent,
                child: widget.child,
              ),
      ),
    );
  }

  _saveHeightToCache() {
    if (!mounted) return;
    var height = context.findRenderObject()?.paintBounds?.height;
    if (height != null) {
      widget.itemHeightCache[widget.cacheKey] = height;
    }
  }
}

/// Added [SizeChangedLayoutNotifier] initial notification.
class InitialSizeChangedLayoutNotifier extends SingleChildRenderObjectWidget {
  const InitialSizeChangedLayoutNotifier({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  _InitialRenderSizeChangedWithCallback createRenderObject(
      BuildContext context) {
    return _InitialRenderSizeChangedWithCallback(onLayoutChangedCallback: () {
      SizeChangedLayoutNotification().dispatch(context);
    });
  }
}

class _InitialRenderSizeChangedWithCallback extends RenderProxyBox {
  _InitialRenderSizeChangedWithCallback({
    RenderBox child,
    @required this.onLayoutChangedCallback,
  })  : assert(onLayoutChangedCallback != null),
        super(child);

  final VoidCallback onLayoutChangedCallback;

  Size _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    // Send the initial notification, or this will be SizeObserver all
    // over again!
    if (size != _oldSize) onLayoutChangedCallback();
    _oldSize = size;
  }
}
