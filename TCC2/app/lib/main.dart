import 'package:app/screens/allreceipts.dart';
import 'package:app/screens/fullrecipe.dart';
import 'package:app/screens/scanqrcode.dart';
import 'package:app/screens/subscribe.dart';
import 'package:app/screens/start.dart';
import 'package:app/screens/forgotpassword.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/waitingforrecipe.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        '/fullrecipe': (context) => FullRecipe(),
        '/scanqrcode': (context) => ScanQrCode(),
        '/allreceipts': (context) => AllReceipts(),
        '/waitingforrecipe': (context) => WaitingForRecipe(),
      },
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
