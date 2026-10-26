import 'package:flutter/material.dart';

import 'controllers/sesi_controller.dart';
import 'repositories/aman_sesi_repository.dart';
import 'repositories/memori_sesi_repository.dart';
import 'repositories/prefs_sesi_repository.dart';
import 'repositories/sesi_repository.dart';
import 'screens/beranda_pengayaan_screen.dart';
import 'screens/login_pengayaan_screen.dart';
import 'storage/penyimpanan_aman.dart';
import 'storage/penyimpanan_aman_platform.dart';
import 'storage/jenis_penyimpanan.dart';
import 'widgets/gerbang_sesi.dart';

class Modul06PengayaanApp extends StatefulWidget {
  const Modul06PengayaanApp({
    super.key,
    this.repository,
    this.penyimpananAman,
    this.jenisPenyimpanan = JenisPenyimpanan.aman,
    this.jam = DateTime.now,
  });

  final SesiRepository? repository;
  final PenyimpananAman? penyimpananAman;
  final JenisPenyimpanan jenisPenyimpanan;
  final DateTime Function() jam;

  @override
  State<Modul06PengayaanApp> createState() => _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState extends State<Modul06PengayaanApp> {
  late JenisPenyimpanan _jenisPenyimpanan;
  late SesiRepository _repository;
  late SesiController _controller;

  @override
  void initState() {
    super.initState();
    _jenisPenyimpanan = widget.jenisPenyimpanan;
    _repository = _buatRepository(_jenisPenyimpanan);
    _controller = _buatController(_repository);
    _controller.pulihkan();
  }

  SesiRepository _buatRepository(JenisPenyimpanan jenis) {
    if (widget.repository case final SesiRepository repository) {
      return repository;
    }

    return switch (jenis) {
      JenisPenyimpanan.aman => AmanSesiRepository(
          penyimpanan:
              widget.penyimpananAman ?? const PenyimpananAmanPlatform(),
        ),
      JenisPenyimpanan.memori => MemoriSesiRepository(),
      JenisPenyimpanan.prefs => PrefsSesiRepository(),
    };
  }

  SesiController _buatController(SesiRepository repository) {
    return SesiController(
      repository: repository,
      loginHandler: _loginDemo,
      jam: widget.jam,
    );
  }

  Future<void> _pilihPenyimpanan(JenisPenyimpanan jenis) async {
    if (jenis == _jenisPenyimpanan ||
        _controller.status == StatusSesi.memeriksa ||
        _controller.sedangMemproses ||
        widget.repository != null) {
      return;
    }

    final SesiController controllerLama = _controller;
    final SesiRepository repositoryBaru = _buatRepository(jenis);
    final SesiController controllerBaru = _buatController(repositoryBaru);

    setState(() {
      _jenisPenyimpanan = jenis;
      _repository = repositoryBaru;
      _controller = controllerBaru;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllerLama.dispose();
    });
    await controllerBaru.pulihkan();
  }

  Future<SesiPengguna> _loginDemo(String email, String sandi) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Email tidak valid.');
    }
    if (sandi.length < 6) {
      throw Exception('Kata sandi terlalu pendek.');
    }

    final DateTime now = widget.jam();
    return SesiPengguna(
      token: 'token-${email.trim()}-${now.millisecondsSinceEpoch}',
      email: email.trim(),
      nama: 'Mahasiswa Fase B',
      peran: 'mahasiswa',
      masukPada: now,
      kedaluwarsaPada: now.add(const Duration(hours: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pengayaan Modul 06',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GerbangSesi(
        controller: _controller,
        form: (context) => LoginPengayaanScreen(
          controller: _controller,
          jenisPenyimpanan: _jenisPenyimpanan,
          pemilihAktif: widget.repository == null,
          onPenyimpananBerubah: _pilihPenyimpanan,
        ),
        beranda: (context, sesi) => BerandaPengayaanScreen(
          controller: _controller,
          sesi: sesi,
          jenisPenyimpanan: _jenisPenyimpanan,
          pemilihAktif: widget.repository == null,
          onPenyimpananBerubah: _pilihPenyimpanan,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
