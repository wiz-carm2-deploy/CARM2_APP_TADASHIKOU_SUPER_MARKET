// @dart=2.9

import 'package:carm2_base/app/ui/widgets/app_version_widget.dart';
import 'package:carm2_base/carm2_base.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Carm2Base(
    configuration: Carm2Configuration(
      appSettings: AppSettings(
        appId: 4,
        appName: 'スーパーマーケットアプリ',
        backendBaseUrl: 'https://carm2-app.tdsku.com/CARM2CMS/client/',
        apiTimeoutDuration: const Duration(seconds: 30),
        useDummyData: false,
        dummyAppDataPath: 'test_resources/kyoroman_app_data.json',
        drawerMenuIconLabel: 'メニュー',
      ),
      paymentSettings: PaymentSettings(
        paymentPlatform: PaymentPlatform.stripe,
        paymentEnvironment: PaymentEnvironment.test,
        testStripePublishableKey:
            'pk_test_51HZ8rQEC70qfpFdBFoTG5GKXtV0nfYj92EgE8QWPrWIbTyhvIcqbrwk4qFkSvdvLJdBoogj0qmmhIqxikKQkpUTV00WOeeN6ew',
        productionStripePublishableKey:
            'pk_live_51HSZfhFZO0kg0q2qyJHSWZhrx9nlmNN6vuIicVM9mBwkEpBLkF0WV7pOIXE45p1oUxY9RyRQLNc0EL6hYVhIYc9s00UFrZYowV',
        enableSavedCards: false,
      ),
      themeData: ThemeData(
        primarySwatch: Carm2Colors.grey,
      ),
      splashScreen: const SplashScreen(),
      appFuncServicesOverrides: [],
    ),
  ).start());
}

/// カスタム[MaterialColor]の例
/// 下記のサイトから自動作成できる
/// http://mcg.mbitson.com/#!?mcgpalette0=%233f51b5
class Carm2Colors {
  static const MaterialColor grey =
      MaterialColor(_carm2colorsPrimaryValue, <int, Color>{
    50: Color(0xFFF7F7F7),
    100: Color(0xFFEAEAEA),
    200: Color(0xFFDDDDDD),
    300: Color(0xFFCFCFCF),
    400: Color(0xFFC4C4C4),
    500: Color(_carm2colorsPrimaryValue),
    600: Color(0xFFB3B3B3),
    700: Color(0xFFABABAB),
    800: Color(0xFFA3A3A3),
    900: Color(0xFF949494),
  });
  // static const int _carm2colorsPrimaryValue = 0xFFBABABA;
  static const int _carm2colorsPrimaryValue = 0xFF26A69A;

  static const MaterialColor carm2colorsAccent =
      MaterialColor(_carm2colorsAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_carm2colorsAccentValue),
    400: Color(0xFFFFCCCC),
    700: Color(0xFFFFB3B3),
  });
  static const int _carm2colorsAccentValue = 0xFFFFFFFF;
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Container(
              child: Center(
                child: Container(
                  constraints: BoxConstraints.expand(
                    width: 150,
                    height: 150,
                  ),
                  child: Image.asset(
                    'assets/splash/top.png',
                  ),
                ),
              ),
            ),
            // Container(
            //   constraints: const BoxConstraints.expand(),
            //   child: Center(
            //     child: Container(
            //       padding: const EdgeInsets.all(40.0),
            //       child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Image.asset(
            //             'assets/splash/top.png',
            //           ),
            //           Text(
            //             'スーパーマーケット用アプリ(TKW)',
            //             style: TextStyle(
            //               fontSize: 22.0,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Text('テスト環境'),
                    AppVersionWidget(),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
