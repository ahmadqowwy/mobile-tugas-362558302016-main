class SesiPengguna {
  final String token;
  final String email;
  final String nama;
  final String peran;
  final DateTime masukPada;
  final DateTime kedaluwarsaPada;

  const SesiPengguna({
    required this.token,
    required this.email,
    required this.nama,
    required this.peran,
    required this.masukPada,
    required this.kedaluwarsaPada,
  });

  factory SesiPengguna.fromJson(Map<String, dynamic> json) {
    return SesiPengguna(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? 'tanpa-email',
      nama: json['nama'] as String? ?? 'Pengguna',
      peran: json['peran'] as String? ?? 'mahasiswa',
      masukPada: DateTime.tryParse(json['masukPada'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      kedaluwarsaPada:
          DateTime.tryParse(json['kedaluwarsaPada'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'email': email,
        'nama': nama,
        'peran': peran,
        'masukPada': masukPada.toIso8601String(),
        'kedaluwarsaPada': kedaluwarsaPada.toIso8601String(),
      };

  Duration sisaWaktu(DateTime sekarang) {
    final Duration selisih = kedaluwarsaPada.difference(sekarang);
    return selisih.isNegative ? Duration.zero : selisih;
  }

  bool sudahKedaluwarsa(DateTime sekarang) =>
      !sekarang.isBefore(kedaluwarsaPada);

  SesiPengguna copyWith({
    String? token,
    String? email,
    String? nama,
    String? peran,
    DateTime? masukPada,
    DateTime? kedaluwarsaPada,
  }) {
    return SesiPengguna(
      token: token ?? this.token,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      peran: peran ?? this.peran,
      masukPada: masukPada ?? this.masukPada,
      kedaluwarsaPada: kedaluwarsaPada ?? this.kedaluwarsaPada,
    );
  }

  static SesiPengguna demo({
    String email = 'mahasiswa@trpl.test',
    String nama = 'Mahasiswa TRPL',
    String peran = 'mahasiswa',
    DateTime? sekarang,
    Duration masaBerlaku = const Duration(hours: 2),
  }) {
    final DateTime now = sekarang ?? DateTime.now();
    return SesiPengguna(
      token: 'demo-token-${now.millisecondsSinceEpoch}',
      email: email,
      nama: nama,
      peran: peran,
      masukPada: now,
      kedaluwarsaPada: now.add(masaBerlaku),
    );
  }
}

abstract class SesiRepository {
  String get nama;
  String get keterangan;
  bool get bertahanSetelahRestart;

  Future<SesiPengguna?> baca();
  Future<void> simpan(SesiPengguna sesi);
  Future<void> hapus();
  Future<bool> adaSesi();

  Future<String?> intipMentah();
}
