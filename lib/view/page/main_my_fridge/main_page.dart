import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leute/di/di_setup.dart';
import 'package:leute/styles/app_text_style.dart';
import 'package:leute/view/page/main_my_fridge/main_screen_view_model.dart';
import 'package:leute/view/page/main_my_fridge/my_fridge_view_model.dart';
import 'package:leute/view/page/my_page/my_page.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import '../../../main.dart';
import 'main_screen.dart';
import 'my_fridge.dart';

class MainPage extends StatefulWidget {
  int currentPageIndex;

  MainPage({
    super.key,
    required this.currentPageIndex,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Widget> _pages = <Widget>[
    ChangeNotifierProvider(
      create: (_) => getIt<MainScreenViewModel>(),
      child: const MainScreen(),
    ),
    ChangeNotifierProvider(
      create: (_) => getIt<MyFridgeViewModel>(),
      child: const MyFridge(),
    ),
    const MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    TargetPlatform os = Theme.of(context).platform;

    BannerAd banner = BannerAd(
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        onAdLoaded: (_) {},
      ),
      size: AdSize.banner,
      adUnitId: UNIT_ID[os == TargetPlatform.iOS ? 'ios' : 'android']!,
      request: AdRequest(),
    )..load();
    return Scaffold(
      body: _pages[widget.currentPageIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurvedNavigationBar(
            animationCurve: Curves.easeInOutExpo,
            index: widget.currentPageIndex,
            backgroundColor: Colors.white,
            color: const Color(0xFF9bc6bf),
            onTap: (int index) {
              setState(() {
                widget.currentPageIndex = index;
              });
            },
            items: <Widget>[
              const Icon(Icons.kitchen_outlined,
                  color: Colors.white, semanticLabel: '냉장고', size: 30),
              Text(
                'My',
                style: AppTextStyle.header22(color: Colors.white),
              ),
              const Icon(UniconsLine.user,
                  color: Colors.white, semanticLabel: '마이페이지', size: 30),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: AdWidget(
              ad: banner,
            ),
          ),
        ],
      ),
    );
  }
}
