import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_data.freezed.dart';
part 'home_data.g.dart';

enum HomeTab { home, history, profile }

@freezed
abstract class HomeData with _$HomeData {
  const factory HomeData({@Default(HomeTab.home) HomeTab currentTab}) =
      _HomeData;

  factory HomeData.fromJson(Map<String, dynamic> json) =>
      _$HomeDataFromJson(json);
}
