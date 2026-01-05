import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock Grocery Ledger',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Fallback to passcode if biometric fails/unavailable
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric Error: $e');
      return false;
    }
  }
}
