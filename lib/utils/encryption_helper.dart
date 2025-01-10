import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:math' show Random;
import 'package:pointycastle/export.dart' as pc;

class EncryptionHelper {
  static const int keyLength = 32; // 256 bits
  static const int ivLength = 16; // 128 bits

  // توليد IV عشوائي
  static IV generateIV() {
    final random = Random.secure();
    final ivBytes = List<int>.generate(ivLength, (i) => random.nextInt(256));
    return IV(Uint8List.fromList(ivBytes));
  }

  // توليد مفتاح من كلمة المرور
  static Uint8List deriveKey(String password, Uint8List salt) {
    var generator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    generator.init(pc.Pbkdf2Parameters(salt, 10000, keyLength));
    return generator.process(utf8.encode(password));
  }

  // تشفير البيانات
  static Map<String, String> encryptData(String data, String password) {
    try {
      // توليد salt عشوائي
      final random = Random.secure();
      final salt = Uint8List.fromList(
          List<int>.generate(32, (i) => random.nextInt(256)));

      // اشتقاق المفتاح من كلمة المرور
      final key = deriveKey(password, salt);

      // توليد IV عشوائي
      final iv = generateIV();

      // إنشاء مفتاح التشفير
      final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));

      // تشفير البيانات
      final encrypted = encrypter.encrypt(data, iv: iv);

      return {
        'data': encrypted.base64,
        'iv': iv.base64,
        'salt': base64.encode(salt),
        'version': '1.0'
      };
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // فك تشفير البيانات
  static String decryptData(
      Map<String, String> encryptedData, String password) {
    try {
      // استخراج البيانات المشفرة
      final salt = base64.decode(encryptedData['salt']!);
      final iv = IV.fromBase64(encryptedData['iv']!);
      final key = deriveKey(password, salt);

      // إنشاء مفتاح فك التشفير
      final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));

      // فك تشفير البيانات
      final decrypted = encrypter.decrypt64(encryptedData['data']!, iv: iv);

      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}
