import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:telegram_mini/features/custom_bottom_sheet.dart';
import 'package:telegram_mini/features/custom_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showModalWindow = false;

  void _closeModalWindow() {
    setState(() {
      showModalWindow = false;
    });
  }

  void _openModalWindow() {
    setState(() {
      showModalWindow = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Mini T"),
        ),
        body: Stack(
          children: [
            Center(
                child: CustomButton(
              onTap: _openModalWindow,
              buttonName: 'Open modal window',
            )),
            if (showModalWindow)
              CustomModalWindow(
                  url: 'https://pub.dev/', onClose: _closeModalWindow),
          ],
        ));
  }
}
