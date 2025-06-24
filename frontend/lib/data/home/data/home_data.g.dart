// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeData _$HomeDataFromJson(Map<String, dynamic> json) => _HomeData(
  currentTab:
      $enumDecodeNullable(_$HomeTabEnumMap, json['currentTab']) ?? HomeTab.home,
);

Map<String, dynamic> _$HomeDataToJson(_HomeData instance) => <String, dynamic>{
  'currentTab': _$HomeTabEnumMap[instance.currentTab]!,
};

const _$HomeTabEnumMap = {
  HomeTab.home: 'home',
  HomeTab.history: 'history',
  HomeTab.profile: 'profile',
};
