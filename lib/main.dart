import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final ContactBook contactBook = ContactBook();
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: contactBook,
        builder: (context, value, child) {
          final List<Contact> contacts = value;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              Contact contact = contacts[index];
              return Dismissible(
                key: ValueKey(contact.id),
                onDismissed: (direction) {
                  contactBook.remove(contact: contact);
                },
                child: ListTile(
                  title: Text(contact.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewContactPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewContactPage extends StatefulWidget {
  const NewContactPage({super.key});

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  final TextEditingController _contactNameController = TextEditingController();

  @override
  void dispose() {
    _contactNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ContactBook contactBook = ContactBook();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new contact"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _contactNameController,
            decoration: const InputDecoration(hintText: "Enter contact name"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_contactNameController.text.isNotEmpty) {
                Contact contact = Contact(name: _contactNameController.text);
                contactBook.add(contact: contact);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Add contact"),
          ),
        ],
      ),
    );
  }
}

class Contact {
  final String id;
  final String name;

  Contact({required this.name}) : id = const Uuid().v4();
}

class ContactBook extends ValueNotifier<List<Contact>> {
  ContactBook._sharedInstance() : super([]);

  static final ContactBook _shared = ContactBook._sharedInstance();

  factory ContactBook() => _shared;

  int get length => value.length;

  void add({required Contact contact}) {
    value.add(contact);
    notifyListeners();
  }

  void remove({required Contact contact}) {
    value.remove(contact);
    notifyListeners();
  }

  Contact? contact({required int atIndex}) {
    return value.length > atIndex ? value[atIndex] : null;
  }
}
