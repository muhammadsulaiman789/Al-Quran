import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/app_widgets/shimmer_loading.dart';
import 'package:quran_app/baselib/base_state_mixin.dart';
import 'package:quran_app/baselib/base_store.dart';
import 'package:quran_app/baselib/widgets.dart';
import 'package:quran_app/pages/error/error_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_tab_surah_store.dart';

class HomeTabSurahWidget extends StatefulWidget {
  HomeTabSurahWidget({Key key}) : super(key: key);

  _HomeTabSurahWidgetState createState() => _HomeTabSurahWidgetState();
}

class _HomeTabSurahWidgetState extends State<HomeTabSurahWidget>
    with
        AutomaticKeepAliveClientMixin,
        BaseStateMixin<HomeTabSurahStore, HomeTabSurahWidget> {
  final _store = HomeTabSurahStore();

  HomeTabSurahStore get store => _store;

  @override
  void initState() {
    super.initState();

    store.fetchSurah.executeIf();
    int index;
    downloadFile(context, index);
  }

  @override
  bool get wantKeepAlive => true;
  bool downloading = false;
  var progressString = "";
  IconData iconData = FontAwesomeIcons.download;

  void _showFormDialog(context, int index) {
    var alert = new AlertDialog(
      content: Observer(builder: (BuildContext context) {
        var item = store.chapters[index];
        return WidgetSelector<DataState>(selectedState: store.state, states: {
          DataState(
            enumSelector: EnumSelector.success,
          ): Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Audio Murrotal ${item.nameSimple}\n'
                'belum didownload,'
                ' download terlebih dahulu ?',
                style: TextStyle(fontSize: 18.0),
              ),
              new Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),

            ],
          ),
        });
      }),
      actions: <Widget>[
        new FlatButton(
          onPressed: ()  {
            Navigator.pop(context);
            setState(() {
              _showDownloadDialog(context, index);
            });

          },
          child: Text(
            'YA',
            style: TextStyle(color: Colors.teal),
          ),
        ),
        new FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'BATAL',
              style: TextStyle(color: Colors.teal),
            ))
      ],

    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  Future<void> downloadFile(context, int index) async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      var item = store.chapters[index];

      final audioUrl =
          "http://203.171.221.227:88/mobile/download/${item.nameSimple}.mp3";

         await dio.download(audioUrl, "${dir.path}/${item.nameSimple}.mp3",
          onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progressString = "Completed";
     // iconData = FontAwesomeIcons.soundcloud;
    });
    print("Download completed");
  }

  void _showDownloadDialog(context, int index) {
    var alert = new AlertDialog(
      content: Center(
        child: downloading
            ? Container(
                height: 120.0,
                width: 200.0,
                child: Card(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Downloading File: $progressString",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Text("No Data"),
      ),
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
        child: Observer(
          builder: (BuildContext context) {
            return WidgetSelector<DataState>(
              selectedState: store.state,
              states: {
                DataState(
                  enumSelector: EnumSelector.success,
                ): ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider(color: Colors.black);
                  },
                  itemCount: store.chapters.length,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    var item = store.chapters[index];
                    //  '${item.chapterNumber}'
                    return InkWell(
                      onTap: () {
                        store.goToQuran.executeIf(item);
                      },
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox.fromSize(
                              size: Size(52.0, 52.0),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/count_surah.png')),
                                ),
                                child: Text('${item.chapterNumber}',
                                    style: GoogleFonts.sourceSansPro(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              item.nameSimple,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${item.revelationPlace} - ${item.versesCount} ayat',
                              style: GoogleFonts.sourceSansPro(
                                color: const Color(0xffb3b33b),
                              ),
                            )
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              item.nameArabic,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            new Padding(
                              padding: EdgeInsets.only(right: 5.0),
                            ),
                            IconButton(
                              onPressed: () {
                                _showFormDialog(context, index);
                              },

                              icon: Icon(iconData),
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                DataState(
                  enumSelector: EnumSelector.loading,
                ): ListView.builder(
                  itemCount: 10,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            height: 28,
                            width: 32,
                            child: ShimmerLoading(),
                          ),
                        ],
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            height: 25,
                            child: ShimmerLoading(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 22,
                            child: ShimmerLoading(),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 28,
                            child: ShimmerLoading(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                DataState(
                  enumSelector: EnumSelector.error,
                ): Center(
                  child: MyErrorWidget(
                    message: store.state.message,
                  ),
                ),
              },
            );
          },
        ),
      ),
    );
    // return BaseWidget<HomeTabSurahStore>(
    //   store: store,
    //   initState: (store) {
    //     // store.fetchSurah.executeIf();
    //   },
    //   builder: (
    //     BuildContext context,
    //     HomeTabSurahStore store,
    //   ) {
    //     return ;
    //   },
    // );
  }
}
