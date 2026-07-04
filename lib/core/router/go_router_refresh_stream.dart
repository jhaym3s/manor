import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns any Stream into a [Listenable] so GoRouter's `refreshListenable`
/// can react to Bloc state changes and re-run its redirect logic.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
