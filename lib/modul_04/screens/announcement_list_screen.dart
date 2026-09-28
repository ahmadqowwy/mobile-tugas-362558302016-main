import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pengayaan/modul_04/providers/announcement_provider.dart';
import '../models/announcement.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends ConsumerStatefulWidget {
  const AnnouncementListScreen({
    super.key,
  });

  @override
  ConsumerState<AnnouncementListScreen> createState() =>
      _AnnouncementListScreenState();
}

class _AnnouncementListScreenState
    extends ConsumerState<AnnouncementListScreen> {
  static const List<String> _kategori = <String>[
    'Semua',
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  String _kategoriTerpilih = 'Semua';

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Announcement>> pengumuman =
        ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Pengumuman TRPL'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: () {
              ref.invalidate(announcementsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildBarisFilter(),

          const Divider(height: 1),

          Expanded(
            child: pengumuman.when(
              // ====================================================
              // KEADAAN 1 — LOADING
              // ====================================================
              loading: () {
                return _buildMemuat();
              },

              // ====================================================
              // KEADAAN 2 — ERROR
              // ====================================================
              error: (Object error, StackTrace stackTrace) {
                return _buildGagal(error);
              },

              // ====================================================
              // KEADAAN 3 & 4 — DATA
              // ====================================================
              data: (List<Announcement> semua) {
                final List<Announcement> tampil =
                    _filterKategori(semua);

                // KEADAAN 3 — KOSONG
                if (tampil.isEmpty) {
                  return _buildKosong();
                }

                // KEADAAN 4 — BERHASIL
                return _buildDaftar(tampil);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FILTER KATEGORI
  // ================================================================

  Widget _buildBarisFilter() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _kategori.length,
        separatorBuilder: (
          BuildContext context,
          int index,
        ) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final String kategori = _kategori[index];

          return ChoiceChip(
            label: Text(kategori),
            selected: kategori == _kategoriTerpilih,
            onSelected: (_) {
              _pilihKategori(kategori);
            },
          );
        },
      ),
    );
  }

  void _pilihKategori(String kategori) {
    if (kategori == _kategoriTerpilih) {
      return;
    }

    setState(() {
      _kategoriTerpilih = kategori;
    });

    // Kirim kategori ke Repository melalui Riverpod.
    ref.read(selectedCategoryProvider.notifier).state =
        kategori == 'Semua' ? null : kategori;
  }

  List<Announcement> _filterKategori(
    List<Announcement> data,
  ) {
    if (_kategoriTerpilih == 'Semua') {
      return data;
    }

    return data
        .where(
          (Announcement item) =>
              item.category.toLowerCase() ==
              _kategoriTerpilih.toLowerCase(),
        )
        .toList(growable: false);
  }

  // ================================================================
  // KEADAAN 1 — LOADING
  // ================================================================

  Widget _buildMemuat() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Sedang memuat pengumuman...',
          ),
        ],
      ),
    );
  }

  // ================================================================
  // KEADAAN 2 — ERROR
  // ================================================================

  Widget _buildGagal(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_rounded,
              size: 64,
            ),

            const SizedBox(height: 16),

            const Text(
              'Gagal Memuat Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () {
                ref.invalidate(announcementsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // KEADAAN 3 — KOSONG
  // ================================================================

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.inbox_outlined,
              size: 64,
            ),

            const SizedBox(height: 16),

            const Text(
              'Tidak ada pengumuman',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Tidak ada pengumuman untuk kategori '
              '"$_kategoriTerpilih".',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // KEADAAN 4 — BERHASIL
  // ================================================================

  Widget _buildDaftar(
    List<Announcement> data,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(announcementsProvider);

        // Tunggu provider mendapatkan data terbaru.
        await ref.read(announcementsProvider.future);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final Announcement announcement = data[index];

          return AnnouncementCard(
            announcement: announcement,
            onTap: () {
              _bukaDetail(announcement);
            },
          );
        },
      ),
    );
  }

  // ================================================================
  // DETAIL
  // ================================================================

  void _bukaDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementDetailScreen(
          announcement: announcement,
        ),
      ),
    );
  }
}