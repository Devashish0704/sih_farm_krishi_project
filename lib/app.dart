import 'package:e_commerce_app_flutter/farmer/routing/Application.dart';
import 'package:e_commerce_app_flutter/farmer/routing/Routes.dart';
import 'package:e_commerce_app_flutter/farmer/screens/WeatherScreen/state/WeatherBloc.dart';
import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
import 'package:e_commerce_app_flutter/wrappers/authentification_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'theme.dart';

class App extends StatelessWidget {
  App() {
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
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: theme(),
          home: AuthentificationWrapper(),
          onGenerateRoute: Application.router.generator,
          //home: AuthentificationWrapper(),
        ));
  }
}
