import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itcc/src/data/globals.dart';

class SecureStorage {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

 static Future<String?> read(String key) async {
  try {
    return await _storage.read(key: key);
  } catch (e) {
    print('SecureStorage read error for key "$key": $e');
    await _storage.delete(key: key);
    return null;
  }
}

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

Future<void> loadSecureData() async {
  try {
    token = await SecureStorage.read('token') ?? '';
    LoggedIn = (await SecureStorage.read('LoggedIn')) == 'true';
    id = await SecureStorage.read('id') ?? '';
    fcmToken = await SecureStorage.read('fcmToken') ?? '';
    subscriptionType = await SecureStorage.read('subscriptionType') ?? 'free';
  } catch (e) {
    print('Error loading secure data: $e');
    await SecureStorage.deleteAll();
  }
}


Future<void> saveSecureData() async {
  await SecureStorage.write('token', token);
  await SecureStorage.write('LoggedIn', LoggedIn.toString());
  await SecureStorage.write('id', id);
  await SecureStorage.write('fcmToken', fcmToken);
  await SecureStorage.write('subscriptionType', subscriptionType);
}
