import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 6)).then((value) {
      GoRouter.of(context).go('/login');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 4),
          opacity: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/cut_refrigerator.gif',
                height: 200.h,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              SizedBox(height: 20.h),
              // Text(
              //   'UriBingo',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 25.sp,
              //     fontWeight: FontWeight.bold,
              //     color: const Color(0xFFFFB500),
              //     letterSpacing: 3.sp,
              //     shadows: [
              //       Shadow(
              //         color: Colors.black.withOpacity(0.1),
              //         offset: const Offset(2.0, 1.0),
              //         blurRadius: 4.0.r,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
