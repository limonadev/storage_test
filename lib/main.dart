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
  String message;

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
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Messages:\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: message ?? ''),
                ],
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

    var contentFromStorage = await widget.storage.read(
      key: widget.storageKey,
    );

    setState(() {
      message =
          'Content from file is ${content == contentFromStorage ? 'equal to' : 'different from'} the content in Storage';
      checkingStorage = false;
    });
  }

  void _loadFileFromAssets() async {
    setState(() {
      loadingFromAssets = true;
    });

    var start = DateTime.now();
    content = await rootBundle.loadString('assets/files/random_words.txt');
    var end = DateTime.now();

    setState(() {
      message =
          'Loading total time: ${end.difference(start).inMilliseconds} ms';
      loadingFromAssets = false;
    });
  }

  void _saveContentOnStorage() async {
    setState(() {
      savingToStorage = true;
    });

    var start = DateTime.now();
    await widget.storage.write(key: widget.storageKey, value: content);
    var end = DateTime.now();

    setState(() {
      message =
          'Saving to Storage total time: ${end.difference(start).inMilliseconds} ms';
      savingToStorage = false;
    });
  }
}
