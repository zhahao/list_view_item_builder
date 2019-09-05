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



### Functions

- [x] Support header,sectionHeader,item,sectionFooter,footer,loadingMore builder for listView.
- [x] Support listView jumpTo and animateTo functions by section and index for scroll to position.
- [x] Support vertical and horizontal scroll direction.



### Screenshot

<img src="https://raw.githubusercontent.com/zhahao/list_view_item_builder/master/example/ScreenShot.png" width="50%" height="50%" div align=center />