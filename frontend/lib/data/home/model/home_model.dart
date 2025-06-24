import 'package:ai_math_helper/data/home/data/home_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_model.g.dart';

@riverpod
class HomeModel extends _$HomeModel {
  @override
  HomeData build() {
    return HomeData(currentTab: HomeTab.home);
  }

  void changeTab(HomeTab tab) {
    state = state.copyWith(currentTab: tab);
  }
}
