import 'package:flutter/services.dart';

class MaskTextInputFormatter extends TextInputFormatter {
  Map<int, String> _maskMap;
  List<int> _maskList;

  MaskTextInputFormatter(maskString, {escapeChar: "_"}) {
    assert(maskString != null);
    final entries = RegExp('[^$escapeChar]+')
        .allMatches(maskString)
        .map((match) => MapEntry<int, String>(match.start, match.group(0)));

    _maskMap = new Map.fromEntries(entries);
    _maskList = _maskMap.keys.toList();
  }

  String getEscapedString(String inputText) {
    _maskList.reversed
        .where((index) =>
            index < inputText.length && _substringIsMask(inputText, index))
        .forEach((index) {
      inputText = inputText.substring(0, index) +
          inputText.substring(index + _maskMap[index].length);
    });
    return inputText;
  }

  bool _substringIsMask(String inputText, int index) {
    try {
      return inputText.substring(index, index + _maskMap[index].length) ==
          _maskMap[index];
    } on RangeError {
      return false;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var escapedString = getEscapedString(newValue.text);
    var position = newValue.selection.baseOffset -
        (newValue.text.length - escapedString.length);

    _maskList.forEach((index) {
      if (escapedString.length > index) {
        escapedString = escapedString.substring(0, index) +
            _maskMap[index] +
            escapedString.substring(index);
        position += _maskMap[index].length;
      }
    });

    return newValue.copyWith(
        text: escapedString,
        selection: TextSelection.collapsed(offset: position));
  }
}

class CreditCardTextInputFormatter extends TextInputFormatter {
  String formattedString = "";
  String rawString = "";
  CreditCardTextInputFormatter();

  String getRawString() {
    rawString = formattedString.replaceAll(" ", "").trim();
    return rawString;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    formattedString = newValue.text;
    var escapedString = getEscapedString(newValue.text);
    var position = newValue.selection.baseOffset -
        (newValue.text.length - escapedString.length);

    return newValue.copyWith(
        text: escapedString,
        selection: TextSelection.collapsed(offset: position));
  }

  getEscapedString(String text) {
    List<String> chunks = text.split("");
    List<String> padded = [];

    int group = 0;
    String cache = "";

    chunks.forEach((i) {
      group += 1;
      cache += i;

      if (group == 4) {
        padded.add(cache);
        group = 0;
        cache = "";
      }
    });

    if (cache.length > 0) {
      padded.add(cache);
      cache = "";
      group = 0;
    }
    return padded.join(" ");
  }
}
