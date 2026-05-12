import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:local_pip/local_pip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _pipAvailable = false;
  final _localPipPlugin = LocalPip();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    bool pipAvailable;

    try {
      platformVersion = await _localPipPlugin.getPlatformVersion() ?? 'Unknown platform version';
      pipAvailable = await _localPipPlugin.isPipAvailable();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      pipAvailable = false;
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _pipAvailable = pipAvailable;
    });
  }

  Future<void> _enterPip() async {
    try {
      await _localPipPlugin.enterPipMode();
    } catch (e) {
      debugPrint("Error entering PiP: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Local PiP Example'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Running on: $_platformVersion'),
                const SizedBox(height: 10),
                Text('PiP Available: ${_pipAvailable ? "YES" : "NO"}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pipAvailable ? _enterPip : null,
                  child: const Text('Enter Picture-in-Picture'),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Note: PiP will only work if 'supportsPictureInPicture' is set to true in AndroidManifest.xml",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
