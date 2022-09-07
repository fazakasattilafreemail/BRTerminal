import 'dart:io';

import 'package:Leuke/src/helpers/shared_pref.dart';
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
  await Firebase.initializeApp();
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
  String link = "";
  @override
  void initState() {
    SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
      initUniLinks().then((value) => this.setState(() {
        link += value;
        Fluttertoast.showToast(msg: link);
        try {
          if (link.contains("?v=")) {
            link = link.split("?v=")[1];
            SharedPreferencesHelper.setDeepLinkIds(
                link.split(",")).then((value) {
              super.initState();
            });
          }


        }catch(e){
          super.initState();
        }
      })).onError((error, stackTrace) => super.initState());
    });

    
    
  }
  Future<String> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      return initialLink;
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }
  @override
  Widget build(BuildContext context) {
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeLeft,
//    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
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
        // textTheme: TextTheme(
        //   headline5:
        //       TextStyle(fontSize: 22.0, color: Color(0xff000000), height: 1.3),
        //   headline4: TextStyle(
        //       fontSize: 20.0,
        //       fontWeight: FontWeight.w700,
        //       color: Color(0xff000000),
        //       height: 1.3),
        //   headline3: TextStyle(
        //     fontSize: 22.0,
        //     fontWeight: FontWeight.w400,
        //     color: Color(0xff000000),
        //   ),
        //   headline2: TextStyle(
        //     fontSize: 20.0,
        //     fontWeight: FontWeight.w500,
        //     color: Color(0xff000000),
        //   ),
        //   headline1: TextStyle(
        //       fontSize: 26.0,
        //       fontWeight: FontWeight.w300,
        //       color: Color(0xff000000),
        //       height: 1.4),
        //   subtitle1: TextStyle(
        //       fontSize: 18.0,
        //       fontWeight: FontWeight.w500,
        //       color: Color(0xff000000),
        //       height: 1.3),
        //   headline6: TextStyle(
        //       fontSize: 17.0,
        //       fontWeight: FontWeight.w700,
        //       color: Color(0xff000000),
        //       height: 1.3),
        //   bodyText2: TextStyle(
        //       fontSize: 15.0,
        //       fontWeight: FontWeight.w500,
        //       color: Color(0xff000000),
        //       height: 1.2),
        //   bodyText1: TextStyle(
        //       fontSize: 15.0,
        //       fontWeight: FontWeight.w400,
        //       color: Color(0xff000000),
        //       height: 1.3),
        //   caption: TextStyle(
        //       fontSize: 14.0,
        //       fontWeight: FontWeight.w300,
        //       color: Color(0xff000000).withOpacity(0.5),
        //       height: 1.2),
        // ),
      ),
    );
  }
}
