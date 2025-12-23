import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'no_internet_screen.dart';

/// İnternet bağlantı durumunu dinleyen ve kullanıcıya bildiren sarmalayıcı (wrapper) widget.
///
/// Uygulamanın en üst katmanında çalışarak tüm ekranlarda bağlantı kopukluğunu
/// algılar ve [MaterialBanner] ile uyarı gösterir.
class ConnectionWrapper extends StatefulWidget {
  final Widget child;

  const ConnectionWrapper({super.key, required this.child});

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  // Bağlantı durumunu takip eden bayrak
  bool _hasConnection = true;
  // Bağlantı akışını (stream) dinlemek için abonelik
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    // İlk açılışta bağlantı kontrolü
    _checkInitialConnection();
    // Bağlantı değişikliklerini dinle
    _subscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Liste içindeki herhangi bir sonuç 'none' değilse bağlantı var sayıyoruz
    final hasConnection = !results.contains(ConnectivityResult.none);

    if (_hasConnection != hasConnection) {
      setState(() => _hasConnection = hasConnection);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasConnection) {
      return const NoInternetScreen();
    }
    return widget.child;
  }
}
