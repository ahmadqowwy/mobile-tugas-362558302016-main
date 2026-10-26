import 'package:flutter/material.dart';

import '../storage/jenis_penyimpanan.dart';

class PemilihPenyimpanan extends StatelessWidget {
  const PemilihPenyimpanan({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final JenisPenyimpanan value;
  final ValueChanged<JenisPenyimpanan> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pilih jenis penyimpanan sesi',
      child: DropdownButton<JenisPenyimpanan>(
        value: value,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.storage_rounded),
        borderRadius: BorderRadius.circular(12),
        onChanged: (JenisPenyimpanan? jenis) {
          if (jenis != null && jenis != value) {
            onChanged(jenis);
          }
        },
        items: JenisPenyimpanan.values
            .map(
              (JenisPenyimpanan jenis) => DropdownMenuItem<JenisPenyimpanan>(
                value: jenis,
                child: Text(jenis.label),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
