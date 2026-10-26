import 'package:flutter/foundation.dart';

import '../repositories/sesi_repository.dart';

enum StatusSesi { memeriksa, keluar, memproses, masuk, gagal, kedaluwarsa }

class SesiController extends ChangeNotifier {
  SesiController({
    required this.repository,
    required this.loginHandler,
    this.jam = DateTime.now,
  });

  final SesiRepository repository;
  final Future<SesiPengguna> Function(String email, String sandi) loginHandler;
  final DateTime Function() jam;

  StatusSesi _status = StatusSesi.memeriksa;
  SesiPengguna? _sesi;
  String? _pesan;
  bool _sedangMemproses = false;

  StatusSesi get status => _status;
  SesiPengguna? get sesi => _sesi;
  String? get pesan => _pesan;
  bool get sedangMemproses => _sedangMemproses;
  bool get isLoggedIn => _status == StatusSesi.masuk && _sesi != null;

  Future<void> pulihkan() async {
    _status = StatusSesi.memeriksa;
    _pesan = null;
    notifyListeners();

    final SesiPengguna? tersimpan = await repository.baca();
    if (tersimpan == null) {
      _sesi = null;
      _status = StatusSesi.keluar;
      notifyListeners();
      return;
    }

    if (tersimpan.sudahKedaluwarsa(jam())) {
      await repository.hapus();
      _sesi = null;
      _status = StatusSesi.kedaluwarsa;
      _pesan = 'Sesi Anda sudah berakhir. Silakan masuk kembali.';
      notifyListeners();
      return;
    }

    _sesi = tersimpan;
    _status = StatusSesi.masuk;
    notifyListeners();
  }

  Future<void> masuk({required String email, required String sandi}) async {
    if (_sedangMemproses) {
      return;
    }

    _sedangMemproses = true;
    _status = StatusSesi.memproses;
    _pesan = null;
    notifyListeners();

    try {
      final SesiPengguna sesiBaru = await loginHandler(email.trim(), sandi);
      await repository.simpan(sesiBaru);
      _sesi = sesiBaru;
      _status = StatusSesi.masuk;
      _pesan = null;
    } catch (error) {
      _status = StatusSesi.gagal;
      _pesan = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _sedangMemproses = false;
      notifyListeners();
    }
  }

  Future<void> keluar() async {
    _sedangMemproses = false;
    await repository.hapus();
    _sesi = null;
    _status = StatusSesi.keluar;
    _pesan = null;
    notifyListeners();
  }

  Future<void> perbaruiSesi(
      {Duration masaBerlaku = const Duration(hours: 2)}) async {
    if (_sesi == null) {
      return;
    }

    if (_sesi!.sudahKedaluwarsa(jam())) {
      await repository.hapus();
      _sesi = null;
      _status = StatusSesi.kedaluwarsa;
      _pesan = 'Sesi sudah berakhir dan tidak dapat diperbarui.';
      notifyListeners();
      return;
    }

    final SesiPengguna baru = _sesi!.copyWith(
      kedaluwarsaPada: jam().add(masaBerlaku),
    );
    await repository.simpan(baru);
    _sesi = baru;
    _status = StatusSesi.masuk;
    notifyListeners();
  }
}
