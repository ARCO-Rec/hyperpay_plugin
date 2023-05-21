import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> pay() async {
    // await _hyperpayPlugin.payTransaction(
    //     CardInfo(
    //         holder: 'Test user ',
    //         cardNumber: '4200000000000000',
    //         cvv: '457',
    //         expiryMonth: '06',
    //         expiryYear: '2027'),
    //     '022AF636CF8D9B1E8EE44C1CEF53989B.uat01-vm-tx01',
    //     'VISA');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: pay,
          child: const Icon(Icons.payment),
        ),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('Running on: \n'),
        ),
      ),
    );
  }
}
