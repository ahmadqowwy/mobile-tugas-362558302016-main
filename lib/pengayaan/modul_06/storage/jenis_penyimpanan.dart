enum JenisPenyimpanan { memori, prefs, aman }

extension LabelJenisPenyimpanan on JenisPenyimpanan {
  String get label {
    switch (this) {
      case JenisPenyimpanan.memori:
        return 'Memori';
      case JenisPenyimpanan.prefs:
        return 'Prefs';
      case JenisPenyimpanan.aman:
        return 'Aman';
    }
  }
}
