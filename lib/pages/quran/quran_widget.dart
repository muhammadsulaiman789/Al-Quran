import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quran_app/app_widgets/shimmer_loading.dart';
import 'package:quran_app/baselib/base_state_mixin.dart';
import 'package:quran_app/baselib/base_widgetparameter_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/baselib/widgets.dart';
import 'package:share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quran_app/models/models.dart';
import 'package:quran_app/models/translation_data.dart';
import 'package:quran_app/pages/quran/quran_store.dart';
import 'package:quiver/strings.dart';
import 'package:quran_app/pages/quran_navigator/quran_navigator_store.dart';
import 'package:quran_app/pages/quran_navigator/quran_navigator_widget.dart';
import 'package:quran_app/pages/quran_settings/quran_settings_widget.dart';
import 'package:quran_app/services/quran_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:social_share/social_share.dart';
import 'package:tuple/tuple.dart';
import '../quran_settings/quran_settings_store.dart';

class QuranWidget extends StatefulWidget with BaseWidgetParameterMixin {
  QuranWidget({Key key}) : super(key: key);

  _QuranWidgetState createState() => _QuranWidgetState();
}

class _QuranWidgetState extends State<QuranWidget>
    with
        BaseStateMixin<QuranStore, QuranWidget>,
        AutomaticKeepAliveClientMixin {


  bool isPlaying = false;
  Duration _duration;
  Duration _position;
  double _slider;
  double _sliderVolume;
  String _error;
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;
  QuranStore _store;

  @override
  QuranStore get store => _store;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _store = QuranStore(
      parameter: widget.parameter,
    );

    {
      var d = _store.pickQuranNavigatorInteraction.registerHandler((p) async {
        var r = await showDialog(
          context: context,
          builder: (context) {
            return QuranNavigatorWidget(
              store: QuranNavigatorStore(
                parameter: p,
              ),
            );
          },
        );
        return r;
      });
      _store.registerDispose(() {
        d.dispose();
      });
    }
  }

  Widget bottomPanel() {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: getPlayModeIcon(playMode),
                onPressed: () {
                  playMode = AudioManager.instance.nextMode();
                  setState(() {});
                }),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.previous()),
            IconButton(
              onPressed: () async {
                bool playing = await AudioManager.instance.playOrPause();
                print("await -- $playing");
              },
              padding: const EdgeInsets.all(0.0),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: Colors.black,
              ),
            ),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.next()),
            IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.stop()),
          ],
        ),
      ),
    ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.black,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.black,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.black,
        );
    }
    return Container();
  }




  void _settingModalBottomSheet(context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          /*  return Container(
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0))),
        child: new Wrap(
          children: <Widget>[
            new ListTile(leading: new Icon(Icons.pets,), title: Text("Mascotas"),),
            new ListTile(leading: new Icon(Icons.home,), title: Text("Casas"),),
            new ListTile(leading: new Icon(Icons.fastfood), title: Text("Comidas"),)
          ],),);*/

          return new Container(
            color: Colors.transparent,
            //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: new Wrap(
                children: <Widget>[
                  StreamBuilder<Chapters>(
                    initialData: store.selectedChapter$.value,
                    stream: store.selectedChapter$,
                    builder: (BuildContext context,
                        AsyncSnapshot<Chapters> snapshot) {
                      var selectedChapter = snapshot.data;
                      if (selectedChapter == null) {
                        return Container();
                      }
                      var item = store.listAya[index];
                      item.getTranslations.execute();
                      item.getBookmark.execute();

                      var aya = item.aya.value;

                      return new Center(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.only(top: 20.0),
                            ),
                            new Text(
                              ' QS. ${selectedChapter.nameSimple} : Ayat ${aya.index}',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  //  new Padding(
                  //   padding: EdgeInsets.only(top: 80.0),
                  // ),
                  new Padding(
                    padding: EdgeInsets.only(top: 80.0),
                  ),
                  new ListTile(
                      leading: new Icon(
                        FontAwesomeIcons.play,
                        color: Colors.black,
                        size: 18,
                      ),
                      title: Text(
                        "Play",
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: () => bottomPanel(),
                  ),
                  new Wrap(
                    children: <Widget>[
                      StreamBuilder<Chapters>(
                        initialData: store.selectedChapter$.value,
                        stream: store.selectedChapter$,
                        builder: (BuildContext context,
                            AsyncSnapshot<Chapters> snapshot) {
                          var selectedChapter = snapshot.data;
                          if (selectedChapter == null) {
                            return Container();
                          }

                          var item = store.listAya[index];
                          item.getTranslations.execute();
                          item.getBookmark.execute();

                          var aya = item.aya.value;

                          return Builder(
                            builder: (
                              BuildContext context,
                            ) {
                              return StreamBuilder<DataState>(
                                initialData: item.translationState.value,
                                stream: item.translationState.delay(
                                  const Duration(
                                    milliseconds: 1,
                                  ),
                                ),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<DataState> snapshot,
                                ) {
                                  return WidgetSelector(
                                    selectedState: snapshot.data,
                                    states: {
                                      DataState(
                                        enumSelector: EnumSelector.loading,
                                      ): Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      DataState(
                                        enumSelector: EnumSelector.success,
                                      ): Builder(
                                        builder: (BuildContext context) {
                                          return StreamBuilder<
                                              List<
                                                  Tuple2<Aya,
                                                      TranslationData>>>(
                                            initialData:
                                                item.translations.value,
                                            stream: item.translations.delay(
                                              const Duration(),
                                            ),
                                            builder: (
                                              BuildContext context,
                                              AsyncSnapshot<
                                                      List<
                                                          Tuple2<Aya,
                                                              TranslationData>>>
                                                  snapshot,
                                            ) {
                                              List<Widget>
                                                  listTranslationWidget = [];
                                              for (var item in snapshot.data) {
                                                var translation = item.item1;
                                                var translationData =
                                                    item.item2;
                                                listTranslationWidget
                                                    .add(Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    SizedBox.fromSize(
                                                      size: Size.fromHeight(5),
                                                    ),
                                                    SizedBox.fromSize(
                                                      size: Size.fromHeight(1),
                                                    ),
                                                    Container(
                                                      child:
                                                          StreamBuilder<double>(
                                                        initialData: store
                                                                .translationFontSize$
                                                                .value ??
                                                            18,
                                                        stream: store
                                                            .translationFontSize$,
                                                        builder: (
                                                          BuildContext context,
                                                          AsyncSnapshot<double>
                                                              snapshot,
                                                        ) {
                                                          return new ListTile(
                                                            leading: new Icon(
                                                              FontAwesomeIcons
                                                                  .shareAlt,
                                                              color:
                                                                  Colors.black,
                                                              size: 20,
                                                            ),
                                                            title: Text(
                                                              "Bagikan Ayat",
                                                              style: TextStyle(
                                                                  fontSize: 15),
                                                            ),
                                                            onTap: () {
                                                              final RenderBox
                                                                  box = context
                                                                      .findRenderObject();
                                                              Share.share(
                                                                  "${aya.text} \n ${translation.text} \n "
                                                                  "(QS. ${selectedChapter.nameSimple} : Ayat ${aya.index})",
                                                                  subject:
                                                                      "Allah SWT Berfirman :",
                                                                  sharePositionOrigin:
                                                                      box.localToGlobal(
                                                                              Offset.zero) &
                                                                          box.size);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              }
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                mainAxisSize: MainAxisSize.min,
                                                children: listTranslationWidget,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  new Wrap(
                    children: <Widget>[
                      StreamBuilder<Chapters>(
                        initialData: store.selectedChapter$.value,
                        stream: store.selectedChapter$,
                        builder: (BuildContext context,
                            AsyncSnapshot<Chapters> snapshot) {
                          var selectedChapter = snapshot.data;
                          if (selectedChapter == null) {
                            return Container();
                          }

                          var item = store.listAya[index];
                          item.getTranslations.execute();
                          item.getBookmark.execute();

                          var aya = item.aya.value;

                          return Builder(
                            builder: (
                              BuildContext context,
                            ) {
                              return StreamBuilder<DataState>(
                                initialData: item.translationState.value,
                                stream: item.translationState.delay(
                                  const Duration(
                                    milliseconds: 1,
                                  ),
                                ),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<DataState> snapshot,
                                ) {
                                  return WidgetSelector(
                                    selectedState: snapshot.data,
                                    states: {
                                      DataState(
                                        enumSelector: EnumSelector.loading,
                                      ): Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      DataState(
                                        enumSelector: EnumSelector.success,
                                      ): Builder(
                                        builder: (BuildContext context) {
                                          return StreamBuilder<
                                              List<
                                                  Tuple2<Aya,
                                                      TranslationData>>>(
                                            initialData:
                                                item.translations.value,
                                            stream: item.translations.delay(
                                              const Duration(),
                                            ),
                                            builder: (
                                              BuildContext context,
                                              AsyncSnapshot<
                                                      List<
                                                          Tuple2<Aya,
                                                              TranslationData>>>
                                                  snapshot,
                                            ) {
                                              List<Widget>
                                                  listTranslationWidget = [];
                                              for (var item in snapshot.data) {
                                                var translation = item.item1;
                                                var translationData =
                                                    item.item2;
                                                listTranslationWidget
                                                    .add(Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    SizedBox.fromSize(
                                                      size: Size.fromHeight(5),
                                                    ),
                                                    SizedBox.fromSize(
                                                      size: Size.fromHeight(1),
                                                    ),
                                                    Container(
                                                      child:
                                                          StreamBuilder<double>(
                                                        initialData: store
                                                                .translationFontSize$
                                                                .value ??
                                                            18,
                                                        stream: store
                                                            .translationFontSize$,
                                                        builder: (
                                                          BuildContext context,
                                                          AsyncSnapshot<double>
                                                              snapshot,
                                                        ) {
                                                          return new ListTile(
                                                              leading: new Icon(
                                                                FontAwesomeIcons
                                                                    .copy,
                                                                color: Colors
                                                                    .black,
                                                                size: 20,
                                                              ),
                                                              title: Text(
                                                                "Salin Ayat",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                              onTap: () async {
                                                                SocialShare
                                                                    .copyToClipboard(
                                                                  "${aya.text} \n ${translation.text} \n "
                                                                  "(QS. ${selectedChapter.nameSimple} : Ayat ${aya.index})",
                                                                ).then((data) {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "QS. ${selectedChapter.nameSimple} : Ayat ${aya.index} berhasil disalin",
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT,
                                                                      gravity: ToastGravity
                                                                          .CENTER,
                                                                      timeInSecForIosWeb:
                                                                          1,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .teal,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      fontSize:
                                                                          16.0);
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              }
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                mainAxisSize: MainAxisSize.min,
                                                children: listTranslationWidget,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  //new ListTile(leading: new Icon(
                  // FontAwesomeIcons.fileAlt, color: Colors.black, size: 20,),
                  // title: Text("Tambah ke Bookmark",style: TextStyle(fontSize: 15),),),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: const Color(0xff14d2b8),
        title: InkWell(
          onTap: () {
            store.pickQuranNavigator.executeIf();
          },
          child: Container(
            alignment: Alignment.centerLeft,
            child: Row(
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
                      '${selectedChapter.chapterNumber}. ${selectedChapter.nameSimple}',
                    );
                  },
                ),
                Icon(
                  Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              {
                var d = store.showSettingsInteraction.registerHandler((_) {
                  Scaffold.of(context).openEndDrawer();
                  return Future.value();
                });
                _store.registerDispose(() {
                  d.dispose();
                });
              }

              return IconButton(
                onPressed: () {
                  _store.showSettings.executeIf();
                },
                icon: Icon(Icons.settings),
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        // Defer the drawer until drawer opened
        child: Builder(
          builder: (BuildContext context) {
            return QuranSettingsWidget(
              store: QuranSettingsStore(
                parameter: store.settingsParameter,
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<DataState>(
        initialData: store.state$.value,
        stream: store.state$,
        builder: (
          BuildContext context,
          AsyncSnapshot<DataState> snapshot,
        ) {
          return WidgetSelector<DataState>(
            selectedState: snapshot.data,
            states: {
              DataState(
                enumSelector: EnumSelector.success,
              ): Container(
                child: Observer(
                  builder: (BuildContext context) {
                    var itemIndex = store.listAya.indexWhere(
                      (t) => t.aya.value == store.initialSelectedAya$.value,
                    );
                    // https://github.com/google/flutter.widgets/issues/24

                    return Scrollbar(
                      child: ScrollablePositionedList.builder(
                        itemCount: store.listAya.length,
                        initialScrollIndex: itemIndex >= 0 ? itemIndex : 0,
                        addAutomaticKeepAlives: true,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                        ) {
                          if (store.listAya.isEmpty) {
                            return Container();
                          }

                          var item = store.listAya[index];
                          item.getTranslations.execute();
                          item.getBookmark.execute();

                          var aya = item.aya.value;


                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    top: 15,
                                    right: 20,
                                    bottom: 25,
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          // Bismillah
                                          // !isBlank('aya.bismillah')
                                          !isBlank('')
                                              ? Container(
                                                  padding: EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 25,
                                                  ),
                                                  child: Text(
                                                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          // 1
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Row(
                                                  children: <Widget>[
                                                    SizedBox.fromSize(
                                                      size: Size(50.0, 50.0),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'assets/images/count_surah.png')),
                                                        ),
                                                        child: Text(
                                                            '${aya.indexString}',
                                                            style: GoogleFonts
                                                                .sourceSansPro(
                                                                    color: Colors
                                                                        .teal,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                      ),
                                                    ),
                                                    // Bookmarks
                                                    StreamBuilder<bool>(
                                                      initialData: item
                                                          .isBookmarked.value,
                                                      stream: item.isBookmarked,
                                                      builder: (
                                                        BuildContext context,
                                                        AsyncSnapshot snapshot,
                                                      ) {
                                                        var isBookmarked = item
                                                            .isBookmarked.value;
                                                        // final int _itemLength = snapshot.data.isBookmarked[index].length;
                                                       // List<bool> _isFavorited = List<bool>.generate(_itemLength.h, (_) => false);
                                                        return Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            isBookmarked
                                                                ? Builder(
                                                                    builder: (
                                                                      BuildContext
                                                                          context,
                                                                    ) {
                                                                      return Animator<
                                                                          double>(
                                                                        duration:
                                                                            const Duration(
                                                                          milliseconds:
                                                                              100,
                                                                        ),
                                                                        builder:
                                                                            (v) {
                                                                          return Transform
                                                                              .scale(
                                                                            scale:
                                                                                v.value,
                                                                            child:
                                                                                IconButton(
                                                                              icon: Icon(
                                                                                Icons.bookmark,
                                                                                color: Theme.of(context).accentColor,
                                                                              ),
                                                                              onPressed: () {
                                                                                store.bookmarkActionType.add(
                                                                                  Tuple3(QuranBookmarkButtonMode.remove, item, item.quranBookmark),
                                                                                );
                                                                              },
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                  )
                                                                : Animator<
                                                                    double>(
                                                                    duration:
                                                                        const Duration(
                                                                      milliseconds:
                                                                          100,
                                                                    ),
                                                                    builder:
                                                                        (v) {
                                                                      return Transform
                                                                          .scale(
                                                                        scale: v
                                                                            .value,
                                                                        child:
                                                                            IconButton(
                                                                          icon: Icon(
                                                                            Icons.bookmark_border,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            store.bookmarkActionType.add(
                                                                              Tuple3(QuranBookmarkButtonMode.add, item, null),
                                                                            );
                                                                          //  setState(()
                                                                             // => _isFavorited[index] = !_isFavorited[index]);
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                  ),
                                                  onPressed: () {
                                                    _settingModalBottomSheet(
                                                        context, index);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox.fromSize(
                                            size: Size.fromHeight(
                                              15,
                                            ),
                                          ),
                                          // 2
                                          StreamBuilder<double>(
                                            initialData:
                                                store.arabicFontSize$.value,
                                            stream: store.arabicFontSize$,
                                            builder: (
                                              BuildContext context,
                                              AsyncSnapshot<double> snapshot,
                                            ) {
                                              return Text(
                                                '${aya.text}',
                                                textDirection:
                                                    TextDirection.rtl,
                                                style: TextStyle(
                                                  fontSize: snapshot.data,
                                                  fontFamily:
                                                      'KFGQPC Uthman Taha Naskh',
                                                ),
                                              );
                                            },
                                          ),
                                        ]..add(
                                            Builder(
                                              builder: (
                                                BuildContext context,
                                              ) {
                                                return StreamBuilder<DataState>(
                                                  initialData: item
                                                      .translationState.value,
                                                  stream: item.translationState
                                                      .delay(
                                                    const Duration(
                                                      milliseconds: 500,
                                                    ),
                                                  ),
                                                  builder: (
                                                    BuildContext context,
                                                    AsyncSnapshot<DataState>
                                                        snapshot,
                                                  ) {
                                                    return WidgetSelector(
                                                      selectedState:
                                                          snapshot.data,
                                                      states: {
                                                        DataState(
                                                          enumSelector:
                                                              EnumSelector
                                                                  .loading,
                                                        ): Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                        DataState(
                                                          enumSelector:
                                                              EnumSelector
                                                                  .success,
                                                        ): Builder(
                                                          builder: (BuildContext
                                                              context) {
                                                            return StreamBuilder<
                                                                List<
                                                                    Tuple2<Aya,
                                                                        TranslationData>>>(
                                                              initialData: item
                                                                  .translations
                                                                  .value,
                                                              stream: item
                                                                  .translations
                                                                  .delay(
                                                                const Duration(
                                                                  milliseconds:
                                                                      500,
                                                                ),
                                                              ),
                                                              builder: (
                                                                BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        List<
                                                                            Tuple2<Aya,
                                                                                TranslationData>>>
                                                                    snapshot,
                                                              ) {
                                                                List<Widget>
                                                                    listTranslationWidget =
                                                                    [];
                                                                for (var item
                                                                    in snapshot
                                                                        .data) {
                                                                  var translation =
                                                                      item.item1;
                                                                  var translationData =
                                                                      item.item2;
                                                                  listTranslationWidget
                                                                      .add(
                                                                          Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox
                                                                          .fromSize(
                                                                        size: Size.fromHeight(
                                                                            10),
                                                                      ),
                                                                      SizedBox
                                                                          .fromSize(
                                                                        size: Size
                                                                            .fromHeight(1),
                                                                      ),
                                                                      Container(
                                                                        child: StreamBuilder<
                                                                            double>(
                                                                          initialData:
                                                                              store.translationFontSize$.value ?? 18,
                                                                          stream:
                                                                              store.translationFontSize$,
                                                                          builder:
                                                                              (
                                                                            BuildContext
                                                                                context,
                                                                            AsyncSnapshot<double>
                                                                                snapshot,
                                                                          ) {
                                                                            return Text(
                                                                              '${translation.text}',
                                                                              style: TextStyle(
                                                                                fontSize: snapshot.data,
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ));
                                                                }

                                                                return Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children:
                                                                      listTranslationWidget,
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              DataState(
                enumSelector: EnumSelector.loading,
              ): ScrollablePositionedList.builder(
                itemCount: 10,
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  return InkWell(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 15,
                        top: 15,
                        right: 20,
                        bottom: 25,
                      ),
                      child: Stack(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // 1
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        ShimmerLoading(
                                          height: 30,
                                        ),
                                        ShimmerLoading(
                                          height: 24,
                                          width: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ShimmerLoading(
                                    height: 24,
                                    width: 16,
                                  ),
                                ],
                              ),
                              SizedBox.fromSize(
                                size: Size.fromHeight(
                                  14,
                                ),
                              ),
                              // 2
                              ShimmerLoading(
                                height: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            },
          );
        },
      ),
    );
  }
}
