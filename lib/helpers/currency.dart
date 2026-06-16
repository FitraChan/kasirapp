import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter;

  CurrencyInputFormatter(this.formatter);

  /// FORMAT UI (Rp 10.000)
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final numericText = removeCurrencyToString(newValue.text);

    if (numericText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.parse(numericText);
    final newText = formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  /// ===============================
  /// HELPER SECTION
  /// ===============================

  /// Menghapus currency → INT (untuk DB)
  static int removeCurrency(String? value) {
    if (value == null || value.isEmpty) return 0;

    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    return clean.isEmpty ? 0 : int.parse(clean);
  }

  /// Menghapus currency → STRING
  static String removeCurrencyToString(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
