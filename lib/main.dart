import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: ExpensiveWidget(),
              ),
              Expanded(
                child: CheapWidget(),
              ),
            ],
          ),
          const ObjectProviderWidget(),
          TextButton(
            onPressed: () {
              context.read<ObjectProvider>().stop();
            },
            child: const Text("Stop"),
          ),
          TextButton(
            onPressed: () {
              context.read<ObjectProvider>().start();
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ObjectProvider provider = context.watch<ObjectProvider>();
    return Container(
      height: 200,
      color: Colors.purple,
      child: Column(
        children: [
          const Text("Object Provider Widget"),
          const Text("ID"),
          Text(provider.id),
        ],
      ),
    );
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpensiveObject expensiveObject =
        context.select<ObjectProvider, ExpensiveObject>(
            (provider) => provider.expensiveObject);
    return Container(
      height: 200,
      color: Colors.blue,
      child: Column(
        children: [
          const Text("Expensive Object"),
          const Text("last updated"),
          Text(expensiveObject.lastUpdated),
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CheapObject cheapObject = context.select<ObjectProvider, CheapObject>(
        (provider) => provider.cheapObject);
    return Container(
      height: 200,
      color: Colors.yellow,
      child: Column(
        children: [
          const Text("Cheap Object"),
          const Text("last updated"),
          Text(cheapObject.lastUpdated),
        ],
      ),
    );
  }
}

class BaseObject {
  final String id;
  final String lastUpdated;

  BaseObject()
      : id = const Uuid().v4(),
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ExpensiveObject extends BaseObject {}

class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSubstriction;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveObjectStreamSubstriction;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  CheapObject get cheapObject => _cheapObject;

  ExpensiveObject get expensiveObject => _expensiveObject;

  void start() {
    _cheapObjectStreamSubstriction =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _cheapObject = CheapObject();
      notifyListeners();
    });
    _expensiveObjectStreamSubstriction =
        Stream.periodic(const Duration(seconds: 10)).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapObjectStreamSubstriction.cancel();
    _expensiveObjectStreamSubstriction.cancel();
  }
}
