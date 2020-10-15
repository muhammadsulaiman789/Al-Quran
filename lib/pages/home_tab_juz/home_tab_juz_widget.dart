import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:quran_app/app_widgets/shimmer_loading.dart';
import 'package:quran_app/baselib/base_state_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/baselib/widgets.dart';
import 'package:quran_app/models/models.dart';

import 'home_tab_juz_store.dart';

class HomeTabJuzWidget extends StatefulWidget {
  HomeTabJuzWidget({Key key}) : super(key: key);

  _HomeTabJuzWidgetState createState() => _HomeTabJuzWidgetState();
}

class _HomeTabJuzWidgetState extends State<HomeTabJuzWidget>
    with
        AutomaticKeepAliveClientMixin,
        BaseStateMixin<HomeTabJuzStore, HomeTabJuzWidget> {
  final _store = HomeTabJuzStore();
  @override
  HomeTabJuzStore get store => _store;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.getListJuz.executeIf();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
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
              ): Observer(
                builder: (BuildContext context) {
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(color: Colors.black, );
                    },
                    itemCount: store.listJuz.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      var item = store.listJuz[index];
                      var verseMapping =
                          JuzItem.getVerseMappingJuzItem(item.verseMapping);
                      print('juz: $verseMapping');
                      return ListTile(
                        onTap: () {
                          store.juzItemTapped.executeIf(item);
                        },
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox.fromSize(
                              size: Size(52.0, 52.0),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/images/count_surah.png')),
                                ),
                                child: Text('${item.id}',
                                    style: GoogleFonts.sourceSansPro(color: Colors.teal,fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),

                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              '${store.localization.getByKey('home_tab_juz.juz')} ${item.juzNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Dimulai dari ${item.chapters.nameSimple} Ayat ${verseMapping.first.startAya}', style: GoogleFonts.sourceSansPro(color: const Color(0xffb3b33b),),
                            ),
                          ],
                        ),
                      );
                    },
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
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ShimmerLoading(
                          height: 10,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerLoading(
                          height: 10,
                        ),
                      ],
                    ),
                    trailing: Container(
                      width: 175,
                      child: ShimmerLoading(
                        height: 20,
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
