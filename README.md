## list_view_item_builder

Item builder for ListView,to quickly build header & item & footer,and provide jumpTo function.

### Usage

- Create an instance of the ListViewItemBuilder.
- Set the values of itemBuilder and itemCount of _itemBuilder to the ListView.

```dart

  ScrollController _scrollController = ScrollController();
  _itemBuilder = ListViewItemBuilder(
        // If you want use [jumpTo] or [animateTo], need set scrollController.
        scrollController:_scrollController,
        rowCountBuilder: (section) => 10,
        itemsBuilder: (BuildContext context, int section, int index) {
                    return Container(
                           height: 44,
                           child: Text('item:${section.toString()}+${index.toString()}'),
                           );
                    },
        );

  ListView.builder(
      itemBuilder: _itemBuilder.itemBuilder,
      itemCount: _itemBuilder.itemCount,
      controller: _scrollController,
    );

  // jumpTo:
  _itemBuilder.jumpTo(int section, int index, {ListViewItemPosition position = ListViewItemPosition.top})

  // animateTo:
  _itemBuilder.animateTo(int section, int index,
      {@required Duration duration,
      @required Curve curve,
      ListViewItemPosition position = ListViewItemPosition.top})
```



### Other properties of the ListViewItemBuilder

```
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

/// Gets the Context of the listView.
BuildContext get listViewContext => _listViewContext;

/// listViewContext
BuildContext _listViewContext;
```



### Screenshot

<img src="https://raw.githubusercontent.com/zhahao/list_view_item_builder/master/example/ScreenShot.png" width="50%" height="50%" div align=center />