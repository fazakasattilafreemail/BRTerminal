import 'dart:io';

import 'package:Leuke/src/helpers/shared_pref.dart';
import 'package:Leuke/src/views/splash_screen_view.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:uni_links/uni_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configuration");
  HttpOverrides.global = new MyHttpOverrides();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCsvyAVapj6SYPAQPdaDU0IvHLMl8smJ_E",
          authDomain: "backrec-48f82.firebaseapp.com",
          projectId: "backrec-48f82",
          storageBucket: "backrec-48f82.appspot.com",
          messagingSenderId: "553305702268",
          appId: "1:553305702268:web:7f5f32ff4f6a261e4a2ef9",
          measurementId: "G-K0D5XKRNTS"),

    );
  } catch (e){

  }
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.purple,
        alignment: Alignment.center,
        child: Text(
          'Something went wrong! '+details.stack.toString(),
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  };
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String link = null;
  bool linkAsked = false;
  @override
  void initState() {
    // SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
    //   initUniLinks().then((value) => this.setState(() {
    //     link += value;
    //     Fluttertoast.showToast(msg: link);
    //     try {
    //       if (link.contains("?v=")) {
    //         link = link.split("?v=")[1];
    //         SharedPreferencesHelper.setDeepLinkIds(
    //             link.split(",")).then((value) {
    //
    //         });
    //       }
    //
    //
    //     }catch(e){
    //
    //     }
    //   })).onError((error, stackTrace) => {});
    // });
    super.initState();

    
  }
  Future<String> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      String _link = initialLink;
      // Fluttertoast.showToast(msg: link);
      // try {
      //   if (_link.contains("?v=")) {
      //     _link = _link.split("?v=")[1];
      //     print('deeplink 000 start');
      //     await SharedPreferencesHelper.setDeepLinkIds(
      //         _link.split(","));
      //     print('deeplink 000 start');
      //     await SharedPreferencesHelper.setDeepLinkProfile('0');
      //
      //   } else if (_link.contains("?v1=")) {
      //     _link = _link.split("?v1=")[1];
      //     print('deeplink 111 start');
      //     await SharedPreferencesHelper.setDeepLinkIds(
      //         _link.split(","));
      //     print('deeplink 111 end');
      //     await SharedPreferencesHelper.setDeepLinkProfile('1');
      //     print('deeplink profile 1');
      //   } else {
      //     print('deeplink nullazva start');
      //     await SharedPreferencesHelper.setDeepLinkIds(<String>[]);
      //     print('deeplink nullazva end');
      //   }
      //
      //
      //
      // }catch(e){
      //   print('deeplink nullazva catch start');
      //   await SharedPreferencesHelper.setDeepLinkIds(<String>[]);
      //   print('deeplink nullazva catch end');
      // }

      if (_link!=null && _link.contains("v")) {
        SharedPreferencesHelper.setDeepLink(
            _link).then((value) {
          setState(() {
            link = _link;
            linkAsked = true;
          });
        });
      } else {
        SharedPreferencesHelper.setDeepLink(
            "").then((value) {
          setState(() {
            link = _link;
            linkAsked = true;
          });
        });
      }

      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      return initialLink;
    } catch(e){
      print('deeplink nullazva catch1 start');
      await SharedPreferencesHelper.setDeepLinkIds(<String>[]);
      SharedPreferencesHelper.setDeepLink(
          "").then((value) {
        setState(() {
          link = "";
          linkAsked = true;
        });
      });

    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeLeft,
//    ]);

    if (!linkAsked) {
      initUniLinks();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      // return
      // MaterialApp(
      //   title: '${GlobalConfiguration().get('app_name')}',
      //   navigatorObservers: [routeObserver],
      //   initialRoute: '/splash-screen',
      //   onGenerateRoute: RouteGenerator.generateRoute,
      //   debugShowCheckedModeBanner: false,
      //   theme: ThemeData(
      //     fontFamily: 'ProductSans',
      //     primaryColor: Colors.white,
      //     floatingActionButtonTheme: FloatingActionButtonThemeData(
      //         elevation: 0, foregroundColor: Colors.white),
      //     brightness: Brightness.light,
      //     dividerColor: Color(0xff36C5D3).withOpacity(0.1),
      //     focusColor: Color(0xff36C5D3).withOpacity(1),
      //     hintColor: Color(0xff000000).withOpacity(0.2), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff36C5D3)),
      //   ),
      // );
      return   linkAsked!=null && linkAsked?MaterialApp(
        title: '${GlobalConfiguration().get('app_name')}',
          navigatorObservers: [routeObserver],
          initialRoute: '/splash-screen',
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'ProductSans',
            primaryColor: Colors.white,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                elevation: 0, foregroundColor: Colors.white),
            brightness: Brightness.light,
            dividerColor: Color(0xff36C5D3).withOpacity(0.1),
            focusColor: Color(0xff36C5D3).withOpacity(1),
            hintColor: Color(0xff000000).withOpacity(0.2), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff36C5D3)),
          ),

      ):Container(
        color: Colors.black,
      );


  }
}
