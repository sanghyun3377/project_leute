import 'package:leute/data/models/foods_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_food_detail_state.freezed.dart';
part 'my_food_detail_state.g.dart';


@freezed
class MyFoodDetailState with _$MyFoodDetailState {
  factory MyFoodDetailState(List<FoodDetail> foodDetails,
      int remainPeriod,
      bool isOld,) = _MyFoodDetailState;

  factory MyFoodDetailState.fromJson(Map<String, Object?> json)
  => _$MyFoodDetailStateFromJson(json);

  }
