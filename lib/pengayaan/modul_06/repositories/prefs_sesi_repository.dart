import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sesi_repository.dart';

class PrefsSesiRepository implements SesiRepository {
  static const String kunciSesi = 'sesi_pengguna_prefs';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  String get nama => 'SharedPreferences';

  @override
  String get keterangan =>
      'Menyimpan data sesi dalam preferensi teks biasa; mudah dibaca saat perangkat tidak aman.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(kunciSesi);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      return SesiPengguna.fromJson(data);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async => (await baca()) != null;

  @override
  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(kunciSesi);
  }
}
