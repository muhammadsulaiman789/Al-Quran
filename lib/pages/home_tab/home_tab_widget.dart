import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quran_app/baselib/base_state_mixin.dart';
import 'package:quran_app/baselib/base_widgetparameter_mixin.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:quran_app/models/models.dart';
import 'package:quran_app/pages/bookmarks/bookmarks_widget.dart';
import 'package:quran_app/pages/error/error_widget.dart';
import 'package:quran_app/pages/home_tab/home_tab_store.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/pages/home_tab_juz/home_tab_juz_widget.dart';
import 'package:quran_app/pages/home_tab_surah/home_tab_surah_store.dart';
import 'package:quran_app/pages/home_tab_surah/home_tab_surah_widget.dart';
import 'package:quran_app/pages/quran/quran_store.dart';
import 'package:quran_app/pages/quran_navigator/quran_navigator_store.dart';
import 'package:quran_app/pages/quran_navigator/quran_navigator_widget.dart';
import 'package:quran_app/pages/quran_settings_app/quran_settings_app_widget.dart';
import 'home_tab_store.dart';



class HomeTabWidget extends StatefulWidget with BaseWidgetParameterMixin {
  HomeTabWidget({Key key}) : super(key: key);

  _HomeTabWidgetState createState() => _HomeTabWidgetState();
}

class _HomeTabWidgetState extends State<HomeTabWidget>
    with BaseStateMixin<HomeTabStore, HomeTabWidget>, TickerProviderStateMixin, AutomaticKeepAliveClientMixin {


  final _store = HomeTabStore();

  HomeTabStore get store => _store;

  @override
  void initState() {
    super.initState();

  }


  @override
  bool get wantKeepAlive => true;

  void _showFormDialog() {
    var alert = new AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.search),
          new Padding(
            padding: EdgeInsets.only(left: 10.0),
          ),
          Text('Pergi ke Sura'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              StreamBuilder<Chapters>(
                initialData: store.selectedChapter$.value,
                stream: store.selectedChapter$,
                builder:
                    (BuildContext context, AsyncSnapshot<Chapters> snapshot) {
                  var selectedChapter = snapshot.data;
                  if (selectedChapter == null) {
                    return Container();
                  }
                  return Text(
                    '${selectedChapter.chapterNumber}. ${selectedChapter
                        .nameSimple}',
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_drop_down),
                onPressed: () {
                  store.pickQuranNavigator.executeIf();
                },
              ),
            ],
          ),
          new Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Text('Masukan nomor ayat antara', style: TextStyle(fontSize: 13.0),),
          new Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          new Container(
              width: 100.0,
              child: new TextField(
                textAlign: TextAlign.center,
                decoration: new InputDecoration(
                  hintText: '1-7',
                ),
              )
          ),
          // Date
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () => debugPrint("Save button"),
          child: Text('OK', style: TextStyle(color: Colors.teal),),),
        new FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.teal),))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }




  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: const Color(0xff14d2b8),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back),
          ),
          title: Row(
            //padding: EdgeInsets.only(left 10.0),
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Al - Quran',
                  style: TextStyle(fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                new Padding(
                  padding: EdgeInsets.only(left: 80.0, bottom: 10.0),
                ),
                IconButton(
                  onPressed: _showFormDialog,
                  icon: Icon(Icons.search), color: Colors.white,
                ),
              ]),
          bottom: TabBar(
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelColor: Colors.white,
            tabs: [
              Tab(
                child: Text(
                  'SURAH',
                  style: GoogleFonts.sourceSansPro(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'JUZ',
                  style: GoogleFonts.sourceSansPro(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'BOOKMARK',
                  style: GoogleFonts.sourceSansPro(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          //controller: pageTabController,
          children: <Widget>[
            HomeTabSurahWidget(),
            HomeTabJuzWidget(),
            BookmarksWidget(),
          ],
        ),
      ),
    );
  }
}

