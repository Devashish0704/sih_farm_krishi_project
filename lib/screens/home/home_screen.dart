import 'dart:async';
import 'package:e_commerce_app_flutter/basic_utitlities.dart';
import 'package:e_commerce_app_flutter/data/Repository.dart';
import 'package:e_commerce_app_flutter/data/api_exception.dart';
import 'package:e_commerce_app_flutter/farmer/routing/RouteHandler.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
import 'package:e_commerce_app_flutter/screens/my_orders/my_orders_screen.dart';
import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../size_config.dart';
import 'components/body.dart';
import 'components/home_screen_drawer.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText speechToText = SpeechToText();
  final ApiRepo _api = ApiRepo();

  String lastWords = '';
  bool _isListening = false;
  bool _isSpeechInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechAndTTS();
  }

  Future<void> _initializeSpeechAndTTS() async {
    try {
      // Initialize Speech to Text
      _isSpeechInitialized = await speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            _isListening = false;
            _isSpeechInitialized = false;
          });
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
      );
      try {
        var language = 'en-IN';
        var isLanguageAvailable =
            await flutterTts.isLanguageAvailable(language);

        if (isLanguageAvailable) {
          await flutterTts.setLanguage(language);
          await flutterTts.setPitch(1.0);
        } else {
          print('Language $language is not available on this device.');
        }
      } catch (ex) {
        print('Unexpected error: $ex');
      }
      // Initialize Text to Speech
      await flutterTts.setSharedInstance(true);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      setState(() {});
    } catch (e) {
      print('Initialization error: $e');
      Utils.snackBar(context, 'Failed to initialize speech services');
    }
  }

  Future<void> _toggleSpeechRecognition() async {
    try {
      // Check if speech is initialized
      if (!_isSpeechInitialized) {
        await _initializeSpeechAndTTS();
        return;
      }

      // Toggle listening state
      if (!_isListening) {
        if (await speechToText.hasPermission) {
          await _startListening();
        } else {
          bool permitted = await speechToText.initialize();
          if (permitted) {
            await _startListening();
          } else {
            Utils.snackBar(context, "Speech recognition permission required");
          }
        }
      } else {
        await _stopListening();
      }
    } catch (e) {
      print("Speech recognition toggle error: $e");
      Utils.snackBar(context, "Speech recognition failed: $e");
    }
  }

  Future<void> _startListening() async {
    if (!speechToText.isListening) {
      await speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        cancelOnError: true,
        listenMode: ListenMode.deviceDefault,
      );

      setState(() {
        _isListening = true;
        lastWords = '';
      });
    }
  }

  Future<void> _stopListening() async {
    await speechToText.stop();

    // Delay to ensure last words are captured
    await Future.delayed(Duration(milliseconds: 500));

    if (lastWords.isNotEmpty) {
      await _sendToAI(lastWords);
    } else {
      Utils.snackBar(context, "No input detected. Please try again.");
    }

    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> _sendToAI(String text) async {
    try {
      final response = await _api.navigationAi({"text": text});
      _processAIResponse(response);
    } on ApiException catch (errorJson) {
      Utils.snackBar(context, errorJson.message);
    } catch (error) {
      Utils.snackBar(context, "An unexpected error occurred. $error");
    }
  }

  Future<void> _processAIResponse(Map response) async {
    String type = response["action"]["type"];
    String text = response["action"]["text"];

    switch (type) {
      case "AddProduct":
      case "EditProduct":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProductScreen()),
        );
        break;
      case "MyOrders":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyOrdersScreen()),
        );
        break;
      case "search":
        await _performSearch(text);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.toString())),
        );
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      List<String> searchedProductsId =
          await ProductDatabaseHelper().searchInProducts(query.toLowerCase());

      if (searchedProductsId.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(
              searchQuery: query,
              searchResultProductsId: searchedProductsId,
              searchIn: "All Products",
              productPrice: '999',
            ),
          ),
        );
      } else {
        Utils.snackBar(context, "No products found matching your search.");
      }
    } catch (e) {
      Logger().e(e.toString());
      Utils.snackBar(context, "Search failed: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
      drawer: HomeScreenDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSpeechRecognition,
        backgroundColor: _isListening ? Colors.red : Colors.green,
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:e_commerce_app_flutter/basic_utitlities.dart';
// import 'package:e_commerce_app_flutter/data/Repository.dart';
// import 'package:e_commerce_app_flutter/data/api_exception.dart';
// import 'package:e_commerce_app_flutter/farmer/routing/RouteHandler.dart';
// import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
// import 'package:e_commerce_app_flutter/screens/my_orders/my_orders_screen.dart';
// import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:logger/logger.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import '../../size_config.dart';
// import 'components/body.dart';
// import 'components/home_screen_drawer.dart';

// class HomeScreen extends StatefulWidget {
//   static const String routeName = "/home";

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // final translator = GoogleTranslator();
//   final flutterTts = FlutterTts();

//   String lastWords = '';
//   // late stt.SpeechToText _speech;

//   final speechToText = SpeechToText();

//   ApiRepo _api = ApiRepo();
//   bool _isListening = false;
//   // String _command = "";

//   @override
//   void dispose() {
//     super.dispose();
//     speechToText.stop();

//     flutterTts.stop();
//   }

//   @override
//   void initState() {
//     super.initState();

//     // ProductDatabaseHelper().determinePosition();

//     // print("yo${ProductDatabaseHelper().userLocation}");

//     // _speech = stt.SpeechToText();
//     initSpeechToText();
//     initTextToSpeech();
//   }

//   Future<void> initTextToSpeech() async {
//     print("intializing text to speech");
//     await flutterTts.setSharedInstance(true);
//     setState(() {});
//   }

//   // Future<String> convertor(String oldString, language) async {
//   //   var translation = await translator.translate(oldString, to: language);
//   //   return translation.toString();
//   // }

//   Future<void> initSpeechToText() async {
//     await speechToText.initialize();
//     print("speech initialized");
//     setState(() {});
//   }

//   Future<void> startListening() async {
//     print("listening");
//     _isListening = true;
//     await speechToText.listen(
//       onResult: onSpeechResult,
//     );
//     setState(() {
//       _isListening = true;
//     });
//   }

//   // Future<void> stopListening() async {
//   //   print("stop listening");
//   //   await speechToText.stop();
//   //   setState(() {
//   //     _isListening = false;
//   //   });
//   //   await _sendToAI(lastWords);
//   // }
//   Future<void> stopListening() async {
//     print("stop listening");

//     await speechToText.stop();

//     // Delay to ensure lastWords updates
//     await Future.delayed(Duration(seconds: 1));

//     if (lastWords.isNotEmpty) {
//       print("Sending words to AI: $lastWords");
//       await _sendToAI(lastWords);
//     } else {
//       print("No recognized words to send.");
//       Utils.snackBar(context, "No input detected. Please try again.");
//     }

//     setState(() {
//       _isListening = false;
//     });
//   }

//   void onSpeechResult(SpeechRecognitionResult result) {
//     print("onSpeechResult" + result.recognizedWords);
//     setState(() {
//       lastWords = result.recognizedWords;
//     });
//   }

//   Future<void> systemSpeak(String content) async {
//     await flutterTts.speak(content);
//     setState(() {});
//   }

//   Future<void> systemStop() async {
//     await flutterTts.stop();
//     setState(() {});
//   }

//   Future<void> _sendToAI(String text) async {
//     try {
//       Map data = {
//         "text": text,
//       };
//       print(data);
//       final response = await _api.navigationAi(data);
//       print(response);
//       _processAIResponse(response);

//       //   Utils.snackBar(context, response["message"]); // Display OTP sent message
//     } on ApiException catch (errorJson) {
//       final errorMessage = errorJson.message;
//       print(errorMessage);
//       Utils.snackBar(context, errorMessage);
//     } catch (error) {
//       print(error);
//       Utils.snackBar(context, "An unexpected error occurred. $error");
//     }
//   }

//   Future<void> _processAIResponse(Map response) async {
//     String type = response["action"]["type"];
//     String text = response["action"]["text"];
//     //  String target = response["action"]["target"];
//     print(text);
//     //  print(target);
//     print(type);
//     //["AddProduct", "EditProduct", "MyOrders", "search" , "chatbot"]
//     if (type == "AddProduct") {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => EditProductScreen(),
//           ));
//     } else if (type == "EditProduct") {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => EditProductScreen(),
//           ));
//     } else if (type == "MyOrders") {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MyOrdersScreen(),
//           ));
//     } else if (type == "search") {
//       final query = text.toString();
//       print(query);
//       if (query.length <= 0) return;
//       List<String> searchedProductsId;
//       // Map<String, dynamic> searchedProductsId;

//       try {
//         // searchedProductsId = await ProductDatabaseHelper()
//         //     .fetchProductIdsAndPrice(query.toLowerCase(), "Rajasthan");
//         searchedProductsId =
//             await ProductDatabaseHelper().searchInProducts(query.toLowerCase());
//         print(searchedProductsId);
//         if (searchedProductsId != null) {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SearchResultScreen(
//                 searchQuery: query,
//                 searchResultProductsId: searchedProductsId,
//                 searchIn: "All Products",
//                 productPrice: '999',
//               ),
//             ),
//           );
//           //  await refreshPage();
//         } else {
//           throw "Couldn't perform search due to some unknown reason";
//         }
//       } catch (e) {
//         final error = e.toString();
//         Logger().e(error);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("$error"),
//           ),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response.toString())),
//       );
//     }
//   }

//   //AIzaSyB3nx2YsyfEexAbmgw7LwHitg2k2D1dbFk

//   void _openDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Namaste, how can I help you?"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               InkWell(
//                 onTap: () async {
//                   if (await speechToText.hasPermission && !_isListening) {
//                     await startListening();
//                   } else if (_isListening) {
//                     await stopListening();
//                   } else {
//                     initSpeechToText();
//                   }
//                 },
//                 child: Icon(
//                   _isListening ? Icons.stop : Icons.mic,
//                   size: 40,
//                   color: speechToText.isListening ? Colors.red : Colors.green,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Text(speechToText.isListening
//                   ? "Listening..."
//                   : "Tap the mic to start speaking."),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Scaffold(
//       body: Body(),
//       drawer: HomeScreenDrawer(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           if (await speechToText.hasPermission && !_isListening) {
//             await startListening();
//           } else if (_isListening) {
//             await stopListening();
//           } else {
//             initSpeechToText();
//           }
//         },
//         child: Icon(
//           _isListening ? Icons.stop : Icons.mic,
//           size: 40,
//           color: speechToText.isListening ? Colors.red : Colors.green,
//         ),
//         //child: Icon(Icons.mic),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';

// // import '../../size_config.dart';
// // import 'components/body.dart';
// // import 'components/home_screen_drawer.dart';

// // class HomeScreen extends StatelessWidget {
// //   static const String routeName = "/home";
// //   @override
// //   Widget build(BuildContext context) {
// //     SizeConfig().init(context);
// //     return Scaffold(
// //       body: Body(),
// //       drawer: HomeScreenDrawer(),
// //     );
// //   }
// // }
