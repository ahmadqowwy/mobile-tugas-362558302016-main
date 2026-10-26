import 'package:flutter/material.dart';

import '../repositories/sesi_repository.dart';

class ProfilPengayaanScreen extends StatelessWidget {
  const ProfilPengayaanScreen({super.key, required this.sesi});

  final SesiPengguna sesi;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: warna.primaryContainer,
                  child: Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: warna.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  sesi.nama,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(sesi.peran),
                const Divider(height: 32),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(sesi.email),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.login_rounded),
                  title: const Text('Waktu masuk'),
                  subtitle: Text(sesi.masukPada.toLocal().toString()),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Sesi berlaku sampai'),
                  subtitle: Text(sesi.kedaluwarsaPada.toLocal().toString()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
