import 'package:content_store/src/models/cl_server.dart';

abstract class Server {
  CLServer? identity;
  bool get isOffline;
  bool get workingOffline;
  bool get isSyncing;

  bool get canSync;

  Future<bool> goOnline();
  Future<bool> workOffline();

  Future<bool?> sync();
  Future<bool?> checkStatus();
  Future<bool?> deregister();

  Future<bool?> register(CLServer candidate);

  bool get isRegistered;
}
