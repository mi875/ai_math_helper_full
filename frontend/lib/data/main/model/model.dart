import 'package:ai_math_helper/data/main/data/data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model.g.dart';

@riverpod
class MainModel extends _$MainModel {
  @override
  MainData build() {
    return MainData(count: 0);
  }

  void increment() {
    state = state.copyWith(count: state.count + 1);
  }
}
