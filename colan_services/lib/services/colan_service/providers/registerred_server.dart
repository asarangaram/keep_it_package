import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cl_server.dart';

class RegisteredServerNotifier extends StateNotifier<CLServer?> {
  RegisteredServerNotifier() : super(null) {
    _initialize();
  }

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: Media Downloader',
    );
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final myServerJSON = prefs.getString('myServer');

    if (myServerJSON != null) {
      final server = CLServer.fromJson(myServerJSON);
      log('Server found from history. $server');
      state = server;
    }
  }

  Future<void> register(CLServer value) async {
    // Registered, but request is for register again
    // If server is same ignore, else, log and then ignore
    if (state != null) {
      if (state != value) {
        // We may consider notifying
        log("can't register ($value) as "
            'another server( $state) is registered');
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('myServer', value.toJson());
    state = value;
    log('server registered $state');
    return;
  }

  Future<bool> deregister() async {
    // Not registers, and request is for unregistered
    if (state == null) {
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('myServer');
    state = null;
    log('server unregistered ');
    return true;
  }
}

final registeredServerProvider =
    StateNotifierProvider<RegisteredServerNotifier, CLServer?>((ref) {
  return RegisteredServerNotifier();
});
