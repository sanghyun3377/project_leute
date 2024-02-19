import 'package:get_it/get_it.dart';
import 'package:leute/view/page/register_page/register_view_model.dart';
import 'package:leute/view/page/main_my_fridge/main_screen_view_model.dart';
import 'package:leute/view/page/main_my_fridge/my_fridge_view_model.dart';
import 'package:leute/view/page/my_food_detail_page/my_food_detail_view_model.dart';

import '../data/repository/foods_repository_impl.dart';
import '../data/repository/refrige_repository_impl.dart';
import '../data/repository/user_data_repository_impl.dart';
import '../domain/foods_repository.dart';
import '../domain/refrige_repository.dart';
import '../domain/user_data_repository.dart';
import '../view/page/discard_foods_page/discard_foods_view_model.dart';
import '../view/page/group_setting_page/group_setting_page_view_model.dart';
import '../view/page/refrige_detail_page/freezer_comp_view_model.dart';
import '../view/page/refrige_detail_page/refrige_comp_view_model.dart';
import '../view/page/refrige_pages/add_page_view_model.dart';

final getIt = GetIt.instance;

void diSetup() {
  getIt.registerSingleton<RegisterdFoodsRepository>(
      RegisterdFoodsRepositoryImpl());
  getIt.registerSingleton<RegisterdRefrigeRepository>(
      RegisterdRefrigeRepositoryImpl());
  getIt.registerSingleton<UserDataRepository>(UserDataRepositoryImpl());

  getIt.registerFactory<DiscardFoodsViewModel>(() => DiscardFoodsViewModel(
      foodRepository: getIt<RegisterdFoodsRepository>(),
      refrigeRepository: getIt<RegisterdRefrigeRepository>()));

  getIt.registerFactory<GroupSettingPageViewModel>(() =>
      GroupSettingPageViewModel(
          userDataRepository: getIt<UserDataRepository>()));

  getIt.registerFactory<FreezerCompViewModel>(() => FreezerCompViewModel(
      foodsRepository: getIt<RegisterdFoodsRepository>(),
      userDataRepository: getIt<UserDataRepository>()));
  getIt.registerFactory<RefrigeCompViewModel>(() => RefrigeCompViewModel(
      foodsRepository: getIt<RegisterdFoodsRepository>(),
      userDataRepository: getIt<UserDataRepository>()));
  getIt.registerFactory<MyFoodDetailViewModel>(() => MyFoodDetailViewModel(
      foodsRepository: getIt<RegisterdFoodsRepository>()));

  getIt.registerFactory<MainScreenViewModel>(() =>
      MainScreenViewModel(userDataRepository: getIt<UserDataRepository>()));

  getIt.registerFactory<MyFridgeViewModel>(() => MyFridgeViewModel(
      userDataRepository: getIt<UserDataRepository>(),
      foodRepository: getIt<RegisterdFoodsRepository>(),
      refrigeRepository: getIt<RegisterdRefrigeRepository>()));

  getIt.registerFactory<RegisterViewModel>(() => RegisterViewModel(
      foodsRepository: getIt<RegisterdFoodsRepository>(),
      userDataRepository: getIt<UserDataRepository>()));
  getIt.registerFactory<AddPageViewModel>(() => AddPageViewModel());
}
