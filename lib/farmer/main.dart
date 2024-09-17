import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routing/Routes.dart';
import 'routing/Application.dart';
import './services/LocalizationProvider.dart';

class AgroAcresApp extends StatelessWidget {
  AgroAcresApp() {
    final router = FluroRouter();
    Routes.configureRouter(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider<LocalizationProvider>(
          create: (_) => LocalizationProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.lightGreen,
          colorScheme: ColorScheme(
              brightness: Brightness.dark,
              primary: Colors.lightGreen,
              onPrimary: Colors.black,
              secondary: Colors.green[600]!,
              onSecondary: Colors.black,
              error: Colors.red,
              onError: Colors.black,
              surface: Colors.blue,
              onSurface: Colors.black),
          //  colorScheme.sec: Colors.green[600],
          textTheme: TextTheme(
            titleSmall: TextStyle(
              fontFamily: 'Lato',
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Varela',
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Application.router.generator,
      ),
    );
  }
}
