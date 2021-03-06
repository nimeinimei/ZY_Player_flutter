import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/home/home_page.dart';
import 'package:ZY_Player_flutter/home/provider/player_resource_provider.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/intercept.dart';
import 'package:ZY_Player_flutter/provider/theme_provider.dart';
import 'package:ZY_Player_flutter/routes/404.dart';
import 'package:ZY_Player_flutter/routes/application.dart';
import 'package:ZY_Player_flutter/routes/routers.dart';
import 'package:ZY_Player_flutter/util/device_utils.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:ZY_Player_flutter/localization/app_localizations.dart';

import 'manhua/provider/manhua_provider.dart';

Future<void> main() async {
//  debugProfileBuildsEnabled = true;
//  debugPaintLayerBordersEnabled = true;
//  debugProfilePaintsEnabled = true;
//  debugRepaintRainbowEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  /// sp初始化
  await SpUtil.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PlayerResourceProvider>(create: (_) => PlayerResourceProvider()),
      ChangeNotifierProvider<CollectProvider>(create: (_) => CollectProvider()),
      ChangeNotifierProvider<ManhuaProvider>(create: (_) => ManhuaProvider()),
      ChangeNotifierProvider<PlayerProvider>(create: (_) => PlayerProvider()),
    ],
    child: MyApp(),
  ));
  // 透明状态栏
  if (Device.isAndroid) {
    final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  final Widget home;
  final ThemeData theme;

  MyApp({this.home, this.theme}) {
    Log.init();
    initDio();
    final Router router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  void initDio() {
    final List<Interceptor> interceptors = [];

    /// 统一添加身份验证请求头
    interceptors.add(AuthInterceptor());

    /// 刷新Token
    interceptors.add(TokenInterceptor());

    /// 打印Log(生产模式去除)
    if (!Constant.inProduction) {
      interceptors.add(LoggingInterceptor());
    }

    setInitDio(
      // baseUrl: Constant.inProduction ? 'http://140.143.207.151:7001/' : 'http://192.168.0.111:7001/',
      baseUrl: 'http://140.143.207.151:7001/',
      interceptors: interceptors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: Consumer<ThemeProvider>(
            builder: (_, provider, __) {
              return Shortcuts(
                  shortcuts: <LogicalKeySet, Intent>{
                    LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
                  },
                  child: MaterialApp(
                    title: 'Flutter Deer',
//              showPerformanceOverlay: true, //显示性能标签
//              debugShowCheckedModeBanner: false, // 去除右上角debug的标签
//              checkerboardRasterCacheImages: true,
//              showSemanticsDebugger: true, // 显示语义视图
//              checkerboardOffscreenLayers: true, // 检查离屏渲染
                    theme: theme ?? provider.getTheme(),
                    darkTheme: provider.getTheme(isDarkMode: true),
                    themeMode: provider.getThemeMode(),
                    // home: home ?? SplashPage(),
                    home: Home(),
                    onGenerateRoute: Application.router.generator,
                    localizationsDelegates: const [
                      AppLocalizationsDelegate(),
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const <Locale>[Locale('zh', 'CN'), Locale('en', 'US')],
                    builder: (context, child) {
                      /// 保证文字大小不受手机系统设置影响 https://www.kikt.top/posts/flutter/layout/dynamic-text/
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                            textScaleFactor: 1.0), // 或者 MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1.0),
                        child: child,
                      );
                    },

                    /// 因为使用了fluro，这里设置主要针对Web
                    onUnknownRoute: (_) {
                      return MaterialPageRoute(
                        builder: (BuildContext context) => PageNotFound(),
                      );
                    },
                  ));
            },
          ),
        ),

        /// Toast 配置
        backgroundColor: Colors.black54,
        textPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        radius: 20.0,
        position: ToastPosition.bottom);
  }
}
