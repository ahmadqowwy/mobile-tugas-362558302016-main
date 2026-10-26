import 'dart:convert';

import '../storage/penyimpanan_aman.dart';
import 'sesi_repository.dart';

class AmanSesiRepository implements SesiRepository {
  static const String kunciSesi = 'sesi_pengguna_aman';

  const AmanSesiRepository({required this.penyimpanan});

  final PenyimpananAman penyimpanan;

  @override
  String get nama => 'Secure Storage';

  @override
  String get keterangan =>
      'Plugin secure storage mengenkripsi data saat disimpan. API aplikasi '
      'tidak membuka ciphertext mentah yang ada di perangkat.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final String? payload = await penyimpanan.baca(kunciSesi);
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      return SesiPengguna.fromJson(data);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final String payload = jsonEncode(sesi.toJson());
    await penyimpanan.tulis(kunciSesi, payload);
  }

  @override
  Future<void> hapus() async {
    await penyimpanan.hapus(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async => (await baca()) != null;

  @override
  Future<String?> intipMentah() => penyimpanan.bacaMentah(kunciSesi);
}
