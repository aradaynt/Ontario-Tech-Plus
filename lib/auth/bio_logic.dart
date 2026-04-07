import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device has biometric hardware and if the user has enrolled any biometrics.
  Future<bool> hasBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print("Error checking biometrics: $e");
      return false;
    }
  }

  /// Prompts the user to authenticate. Returns true if successful.
  Future<bool> authenticate() async {
    final bool isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access Ontario Tech Plus',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keeps the prompt open if the app goes to the background temporarily
          biometricOnly: false, // Allows fallback to device PIN/Pattern if biometrics fail
        ),
      );
    } on PlatformException catch (e) {
      print("Error authenticating: $e");
      return false;
    }
  }
}