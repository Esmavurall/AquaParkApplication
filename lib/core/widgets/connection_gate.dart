import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:aquapark/core/network/connectivity_service.dart';

class ConnectionGate extends StatefulWidget {
  final Widget child;

  const ConnectionGate({
    super.key,
    required this.child,
  });

  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends State<ConnectionGate> {
  final ConnectivityService _service = ConnectivityService();

  StreamSubscription<bool>? _sub;

  final BehaviorSubject<bool> _online =
  BehaviorSubject<bool>.seeded(true);

  final BehaviorSubject<bool> _checking =
  BehaviorSubject<bool>.seeded(false);

  @override
  void initState() {
    super.initState();

    _sub = _service.onStatusChange().listen((online) {
      if (!_online.isClosed) {
        _online.add(online);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _online.close();
    _checking.close();

    super.dispose();
  }

  Future<void> _retry() async {
    if (!_checking.isClosed) {
      _checking.add(true);
    }

    final online = await _service.isOnline();

    if (!mounted) {
      return;
    }

    if (!_online.isClosed) {
      _online.add(online);
    }

    if (!_checking.isClosed) {
      _checking.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _online,
      initialData: _online.value,
      builder: (context, snapshot) {
        final online = snapshot.data ?? true;

        return Stack(
          children: [
            widget.child,

            if (!online) _buildOfflineScreen(),
          ],
        );
      },
    );
  }

  Widget _buildOfflineScreen() {
    return Positioned.fill(
      child: Material(
        color: const Color(0xFF06323C),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 72,
                ),

                const SizedBox(height: 20),

                Text(
                  'connection.offline_title'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'connection.offline_description'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                StreamBuilder<bool>(
                  stream: _checking,
                  initialData: _checking.value,
                  builder: (context, snapshot) {
                    final checking = snapshot.data ?? false;

                    return ElevatedButton.icon(
                      onPressed: checking ? null : _retry,
                      icon: checking
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.refresh,
                      ),
                      label: Text(
                        checking
                            ? 'connection.checking'.tr()
                            : 'connection.try_again'.tr(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF2E9CB4),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        const Color(0xFF2E9CB4)
                            .withValues(alpha: 0.65),
                        disabledForegroundColor:
                        Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}