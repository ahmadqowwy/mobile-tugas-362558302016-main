import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/modul_06_pengayaan_app.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/screens/profil_pengayaan_screen.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/storage/jenis_penyimpanan.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/storage/penyimpanan_aman.dart';

class _PenyimpananAmanPalsu implements PenyimpananAman {
  final Map<String, String> _data = <String, String>{};

  @override
  Future<String?> baca(String kunci) async => _data[kunci];

  @override
  Future<String?> bacaMentah(String kunci) async => null;

  @override
  Future<void> hapus(String kunci) async {
    _data.remove(kunci);
  }

  @override
  Future<void> tulis(String kunci, String nilai) async {
    _data[kunci] = nilai;
  }
}

void main() {
  testWidgets('pemilih menampilkan tiga pilihan dan mengganti repository',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Modul06PengayaanApp(
          jenisPenyimpanan: JenisPenyimpanan.memori,
          penyimpananAman: _PenyimpananAmanPalsu(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Memori'));
    await tester.pumpAndSettle();

    expect(find.text('Prefs'), findsOneWidget);
    expect(find.text('Aman'), findsOneWidget);

    await tester.tap(find.text('Aman'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Secure Storage'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hitung mundur berubah merah dan profil berada di balik gerbang',
      (WidgetTester tester) async {
    DateTime sekarang = DateTime(2026, 10, 26, 9);
    await tester.pumpWidget(
      MaterialApp(
        home: Modul06PengayaanApp(
          jenisPenyimpanan: JenisPenyimpanan.memori,
          jam: () => sekarang,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('02:00:00'), findsOneWidget);
    expect(find.byType(ProfilPengayaanScreen), findsNothing);

    sekarang = sekarang.add(const Duration(hours: 1, minutes: 55, seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    final Text hitungMundur = tester.widget<Text>(find.text('00:04:59'));
    expect(
      hitungMundur.style?.color,
      ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ).colorScheme.error,
    );
    expect(find.text('Sesi segera berakhir'), findsOneWidget);

    await tester.tap(find.text('Profil').first);
    await tester.pump();
    expect(find.byType(ProfilPengayaanScreen), findsOneWidget);
    expect(find.text('mahasiswa@trpl.test'), findsOneWidget);

    await tester.tap(find.byTooltip('Keluar'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(ProfilPengayaanScreen), findsNothing);
    expect(find.text('Masuk ke Modul 06'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
