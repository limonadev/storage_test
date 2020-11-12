import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StoragePage(),
    );
  }
}

class StoragePage extends StatefulWidget {
  StoragePage()
      : storage = FlutterSecureStorage(),
        storageKey = 'CONTENT';

  final FlutterSecureStorage storage;
  final String storageKey;

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  bool checkingStorage = false,
      loadingFromAssets = false,
      savingToStorage = false;
  String content;
  List<String> messages = [];
  ScrollController messagesController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            _saveToStorageWidget(),
            OutlinedButton(
              onPressed: () {},
              child: Text('Save to protected SQLite'),
            ),
            Spacer(flex: 2),
            _assertStorageContentWidget(),
            Spacer(flex: 2),
            _loadFromAssetsWidget(),
            Spacer(),
            Text(
              'Messages:',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 200.0,
              child: ListView.builder(
                controller: messagesController,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    messages[index] ?? '',
                  ),
                ),
                itemCount: messages.length,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _assertStorageContentWidget() {
    Widget result;
    if (checkingStorage == true) {
      result = CircularProgressIndicator();
    } else {
      result = OutlinedButton(
        onPressed: _assertContentFromStorage,
        child: Text('Assert content from Secure Storage'),
      );
    }
    return result;
  }

  Widget _loadFromAssetsWidget() {
    Widget result;
    if (loadingFromAssets == true) {
      result = CircularProgressIndicator();
    } else {
      result = content == null
          ? OutlinedButton(
              onPressed: _loadFileFromAssets,
              child: Text('Load from assets'),
            )
          : Text(
              'Content from assets is already in RAM',
            );
    }
    return result;
  }

  Widget _saveToStorageWidget() {
    Widget result;
    if (savingToStorage == true) {
      result = CircularProgressIndicator();
    } else {
      result = OutlinedButton(
        onPressed: _saveContentOnStorage,
        child: Text('Save to Secure Storage'),
      );
    }
    return result;
  }

  void _assertContentFromStorage() async {
    setState(() {
      checkingStorage = true;
    });

    var start = DateTime.now();
    var contentFromStorage = await widget.storage.read(
      key: widget.storageKey,
    );
    var end = DateTime.now();

    setState(() {
      checkingStorage = false;
    });

    _registerMessages(
      [
        'Retrieving content from Storage total time: ${end.difference(start).inMilliseconds} ms',
        'Content from file is ${content == contentFromStorage ? 'equal to' : 'different from'} the content in Storage',
      ],
    );
  }

  void _loadFileFromAssets() async {
    setState(() {
      loadingFromAssets = true;
    });

    var start = DateTime.now();
    content = await rootBundle.loadString('assets/files/random_words.txt');
    var end = DateTime.now();

    setState(() {
      loadingFromAssets = false;
    });

    _registerMessage(
      'Loading total time: ${end.difference(start).inMilliseconds} ms',
    );
  }

  void _saveContentOnStorage() async {
    setState(() {
      savingToStorage = true;
    });

    var start = DateTime.now();
    await widget.storage.write(key: widget.storageKey, value: content);
    var end = DateTime.now();

    setState(() {
      savingToStorage = false;
    });

    _registerMessage(
      'Saving to Storage total time: ${end.difference(start).inMilliseconds} ms',
    );
  }

  Future<void> _registerMessage(String message) async {
    setState(() {
      messages.add(message);
    });

    await Future.delayed(Duration(milliseconds: 100));
    messagesController.animateTo(
      messagesController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  void _registerMessages(List<String> messages) async {
    for (var message in messages) {
      await _registerMessage(message);
    }
  }
}
