import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'no_internet_screen.dart';

/// Dosya: connection_wrapper.dart
///
/// İnternet bağlantı durumunu sürekli dinleyen sarmalayıcı (wrapper) widget.
///
/// [Özellikler]
/// - Uygulamanın en üst katmanında çalışır.
/// - Bağlantı koptuğunda otomatik olarak [NoInternetScreen] gösterir.
/// - Bağlantı geri geldiğinde normal akışa devam eder.
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

  /// Uygulama ilk açıldığında anlık bağlantı durumunu kontrol eder.
  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  /// Bağlantı durumu değiştiğinde state'i günceller.
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // 'none' içeriyorsa internet yok demektir.
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
