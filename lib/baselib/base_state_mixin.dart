import 'package:flutter/widgets.dart';

import 'base_store.dart';

mixin BaseStateMixin<TStore extends BaseStore, T extends StatefulWidget>
    on State<T> {
  TStore get store;
  final _parameter = Map<String, Object>();
  Map<String, Object> get parameter => _parameter;
  @override
  void dispose() {
    store?.dispose();

    super.dispose();
  }
}
