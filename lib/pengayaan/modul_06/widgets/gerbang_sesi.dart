import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';
import '../repositories/sesi_repository.dart';

class GerbangSesi extends StatelessWidget {
  const GerbangSesi({
    super.key,
    required this.controller,
    required this.form,
    required this.beranda,
  });

  final SesiController controller;
  final Widget Function(BuildContext context) form;
  final Widget Function(BuildContext context, SesiPengguna sesi) beranda;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        switch (controller.status) {
          case StatusSesi.memeriksa:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 14),
                    Text('Memeriksa sesi tersimpan…'),
                  ],
                ),
              ),
            );
          case StatusSesi.masuk:
            final SesiPengguna? sesi = controller.sesi;
            if (sesi == null) {
              return form(context);
            }
            return beranda(context, sesi);
          case StatusSesi.keluar:
          case StatusSesi.gagal:
          case StatusSesi.kedaluwarsa:
          case StatusSesi.memproses:
            return form(context);
        }
      },
    );
  }
}
