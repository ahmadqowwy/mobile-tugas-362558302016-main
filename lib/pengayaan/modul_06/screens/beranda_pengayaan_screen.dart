import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';
import '../repositories/sesi_repository.dart';
import '../storage/jenis_penyimpanan.dart';
import '../widgets/papan_diagnostik_penyimpanan.dart';
import '../widgets/pemilih_penyimpanan.dart';
import 'profil_pengayaan_screen.dart';

class BerandaPengayaanScreen extends StatefulWidget {
  const BerandaPengayaanScreen({
    super.key,
    required this.controller,
    required this.sesi,
    required this.jenisPenyimpanan,
    required this.onPenyimpananBerubah,
    this.pemilihAktif = true,
  });

  final SesiController controller;
  final SesiPengguna sesi;
  final JenisPenyimpanan jenisPenyimpanan;
  final ValueChanged<JenisPenyimpanan> onPenyimpananBerubah;
  final bool pemilihAktif;

  @override
  State<BerandaPengayaanScreen> createState() =>
      _BerandaPengayaanScreenState();
}

class _BerandaPengayaanScreenState extends State<BerandaPengayaanScreen> {
  late DateTime _sekarang;
  late final Timer _timer;
  int _tabAktif = 0;
  bool _kedaluwarsaDiproses = false;

  @override
  void initState() {
    super.initState();
    _sekarang = widget.controller.jam();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _sekarang = widget.controller.jam();
      });

      if (!_kedaluwarsaDiproses &&
          widget.sesi.sudahKedaluwarsa(_sekarang)) {
        _kedaluwarsaDiproses = true;
        widget.controller.pulihkan();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatSisaWaktu(Duration sisa) {
    final int totalDetik = sisa.inSeconds;
    final String jam = (totalDetik ~/ 3600).toString().padLeft(2, '0');
    final String menit = ((totalDetik % 3600) ~/ 60).toString().padLeft(2, '0');
    final String detik = (totalDetik % 60).toString().padLeft(2, '0');
    return '$jam:$menit:$detik';
  }

  @override
  Widget build(BuildContext context) {
    final Duration sisa = widget.sesi.sisaWaktu(_sekarang);
    final bool hampirBerakhir = sisa < const Duration(minutes: 5);
    final Color warnaSisa = hampirBerakhir
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    final bool diBeranda = _tabAktif == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(diBeranda ? 'Beranda Fase B' : 'Profil'),
        actions: [
          if (widget.pemilihAktif)
            PemilihPenyimpanan(
              value: widget.jenisPenyimpanan,
              onChanged: widget.onPenyimpananBerubah,
            ),
          IconButton(
            onPressed: () async {
              await widget.controller.keluar();
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: SafeArea(
        child: diBeranda
            ? _tampilanBeranda(context, sisa, warnaSisa, hampirBerakhir)
            : ProfilPengayaanScreen(sesi: widget.sesi),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabAktif,
        onDestinationSelected: (int index) {
          setState(() {
            _tabAktif = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _tampilanBeranda(
    BuildContext context,
    Duration sisa,
    Color warnaSisa,
    bool hampirBerakhir,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Nama: ${widget.sesi.nama}'),
                Text('Email: ${widget.sesi.email}'),
                Text('Peran: ${widget.sesi.peran}'),
                Text('Token: ${widget.sesi.token}'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: warnaSisa.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: warnaSisa),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: warnaSisa),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hampirBerakhir
                                  ? 'Sesi segera berakhir'
                                  : 'Sisa masa sesi',
                              style: TextStyle(
                                color: warnaSisa,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatSisaWaktu(sisa),
                              style: TextStyle(
                                color: warnaSisa,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kedaluwarsa: ${widget.sesi.kedaluwarsaPada.toLocal()}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        PapanDiagnostikPenyimpanan(repository: widget.controller.repository),
      ],
    );
  }
}
