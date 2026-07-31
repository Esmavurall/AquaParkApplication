import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> onStatusChange() async* {
    yield await isOnline(); 
    await for (final _ in _connectivity.onConnectivityChanged) {
      yield await isOnline();
    }
  }

  // Cihazın internete bağlı olup olmadığını sorgular.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);
    if (!hasNetwork) return false;

    // DNS sorgusu ile internet erişimini test eder.
    try {
      final lookup = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
