import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/config.dart';
import '../state/auth_notifier.dart';

class InactivityWatcher extends StatefulWidget {
  const InactivityWatcher({
    super.key,
    required this.auth,
    required this.messengerKey,
    required this.child,
  });

  final AuthNotifier auth;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  Timer? _warnTimer;
  Timer? _idleTimer;
  Timer? _sessionTimer;
  bool _warned = false;
  bool _active = false;

  AuthNotifier get _auth => widget.auth;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _auth.addListener(_sync);
    _sync();
  }

  bool _onKey(KeyEvent event) {
    _restart();
    return false;
  }

  void _sync() {
    if (_auth.isAuthenticated == _active) return;
    _active = _auth.isAuthenticated;
    if (!_active) return _cancel();
    _restart();
    final endsAt = _auth.sessionEndsAt;
    if (endsAt != null) {
      _sessionTimer = Timer(
        endsAt.difference(DateTime.now()),
        () => _auth.logout(
          reason:
              'Сессия завершена: истёк максимальный срок работы '
              '(${sessionMaxDuration.inMinutes} мин)',
        ),
      );
    }
  }

  void _restart() {
    if (!_active) return;
    _warnTimer?.cancel();
    _idleTimer?.cancel();
    if (_warned) {
      widget.messengerKey.currentState?.hideCurrentSnackBar();
      _warned = false;
    }
    _warnTimer = Timer(inactivityTimeout - inactivityWarning, _warn);
    _idleTimer = Timer(
      inactivityTimeout,
      () => _auth.logout(
        reason:
            'Сессия завершена: ${inactivityTimeout.inMinutes} мин '
            'без действий',
      ),
    );
    _auth.markActivity();
  }

  void _warn() {
    _warned = true;
    widget.messengerKey.currentState?.showSnackBar(
      SnackBar(
        duration: inactivityWarning,
        content: Text(
          'Нет активности. Через ${inactivityWarning.inSeconds} секунд '
          'сессия будет завершена.',
        ),
        action: SnackBarAction(label: 'Продолжить', onPressed: _restart),
      ),
    );
  }

  void _cancel() {
    for (final t in [_warnTimer, _idleTimer, _sessionTimer]) {
      t?.cancel();
    }
    if (_warned) widget.messengerKey.currentState?.hideCurrentSnackBar();
    _warned = false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _auth.removeListener(_sync);
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerMove: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}
