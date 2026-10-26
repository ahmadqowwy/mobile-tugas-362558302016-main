import 'package:flutter/material.dart';

import '../repositories/sesi_repository.dart';

class PapanDiagnostikPenyimpanan extends StatefulWidget {
  const PapanDiagnostikPenyimpanan({
    super.key,
    required this.repository,
  });

  final SesiRepository repository;

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  String? _hasilIntip;
  bool _sedangMengintip = false;

  Future<void> _intip() async {
    setState(() => _sedangMengintip = true);
    final String? hasil = await widget.repository.intipMentah();
    if (!mounted) return;
    setState(() {
      _hasilIntip = hasil;
      _sedangMengintip = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warna.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnostik penyimpanan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.repository.nama,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(widget.repository.keterangan),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sedangMengintip ? null : _intip,
            icon: _sedangMengintip
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.remove_red_eye_outlined),
            label: Text(_sedangMengintip ? 'Mengintip…' : 'Intip token'),
          ),
          const SizedBox(height: 12),
          if (_hasilIntip == null)
            Text(
              'Nilai mentah tidak tersedia melalui adapter ini. '
              'Secure storage mengenkripsi data saat disimpan, dan plugin '
              'tidak menyediakan API untuk membaca ciphertext perangkat.',
              style: TextStyle(color: warna.onSurfaceVariant),
            )
          else
            SelectableText(
              _hasilIntip!,
              style: TextStyle(
                color: warna.onSurface,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}
