## list_view_item_builder

listView的item构造器.

### 使用

```dart
ListView.builder的item构造器
  example:
1.创建一个ListViewItemBuilder实例
  _itemBuilder = ListViewItemBuilder(
  rowCountBuilder: (section) => 10,
  itemsBuilder: (BuildContext context, int section, int index) {
    return Container(
      height: 44,
      child: Text('item:${section.toString()}+${index.toString()}'),
    );
  },
);

2.将_itemBuilder的itemBuilder和itemCount传值给ListView
  ListView.builder(
  itemBuilder: _itemBuilder.itemBuilder,
  itemCount: _itemBuilder.itemCount,
);
```



### ListViewItemBuilder的其他属性

```
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
```



### 效果

<img src="https://upload-images.jianshu.io/upload_images/3537150-cc4ba38a9a08b0af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="50%" height="50%" div align=center />