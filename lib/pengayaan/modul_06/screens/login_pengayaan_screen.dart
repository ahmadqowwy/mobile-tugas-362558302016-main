import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';
import '../storage/jenis_penyimpanan.dart';
import '../widgets/pemilih_penyimpanan.dart';

class LoginPengayaanScreen extends StatefulWidget {
  const LoginPengayaanScreen({
    super.key,
    required this.controller,
    required this.jenisPenyimpanan,
    required this.onPenyimpananBerubah,
    this.pemilihAktif = true,
  });

  final SesiController controller;
  final JenisPenyimpanan jenisPenyimpanan;
  final ValueChanged<JenisPenyimpanan> onPenyimpananBerubah;
  final bool pemilihAktif;

  @override
  State<LoginPengayaanScreen> createState() => _LoginPengayaanScreenState();
}

class _LoginPengayaanScreenState extends State<LoginPengayaanScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: 'mahasiswa@trpl.test');
  final TextEditingController _passwordController =
      TextEditingController(text: 'rahasia123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await widget.controller.masuk(
      email: _emailController.text,
      sandi: _passwordController.text,
    );
  }

  String? _validateEmail(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Email wajib diisi.';
    if (!text.contains('@') || !text.contains('.')) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Kata sandi wajib diisi.';
    if (text.length < 6) return 'Minimal 6 karakter.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool sibuk = widget.controller.status == StatusSesi.memproses;
    final String? pesan = widget.controller.pesan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk ke Modul 06'),
        actions: [
          if (widget.pemilihAktif)
            PemilihPenyimpanan(
              value: widget.jenisPenyimpanan,
              onChanged: widget.onPenyimpananBerubah,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sesi Pengguna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk menggunakan akun demo untuk melihat cara kerja penyimpanan sesi.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (pesan != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(pesan),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      enabled: !sibuk,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !sibuk,
                      validator: _validatePassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Kata sandi',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: sibuk ? null : _submit,
                      icon: sibuk
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(sibuk ? 'Memproses…' : 'Masuk'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: sibuk
                          ? null
                          : () {
                              _emailController.text = 'mahasiswa@trpl.test';
                              _passwordController.text = 'rahasia123';
                            },
                      child: const Text('Isi akun demo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
