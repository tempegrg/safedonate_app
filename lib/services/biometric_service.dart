import 'package:local_auth/local_auth.dart';

class BiometricService {

  static final LocalAuthentication auth =
      LocalAuthentication();

  static Future<bool> authenticate() async {

    try {

      bool canCheck =
          await auth.canCheckBiometrics;

      bool isSupported =
          await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        return false;
      }

      bool authenticated =
          await auth.authenticate(

        localizedReason:
            'Authenticate to access SafeDonate',

        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;

    } catch (e) {

      print(e);
      return false;
    }
  }
}