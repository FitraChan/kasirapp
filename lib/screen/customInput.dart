import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';

class CustomInput {
  // ================= TEXT FIELD =================
  static Widget textField(
    String hint,
    IconData icon,
    TextEditingController? controller, {
    bool obscure = false,
    bool readOnly = false,
  }) {
    return _baseField(
      hint: hint,
      icon: icon,
      controller: controller,
      obscure: obscure,
      readOnly: readOnly,
    );
  }

  // ================= TEXT AREA =================
  static Widget textArea(
    String hint,
    IconData icon,
    TextEditingController? controller, {
    bool readOnly = false,
  }) {
    return _baseField(
      hint: hint,
      icon: icon,
      controller: controller,
      readOnly: readOnly,
      maxLines: 6,
    );
  }

  // ================= ANGKA + FORMAT =================
  static Widget angka(
    String hint,
    IconData icon,
    TextEditingController? controller,
  ) {
    _setDefaultZero(controller);

    return _baseField(
      hint: hint,
      icon: icon,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
    );
  }

  // ================= ANGKA BIASA =================
  static Widget number(
    String hint,
    IconData icon,
    TextEditingController? controller,
  ) {
    _setDefaultZero(controller);

    return _baseField(
      hint: hint,
      icon: icon,
      controller: controller,
      keyboardType: TextInputType.number,
    );
  }

  // ================= BASE =================
  static Widget _baseField({
    required String hint,
    required IconData icon,
    required TextEditingController? controller,
    bool obscure = false,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(hint, style: const TextStyle(color: Colors.black)),
        ),
        TextFormField(
          obscureText: obscure,
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        )
      ],
    );
  }

  // ================= DEFAULT ZERO =================
  static void _setDefaultZero(TextEditingController? controller) {
    if (controller != null && controller.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.text = '0';
      });
    }
  }
}
