import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/password_item.dart';
import 'database_helper.dart';
import 'encryption_helper.dart';

class BackupHelper {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<String> createBackup(String password) async {
    try {
      // جلب كل كلمات المرور
      final passwords = await _databaseHelper.getAllPasswords();

      // تحضير البيانات للنسخ الاحتياطي
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'passwords': passwords.map((p) => p.toMap()).toList(),
      };

      // تشفير البيانات
      final jsonString = jsonEncode(backupData);
      final encrypted = EncryptionHelper.encryptData(jsonString, password);

      // حفظ الملف المشفر
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'password_backup_${DateTime.now().millisecondsSinceEpoch}.enc';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonEncode(encrypted));
      return file.path;
    } catch (e) {
      throw Exception('Backup creation failed: $e');
    }
  }

  Future<bool> restoreBackup(String password) async {
    try {
      // اختيار ملف النسخ الاحتياطي
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['enc'],
      );

      if (result == null) return false;

      // قراءة الملف المشفر
      final file = File(result.files.single.path!);
      final encryptedJson = await file.readAsString();
      final encryptedData = Map<String, String>.from(jsonDecode(encryptedJson));

      // فك تشفير البيانات
      final decryptedJson =
          EncryptionHelper.decryptData(encryptedData, password);
      final backupData = jsonDecode(decryptedJson);

      // التحقق من صحة الملف
      if (!backupData.containsKey('passwords')) {
        throw Exception('Invalid backup file');
      }

      // حذف كل البيانات القديمة
      await _databaseHelper.deleteAllPasswords();

      // استعادة كلمات المرور
      final passwordsList = (backupData['passwords'] as List);
      for (var passwordMap in passwordsList) {
        final password = PasswordItem.fromMap(passwordMap);
        await _databaseHelper.insertPassword(password);
      }

      return true;
    } catch (e) {
      print('Error restoring backup: $e');
      return false;
    }
  }
}
