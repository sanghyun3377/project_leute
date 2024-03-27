import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:leute/di/di_setup.dart';
import 'package:leute/router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';

const Map<String, String> UNIT_ID = kReleaseMode
    ? {
  'ios': '[YOUR iOS AD UNIT ID]',
  'android': '[YOUR ANDROID AD UNIT ID]',
}
    : {
  'ios': 'ca-app-pub-3940256099942544/2934735716',
  'android': 'ca-app-pub-3940256099942544/6300978111',
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Always initialize Awesome Notifications
  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();
  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  diSetup();
  runApp(const MyApp());
}

///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************
///
class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);
    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;

  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      debugPrint(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need                                                                                                                   redirect the execution to main isolate
      if (receivePort == null) {
        debugPrint(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          debugPrint('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
        (route) =>
            (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/refrigerator.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************
  static Future<void> executeLongTaskInBackground() async {
    debugPrint("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    debugPrint(re.body);
    debugPrint("long task done");
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************

  static Future<void> scheduleNewNotification(
      int dayFromNow, String refrigeName, String userName) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await myNotifyScheduleInDays(
        title: '보관음식 중 곧 폐기될 음식이 있습니다!',
        msg: '음식을 비워주세요.',
        daysFromNow: dayFromNow,
        refrigeName: refrigeName,
        username: userName,
        repeatNotif: true);

    debugPrint('푸시알림 정상등록');
  }

  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1,
            // -1 is replaced by a random number
            channelKey: 'alerts',
            title: '보관음식 중 곧 폐기될 음식이 있습니다!',
            body: '음식을 비워주세요',
            bigPicture:
                'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.Messaging,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

// static Future<void> resetBadgeCounter() async {
//   await AwesomeNotifications().resetGlobalBadge();
// }
//
// static Future<void> cancelNotifications() async {
//   await AwesomeNotifications().cancelAll();
// }
}

Future<void> myNotifyScheduleInDays({
  required int daysFromNow,
  required String username,
  required String refrigeName,
  required String title,
  required String msg,
  bool repeatNotif = false,
}) async {
  var nowDate = DateTime.now().add(Duration(days: daysFromNow, seconds: 5));
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar(
      preciseAlarm: true,
      //weekday: nowDate.day,
      day: nowDate.day,
      minute: 5,
      second: nowDate.second,
      //allowWhileIdle: true,
    ),
    // schedule: NotificationCalendar.fromDate(
    //    date: DateTime.now().add(const Duration(seconds: 10))),
    content: NotificationContent(
      id: -1,
      channelKey: 'alerts',
      wakeUpScreen: true,
      category: NotificationCategory.Reminder,
      title: '${Emojis.food_bowl_with_spoon} $refrigeName에 $title',
      body: '$username 님, $msg',
      largeIcon: 'asset://assets/images/lemon.png',
      roundedLargeIcon: true,
      autoDismissible: false,
      notificationLayout: NotificationLayout.BigPicture,
      //actionType : ActionType.DismissAction,
      color: Colors.black,
      backgroundColor: Colors.black,
      // customSound: 'resource://raw/notif',
      payload: {'actPag': 'myAct', 'actType': 'food', 'username': username},
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'NOW',
        label: '확인',
      ),
      // NotificationActionButton(
      //   key: 'LATER',
      //   label: 'btnAct2',
      // ),
    ],
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Color mainColor = const Color(0xFF9D50DD);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // static const String routeHome = '/splash_page', routeNotification = '/notification-page';

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Tmoney',
// useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF325c6a)),
        ),
        routerConfig: router,
      ),
    );
  }
}




///  *********************************************
///     NOTIFICATION PAGE
///  *********************************************
class NotificationPage extends StatefulWidget {
  const NotificationPage({
    Key? key,
    required this.receivedAction,
  }) : super(key: key);

  final ReceivedAction receivedAction;

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  bool get hasTitle => widget.receivedAction.title?.isNotEmpty ?? false;
  bool get hasBody => widget.receivedAction.body?.isNotEmpty ?? false;
  bool get hasLargeIcon => widget.receivedAction.largeIconImage != null;
  bool get hasBigPicture => widget.receivedAction.bigPictureImage != null;

  double bigPictureSize = 0.0;
  double largeIconSize = 0.0;
  bool isTotallyCollapsed = false;
  bool bigPictureIsPredominantlyWhite = true;

  ScrollController scrollController = ScrollController();

  Future<bool> isImagePredominantlyWhite(ImageProvider imageProvider) async {
    final paletteGenerator =
    await PaletteGenerator.fromImageProvider(imageProvider);
    final dominantColor =
        paletteGenerator.dominantColor?.color ?? Colors.transparent;
    return dominantColor.computeLuminance() > 0.5;
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);

    if (hasBigPicture) {
      isImagePredominantlyWhite(widget.receivedAction.bigPictureImage!)
          .then((isPredominantlyWhite) => setState(() {
        bigPictureIsPredominantlyWhite = isPredominantlyWhite;
      }));
    }
  }

  void _scrollListener() {
    bool pastScrollLimit = scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 240;

    if (!hasBigPicture) {
      isTotallyCollapsed = true;
      return;
    }

    if (isTotallyCollapsed) {
      if (!pastScrollLimit) {
        setState(() {
          isTotallyCollapsed = false;
        });
      }
    } else {
      if (pastScrollLimit) {
        setState(() {
          isTotallyCollapsed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bigPictureSize = MediaQuery.of(context).size.height * .4;
    largeIconSize =
        MediaQuery.of(context).size.height * (hasBigPicture ? .16 : .2);

    if (!hasBigPicture) {
      isTotallyCollapsed = true;
    }

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isTotallyCollapsed || bigPictureIsPredominantlyWhite
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            systemOverlayStyle:
            isTotallyCollapsed || bigPictureIsPredominantlyWhite
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
            expandedHeight: hasBigPicture
                ? bigPictureSize + (hasLargeIcon ? 40 : 0)
                : (hasLargeIcon)
                ? largeIconSize + 10
                : MediaQuery.of(context).padding.top + 28,
            backgroundColor: Colors.transparent,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              centerTitle: true,
              expandedTitleScale: 1,
              collapseMode: CollapseMode.pin,
              title: (!hasLargeIcon)
                  ? null
                  : Stack(children: [
                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: hasBigPicture
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: largeIconSize,
                        width: largeIconSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(largeIconSize)),
                          child: FadeInImage(
                            placeholder: const NetworkImage(
                                'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
                            image: widget.receivedAction.largeIconImage!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              background: hasBigPicture
                  ? Padding(
                padding: EdgeInsets.only(bottom: hasLargeIcon ? 60 : 20),
                child: FadeInImage(
                  placeholder: const NetworkImage(
                      'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
                  height: bigPictureSize,
                  width: MediaQuery.of(context).size.width,
                  image: widget.receivedAction.bigPictureImage!,
                  fit: BoxFit.fill,
                ),
              )
                  : null,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding:
                  const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          if (hasTitle)
                            TextSpan(
                              text: widget.receivedAction.title!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          if (hasBody)
                            WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: hasTitle ? 16.0 : 0.0,
                                ),
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                        widget.receivedAction.bodyWithoutHtml ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium)),
                              ),
                            ),
                        ]),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black12,
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  child: Text(widget.receivedAction.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
