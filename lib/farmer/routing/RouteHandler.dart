import 'package:e_commerce_app_flutter/farmer/screens/UserInfoScreen.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/components/edit_product_form.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../screens/InitScreen.dart';
import '../screens/HomeScreen.dart';
import '../screens/LoginScreen.dart';
import '../screens/WebViewScreen.dart';
import '../screens/WeatherScreen/WeatherScreen.dart';
import '../screens/SettingsScreen/SettingsScreen.dart';
import '../screens/ProductsScreen/AddProductScreen.dart';
import '../screens/ProductsScreen/MyProductsScreen.dart';
import '../screens/WeatherScreen/state/WeatherBloc.dart';
import '../screens/SettingsScreen/SetLanguageScreen.dart';
import '../screens/ProductsScreen/state/ProductsBloc.dart';
import '../screens/SettingsScreen/state/TutorialBloc.dart';
import '../screens/CalenderScreen/screens/FieldScreen.dart';
import '../screens/CalenderScreen/screens/MyCropFieldScreen.dart';
import '../screens/CalenderScreen/screens/AddCropFieldScreen.dart';

var initHandler = Handler(handlerFunc: (context, params) {
  return InitScreen();
});

var loginHandler = Handler(
  handlerFunc: (context, param) {
    return LoginScreen();
  },
);
var userInfoHandler = Handler(
  handlerFunc: (context, param) {
    return UserInfoScreen();
  },
);
var registerHandler = Handler(
  handlerFunc: (context, param) {
    return LoginScreen();
  },
);

var homeHandler = Handler(handlerFunc: (context, params) {
  return HomeScreen();
});

var setLanguageHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return SetLanguageScreen();
});

var weatherHandler = Handler(handlerFunc: (context, params) {
  return Provider<WeatherBloc>(
    create: (context) => WeatherBloc(),
    dispose: (context, bloc) => bloc.dispose(),
    child: WeatherScreen(),
  );
});

var myProductsHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    return Provider<ProductsBloc>(
      create: (context) => ProductsBloc(userId: params['userId']!.first),
      dispose: (context, bloc) => bloc.dispose(),
      child: MyProductsScreen(),
    );
  },
);

var addProductHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    return Provider<ProductsBloc>(
      create: (context) => ProductsBloc(fetchProducts: false),
      dispose: (context, bloc) => bloc.dispose(),
      child: EditProductScreen(),
    );
  },
);

var editProductHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    return Provider<ProductsBloc>(
      create: (context) => ProductsBloc(fetchProducts: false),
      dispose: (context, bloc) => bloc.dispose(),
      child: MyProductsScreen(),
    );
  },
);

var settingsHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    bool isEnglish = params['language']!.first == 'en';
    return Provider<TutorialBloc>(
      create: (context) => TutorialBloc(isEnglish),
      dispose: (context, bloc) => bloc.dispose(),
      child: SettingsScreen(),
    );
  },
);

var chatbotHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    bool isEnglish = params['language']!.first == 'en';
    return WebViewScreen(
      isEnglish ? 'Welcome' : 'स्वागत हे',
      isEnglish ? CHATBOT_ENGLISH_URL : CHATBOT_HINDI_URL,
      isEnglish ? TUTORIAL_URL_CHATBOT_ENGLISH : TUTORIAL_URL_CHATBOT_HINDI,
    );
  },
);

var myFieldsHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    return FieldScreen();
  },
);

var addCropFieldsHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    return AddCropFieldScreen();
  },
);

var myCropFieldHandler = Handler(
  handlerFunc: (context, Map<String, List<String>> params) {
    String id = params['id']!.first;
    return MyCropFieldScreen(id);
  },
);
