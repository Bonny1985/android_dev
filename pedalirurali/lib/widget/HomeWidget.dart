import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/model/Post.dart';
import 'package:pedalirurali/model/PostsFilter.dart';
import 'package:pedalirurali/widget/LeftSidebarWidget.dart';
import 'package:pedalirurali/widget/PostsWidget.dart';

abstract class TabMenu {
  String getTitle();
}

class Events extends StatelessWidget implements TabMenu {
  final  PostsWidget _p = PostsWidget(filter: PostsFilter(PostTypes.events, false));
  @override
  Widget build(BuildContext context) => _p;
  @override
  String getTitle() => "Calendario Eventi";
}

class PermanentPath extends StatelessWidget implements TabMenu {
  final PostsWidget _p = PostsWidget(filter: PostsFilter(PostTypes.permanent, false));
  @override
  Widget build(BuildContext context) => _p;
  @override
  String getTitle() => "Percorsi Permanenti";
}

class FavoriteEvents extends StatelessWidget implements TabMenu {
  final PostsWidget _p = PostsWidget(filter: PostsFilter(PostTypes.events, true));
  @override
  Widget build(BuildContext context) => _p;
  @override
  String getTitle() => "I miei eventi";
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _selectedIndex = 0;
  static final List<TabMenu> _widgetOptions = <TabMenu>[
    Events(),
    PermanentPath(),
    FavoriteEvents(),
  ];

  @override
  Widget build(BuildContext context) {
    return getBody(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget getBody(BuildContext context) {

    final TabMenu tm = _widgetOptions.elementAt(_selectedIndex);
    
    return Scaffold(
        appBar: AppBar(
          title: Text(tm.getTitle()),
          //shape:Border(bottom: BorderSide(color: COLOR_SECONDARY, width: 2.0))
          
        ),
        drawer: LeftSidebarWidget(),
        body: tm as Widget,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventi'),
            BottomNavigationBarItem(icon: Icon(Icons.gesture), label: 'Percorsi'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'My'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: COLOR_SECONDARY,
          onTap: _onItemTapped
        )
    );
  }
}
