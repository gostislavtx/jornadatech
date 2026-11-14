import 'package:flutter/services.dart';

/// Só os dígitos do texto.
String cpfDigits(String text) => text.replaceAll(RegExp(r'\D'), '');

/// Valida o CPF pelos dois dígitos verificadores.
bool isValidCpf(String text) {
  final d = cpfDigits(text);
  if (d.length != 11) return false;
  // 000.000.000-00, 111.111.111-11 etc. passam na conta, mas não existem.
  if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;

  int check(int length) {
    var sum = 0;
    for (var i = 0; i < length; i++) {
      sum += int.parse(d[i]) * (length + 1 - i);
    }
    final rest = (sum * 10) % 11;
    return rest == 10 ? 0 : rest;
  }

  return check(9) == int.parse(d[9]) && check(10) == int.parse(d[10]);
}

/// Formata enquanto digita: 000.000.000-00.
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = cpfDigits(newValue.text);
    final d = digits.length > 11 ? digits.substring(0, 11) : digits;
    final out = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 3 || i == 6) out.write('.');
      if (i == 9) out.write('-');
      out.write(d[i]);
    }
    final text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
