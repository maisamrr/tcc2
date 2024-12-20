import 'package:app/firebase_options.dart';
import 'package:app/screens/allidentifiedrecipes.dart';
import 'package:app/screens/allreceipts.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/receiptdetails.dart';
import 'package:app/screens/scanarcodeinstructions.dart';
import 'package:app/screens/scanqrcode.dart';
import 'package:app/screens/subscribe.dart';
import 'package:app/screens/start.dart';
import 'package:app/screens/forgotpassword.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/waitingforrecipe.dart';
import 'package:app/store/user_store.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => UserStore(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notas Culinárias',
        theme: ThemeData(
          fontFamily: 'PP Neue Montreal',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Start(),
          '/login': (context) => Login(),
          '/subscribe': (context) => Subscribe(),
          '/forgotpassword': (context) => ForgotPassword(),
          '/home': (context) => Home(),
          '/scanqrcode': (context) => ScanQrCode(),
          '/allreceipts': (context) => AllReceipts(),
          '/waitingforrecipe': (context) => WaitingForRecipe(),
          '/allidentifiedrecipes': (context) => AllIdentifiedRecipes(),
          '/profile': (context) => Profile(),
          '/scanqrcodeinstructions': (context) => ScanQrCodeInstructions(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
