import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poliwangi_mobile_starter/modul_06/models/sesi_pengguna.dart';
import 'package:poliwangi_mobile_starter/modul_06/screens/login_screen.dart';
import 'package:poliwangi_mobile_starter/modul_06/services/auth_api.dart';
import 'package:poliwangi_mobile_starter/modul_06/services/sesi_memori.dart';

void main() {
  group('Modul 06 autentikasi dan sesi', () {
    test('sesi tepat pada waktu kedaluwarsa sudah tidak berlaku', () {
      final DateTime sekarang = DateTime(2026, 10, 19, 9);
      final SesiPengguna sesi = SesiPengguna.contoh(
        sekarang: sekarang,
        masaBerlaku: const Duration(minutes: 1),
      );

      expect(sesi.sudahKedaluwarsa(sekarang), isFalse);
      expect(
        sesi.sudahKedaluwarsa(sekarang.add(const Duration(minutes: 1))),
        isTrue,
      );
    });

    test('penyimpanan sesi menyimpan dan menghapus sesi di memori', () async {
      final SesiMemori penyimpanan = SesiMemori();
      final SesiPengguna sesi = SesiPengguna.contoh();

      await penyimpanan.simpan(sesi);
      expect(penyimpanan.baca(), same(sesi));
      expect(penyimpanan.adaSesi, isTrue);

      await penyimpanan.hapus();
      expect(penyimpanan.baca(), isNull);
      expect(penyimpanan.adaSesi, isFalse);
    });

    test('API simulasi menolak kredensial salah dengan AuthException',
        () async {
      const AuthApi api = AuthApi(tunda: Duration.zero);

      await expectLater(
        api.masuk(email: 'salah@example.com', sandi: 'salah'),
        throwsA(isA<AuthException>()),
      );
    });

    test('API menolak akun yang belum diaktivasi dengan kode khusus',
        () async {
      const AuthApi api = AuthApi(tunda: Duration.zero);

      await expectLater(
        api.masuk(email: AuthApi.emailBelumAktif, sandi: 'apa saja'),
        throwsA(
          isA<AuthException>()
              .having((error) => error.kode, 'kode', 403)
              .having(
                (error) => error.pesan,
                'pesan',
                'Akun belum diaktivasi. Periksa email Anda untuk tautan aktivasi.',
              ),
        ),
      );
    });

    testWidgets(
        'login berhasil menampilkan sesi dan tombol keluar menghapusnya',
        (WidgetTester tester) async {
      final SesiMemori penyimpanan = SesiMemori();
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            api: const AuthApi(tunda: Duration.zero),
            sesiMemori: penyimpanan,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        AuthApi.emailDemo,
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        AuthApi.sandiDemo,
      );
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Mahasiswa TRPL'), findsOneWidget);
      expect(penyimpanan.baca(), isNotNull);

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Portal Akademik'), findsOneWidget);
      expect(penyimpanan.baca(), isNull);
    });

    testWidgets('login menampilkan pesan aman saat kredensial salah',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            api: const AuthApi(tunda: Duration.zero),
            sesiMemori: SesiMemori(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'salah@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'salah1234');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
      expect(find.text('Kata sandi salah.'), findsNothing);
    });
  });
}
