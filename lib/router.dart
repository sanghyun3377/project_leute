import 'package:go_router/go_router.dart';
import 'package:leute/data/models/user_model.dart';
import 'package:leute/view/page/discard_foods_page/discard_food_detail_page.dart';
import 'package:leute/view/page/discard_foods_page/discard_foods_page.dart';
import 'package:leute/view/page/change_password_page/change_password_page.dart';
import 'package:leute/view/page/discard_foods_page/discard_foods_view_model.dart';
import 'package:leute/view/page/group_setting_page/group_setting_page.dart';
import 'package:leute/view/page/login_page/login_page.dart';
import 'package:leute/view/page/password_reset_page/password_reset_page.dart';
import 'package:leute/view/page/signup_page/signup_page.dart';
import 'package:leute/view/page/main_my_fridge/main_page.dart';
import 'package:leute/view/page/my_food_detail_page/my_food_detail_page.dart';
import 'package:leute/view/page/refrige_detail_page/refrige_detail_screen.dart';
import 'package:leute/view/page/register_page/register_page.dart';
import 'package:leute/view/page/group_setting_page/group_setting_page_view_model.dart';
import 'package:leute/view/page/login_page/login_page_view_model.dart';
import 'package:leute/view/page/my_page/my_page_view_model.dart';
import 'package:leute/view/page/signup_page/signup_page_view_model.dart';
import 'package:provider/provider.dart';

import 'di/di_setup.dart';
import 'view/page/refrige_pages/add_page_view_model.dart';
import 'view/page/refrige_pages/add_refrige.dart';
import 'view/page/refrige_pages/edit_refrige.dart';
import 'view/page/register_page/register_view_model.dart';
import 'view/page/splash_page/splash_page.dart';

import 'view/page/my_food_detail_page/my_food_detail_view_model.dart';

final router = GoRouter(initialLocation: '/splash_page', routes: [
  GoRoute(
      path: '/main_page',
      builder: (context, state) => ChangeNotifierProvider(
          create: (_) => MyPageViewModel(),
          child: MainPage(currentPageIndex: state.extra as int))),

  // 나의음식 상세 페이지
  GoRoute(
      path: '/myfooddetail',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => getIt<MyFoodDetailViewModel>(),
          child: MyFoodDetail(
            myFoodItem: (state.extra as List)[0],
            ourRefrigItem: (state.extra as List)[1],
          ),
        );
      }),

  //로그인 페이지
  GoRoute(
      path: '/login',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => LoginPageViewModel(),
          child: const LoginPage(),
        );
      }),

  // 회원가입 페이지
  GoRoute(
      path: '/signup',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => SignupPageViewModel(),
          child: const SignupPage(),
        );
      }),

  // 비밀번호 찾기 페이지
  GoRoute(
      path: '/passwordReset',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => LoginPageViewModel(),
          child: const PasswordResetPage(),
        );
      }),

  // 그룹관리 페이지
  GoRoute(
      path: '/groupSetting',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => getIt<GroupSettingPageViewModel>(),
          child: GroupSettingPage(thisGroupName: state.extra as String,),
        );
      }),

  // 냉장고 상세 페이지
  GoRoute(
    path: '/details',
    builder: (context, state) => RefrigeDetailScreen(
      selectedRefrige: (state.extra as List)[0],
      selectedIndex: (state.extra as List)[1],
    ),
  ),

  // 스플래쉬 페이지
  GoRoute(
    path: '/splash_page',
    builder: (context, state) {
      return ChangeNotifierProvider(
        create: (_) => LoginPageViewModel(),
        child: const SplashScreen(),
      );
    },
  ),

  //냉장고 추가 페이지
  GoRoute(
    path: '/addRefrige',
    builder: (context, state) {
      return ChangeNotifierProvider(
        create: (_) => getIt<AddPageViewModel>(),
        child: AddRefrige(
          currentUser: state.extra as UserModel,
        ),
      );
    },
  ),

  // 냉장고 수정페이지
  GoRoute(
    path: '/editRefrige',
    builder: (context, state) {
      return ChangeNotifierProvider(
        create: (_) => getIt<AddPageViewModel>(),
        child: EditRefrige(
          seletedRefrige: (state.extra as List)[0],
          currentUser: (state.extra as List)[1],
        ),
      );
    },
  ),

  // 음식 추가페이지
  GoRoute(
      path: '/addMyFood',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => getIt<RegisterViewModel>(),
          child: RegisterPage(fridgeData: state.extra as List<Object>),
        );
      }),

  // 폐기할 음식 페이지
  GoRoute(
      path: '/discardPage',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => getIt<DiscardFoodsViewModel>(),
          child: const DiscardFoods(),
        );
      }),

  // 폐기 음식 상세 페이지
  GoRoute(
      path: '/discardFoodDetail',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => MyFoodDetailViewModel(),
          child: DiscardFoodDetail(
            myFoodItem: (state.extra as List)[0],
            ourRefrigItem: (state.extra as List)[1],
          ),
        );
      }),

  // 비밀번호 변경 페이지
  GoRoute(
    path: '/changePassword',
    builder: (context, state) {
      return ChangeNotifierProvider(
        create: (_) => LoginPageViewModel(),
        child: const ChangePasswordPage(),
      );
    },
  ),
]);
