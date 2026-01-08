import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:grocery_ledger/core/storage/hive_app_settings.dart';
import 'package:grocery_ledger/core/auth/auth_service.dart';
import 'biometric_service.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({
    super.key,
    required this.child,
  });

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _isLocked = false;
  late Box<HiveAppSettings> _settingsBox;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settingsBox = Hive.box<HiveAppSettings>('app_settings');
    
    // Initial lock check
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock when app moves to background or is inactive
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _lockApp();
    } else if (state == AppLifecycleState.resumed) {
      _checkLockStatus();
    }
  }

  bool get _shouldLock {
    // Only lock if user is authenticated with Supabase and biometric is enabled
    final settings = _settingsBox.get('settings');
    final isEnabled = settings?.isBiometricLockEnabled ?? false;
    final isLoggedIn = AuthService.instance.isLoggedIn;
    
    return isEnabled && isLoggedIn;
  }

  void _lockApp() {
    if (_shouldLock) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  void _checkInitialLock() {
    if (_shouldLock) {
      setState(() {
        _isLocked = true;
      });
      // Delay to ensure the UI is ready before showing native dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkLockStatus();
      });
    }
  }

  Future<void> _checkLockStatus() async {
    if (!_isLocked) return;

    final authenticated = await BiometricService.instance.authenticate();
    if (authenticated) {
      setState(() {
        _isLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // The actual app (Navigator)
          widget.child,

          // The Lock Screen Overlay
          if (_isLocked)
            Positioned.fill(
              child: _LockScreen(onUnlock: _checkLockStatus),
            ),
        ],
      ),
    );
  }
}

class _LockScreen extends StatelessWidget {
  final VoidCallback onUnlock;

  const _LockScreen({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Grocery Ledger',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Authenticate to continue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUnlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.fingerprint),
                label: const Text(
                  'Unlock App',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
