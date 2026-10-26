import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'penyimpanan_aman.dart';

class PenyimpananAmanPlatform implements PenyimpananAman {
  const PenyimpananAmanPlatform({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> tulis(String kunci, String nilai) async {
    await _secureStorage.write(key: kunci, value: nilai);
  }

  @override
  Future<String?> baca(String kunci) async {
    return _secureStorage.read(key: kunci);
  }

  @override
  Future<void> hapus(String kunci) async {
    await _secureStorage.delete(key: kunci);
  }

  @override
  Future<String?> bacaMentah(String kunci) async {
    return null;
  }
}
