import 'package:flutter/material.dart';
import 'package:list_view_item_builder/list_view_item_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text('list_view_item_builder example'),
            ),
            body: ListViewTestPage()));
  }
}

class ListViewTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QListViewTest();
}

class _QListViewTest extends State<ListViewTestPage> {
  ListViewItemBuilder _itemBuilder;
  ScrollController _scrollController = ScrollController();

  TextEditingController _sectionTextEditingController =
      TextEditingController(text: "0");
  TextEditingController _indexTextEditingController =
      TextEditingController(text: "0");

  bool _animate = false;
  Axis _scrollDirection = Axis.vertical;
  bool _scrollDirectionChanged = false;

  @override
  void initState() {
    super.initState();
    _initItemBuilder();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _jumpToWidget(),
        Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: _itemBuilder.itemBuilder,
                itemCount: _itemBuilder.itemCount,
                padding: const EdgeInsets.all(0),
                controller: _scrollController,
                scrollDirection: _scrollDirection))
      ],
    );
  }

  _initItemBuilder() {
    _itemBuilder = ListViewItemBuilder(
      scrollController: _scrollController,
      scrollDirection: _scrollDirection,
      rowCountBuilder: (section) => 10,
      sectionCountBuilder: () => 30,
      sectionHeaderBuilder: _headerBuilder,
      sectionFooterBuilder: _footerBuilder,
      itemsBuilder: _itemsBuilder,
      itemOnTap: _itemOnTap,
      itemShouldTap: _itemShouldTap,
      headerWidgetBuilder: (ctx) =>
          _widgetBuilder('HeaderWidget', Colors.green, height: 80),
      footerWidgetBuilder: (ctx) =>
          _widgetBuilder('FooterWidget', Colors.green, height: 80),
      loadMoreWidgetBuilder: (ctx) =>
          _widgetBuilder('LoadMoreWidget', Colors.lightBlue, height: 80),
    );
  }

  Widget _jumpToWidget() {
    return Container(
      color: Colors.red,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    var section = int.parse(_sectionTextEditingController.text);
                    var index = int.parse(_indexTextEditingController.text);
                    if (_animate) {
                      _itemBuilder.animateTo(section, index,
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut);
                    } else {
                      _itemBuilder.jumpTo(section, index);
                    }
                  },
                  child: Text(
                    "jumpTo",
                    style: TextStyle(fontSize: 16),
                  )),
              Text(
                "animate",
                style: TextStyle(fontSize: 16),
              ),
              Checkbox(
                value: _animate,
                onChanged: (value) {
                  setState(() {
                    _animate = value;
                  });
                },
              ),
              Text(
                "vertical",
                style: TextStyle(fontSize: 16),
              ),
              Checkbox(
                value: _scrollDirection == Axis.vertical,
                onChanged: (value) {
                  setState(() {
                    if (_scrollDirectionChanged) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(
                                    'ScrollDirection only can be changed once'),
                              ));
                    } else {
                      _scrollDirection =
                          value ? Axis.vertical : Axis.horizontal;
                      _itemBuilder.scrollDirection = _scrollDirection;
                    }
                    _scrollDirectionChanged = true;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildInputWidget("section:", _sectionTextEditingController),
              _buildInputWidget("index:", _indexTextEditingController),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInputWidget(String title, TextEditingController controller) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          Container(
            width: 30,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
            ),
          )
        ],
      ),
    );
  }

  bool _itemShouldTap(BuildContext context, int section, int index) {
    return index != 0;
  }

  void _itemOnTap(BuildContext context, int section, int index) {
    print('clicked: section: ${section.toString()},index:${index.toString()}');
  }

  Widget _itemsBuilder(BuildContext context, int section, int index) {
    return _widgetBuilder(
        'Item:section=${section.toString()},index=${index.toString()},canTap:${_itemShouldTap(context, section, index).toString()}',
        Colors.white70,
        height: 50);
  }

  Widget _headerBuilder(BuildContext context, int section) {
    return _widgetBuilder(
        'SectionHeader:section = ${section.toString()}', Colors.yellow,
        height: 30);
  }

  Widget _footerBuilder(BuildContext context, int section) {
    return _widgetBuilder(
        'SectionFooter:section = ${section.toString()}', Colors.orange,
        height: 30);
  }

  Widget _widgetBuilder(String text, Color color, {double height}) {
    var size = height ?? 44;
    return Container(
      height: _scrollDirection == Axis.horizontal ? null : size,
      width: _scrollDirection == Axis.horizontal ? size : null,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }
}
