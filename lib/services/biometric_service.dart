import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication auth = LocalAuthentication();

  // Check whether biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      print("isDeviceSupported: $isDeviceSupported");
      print("canCheckBiometrics: $canCheckBiometrics");
      print("availableBiometrics: $availableBiometrics");

      return isDeviceSupported &&
          canCheckBiometrics &&
          availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      print("Biometric availability error: $e");
      return false;
    }
  }

  // Authenticate using biometric
  static Future<bool> authenticate() async {
    try {
      final bool available = await isBiometricAvailable();

      if (!available) {
        print("Biometric not available or not enrolled");
        return false;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access SafeDonate',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      print("Authenticated result: $authenticated");
      return authenticated;
    } on PlatformException catch (e) {
      print("Authentication error: $e");
      return false;
    }
  }
}