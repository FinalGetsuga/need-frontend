import 'dart:ui';

abstract class CategoryColors {
  static const List<Color> _backgrounds = [
    Color(0xFFEDE9FE), // lavender
    Color(0xFFD1FAE5), // green
    Color(0xFFFCE7F3), // pink
    Color(0xFFFEF3C7), // amber
    Color(0xFFDBEAFE), // blue
    Color(0xFFFFE4E6), // rose
    Color(0xFFE0F2FE), // sky
    Color(0xFFECFCCB), // lime
  ];

  static const List<Color> _text = [
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFDB2777),
    Color(0xFFD97706),
    Color(0xFF2563EB),
    Color(0xFFE11D48),
    Color(0xFF0284C7),
    Color(0xFF65A30D),
  ];

  static ({Color background, Color text}) forId(String id) {
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    final index = hash % _backgrounds.length;
    return (background: _backgrounds[index], text: _text[index]);
  }
}