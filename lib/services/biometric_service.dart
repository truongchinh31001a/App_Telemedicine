import 'package:local_auth/local_auth.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async =>
      await _auth.canCheckBiometrics && await _auth.isDeviceSupported();

  Future<bool> authenticate() async {
    return await _auth.authenticate(
      localizedReason: 'Xác thực sinh trắc học để đăng nhập',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }
}
