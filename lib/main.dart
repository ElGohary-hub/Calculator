import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const ScientificCalculatorApp());
}

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      home: const CalculatorBody(),
    );
  }
}

class CalculatorBody extends StatefulWidget {
  const CalculatorBody({super.key});

  @override
  State<CalculatorBody> createState() => _CalculatorBodyState();
}

class _CalculatorBodyState extends State<CalculatorBody> {
  String _displayText = "0"; 
  String _historyText = ""; 
  bool _shouldShowCursor = true; 
  Timer? _cursorTimer; 

  @override
  void initState() {
    super.initState();
    _startCursorBlink();
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _shouldShowCursor = !_shouldShowCursor;
        });
      }
    });
  }

  // --- إدخال البيانات للشاشة ---
  void _onInputPressed(String input) {
    setState(() {
      if (_displayText == "0" && !['+', '-', '×', '÷', '.', ')', '²'].contains(input)) {
        _displayText = input;
      } else {
        _displayText += input;
      }
    });
  }

  void _onACPressed() {
    setState(() {
      _displayText = "0";
      _historyText = "";
    });
  }

  void _onDELPressed() {
    setState(() {
      if (_displayText.isNotEmpty && _displayText != "0") {
        if (_displayText.endsWith("sin(") || _displayText.endsWith("cos(") || _displayText.endsWith("tan(") || _displayText.endsWith("log(")) {
          _displayText = _displayText.substring(0, _displayText.length - 4);
        } else if (_displayText.endsWith("ln(")) {
          _displayText = _displayText.substring(0, _displayText.length - 3);
        } else if (_displayText.endsWith("√( ")) {
          _displayText = _displayText.substring(0, _displayText.length - 3);
        } else {
          _displayText = _displayText.substring(0, _displayText.length - 1);
        }
        
        if (_displayText.isEmpty) {
          _displayText = "0";
        }
      }
    });
  }

  // --- المفسر الرياضي الذكي ---
  void _onEqualPressed() {
    setState(() {
      try {
        _historyText = _displayText + " =";
        String expression = _displayText
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('π', math.pi.toString())
            .replaceAll('e', math.e.toString());

        double result = _evaluateExpression(expression);
        
        _displayText = result.toString().replaceAll(RegExp(r'\.0$'), '');
        if (_displayText == "NaN" || _displayText == "Infinity") {
          _displayText = "Error";
        }
      } catch (e) {
        _displayText = "Error";
      }
    });
  }

  double _evaluateExpression(String expr) {
    while (expr.contains('(')) {
      int startIndex = expr.lastIndexOf('(');
      int endIndex = expr.indexOf(')', startIndex);
      if (endIndex == -1) endIndex = expr.length;

      String subExpr = expr.substring(startIndex + 1, endIndex);
      double subResult = _evaluateSimple(subExpr);

      String beforeBracket = expr.substring(0, startIndex);
      if (beforeBracket.endsWith('sin')) {
        expr = beforeBracket.substring(0, beforeBracket.length - 3) + math.sin(subResult * math.pi / 180).toString() + expr.substring(endIndex + 1);
      } else if (beforeBracket.endsWith('cos')) {
        expr = beforeBracket.substring(0, beforeBracket.length - 3) + math.cos(subResult * math.pi / 180).toString() + expr.substring(endIndex + 1);
      } else if (beforeBracket.endsWith('tan')) {
        expr = beforeBracket.substring(0, beforeBracket.length - 3) + math.tan(subResult * math.pi / 180).toString() + expr.substring(endIndex + 1);
      } else if (beforeBracket.endsWith('log')) {
        expr = beforeBracket.substring(0, beforeBracket.length - 3) + (math.log(subResult) / math.ln10).toString() + expr.substring(endIndex + 1);
      } else if (beforeBracket.endsWith('ln')) {
        expr = beforeBracket.substring(0, beforeBracket.length - 2) + math.log(subResult).toString() + expr.substring(endIndex + 1);
      } else if (beforeBracket.endsWith('√')) {
        expr = beforeBracket.substring(0, beforeBracket.length - 1) + math.sqrt(subResult).toString() + expr.substring(endIndex + 1);
      } else {
        expr = expr.substring(0, startIndex) + subResult.toString() + expr.substring(endIndex + 1);
      }
    }
    return _evaluateSimple(expr);
  }

  double _evaluateSimple(String expr) {
    while (expr.contains('²')) {
      int idx = expr.indexOf('²');
      int start = idx - 1;
      while (start >= 0 && (RegExp(r'[0-9.]').hasMatch(expr[start]))) {
        start--;
      }
      start++;
      double num = double.parse(expr.substring(start, idx));
      expr = expr.substring(0, start) + (num * num).toString() + expr.substring(idx + 1);
    }

    List<String> tokens = [];
    String numberBuffer = "";
    
    for (int i = 0; i < expr.length; i++) {
      String char = expr[i];
      if (RegExp(r'[0-9.]').hasMatch(char) || (char == '-' && (i == 0 || ['+', '-', '*', '/'].contains(expr[i - 1])))) {
        numberBuffer += char;
      } else {
        if (numberBuffer.isNotEmpty) {
          tokens.add(numberBuffer);
          numberBuffer = "";
        }
        tokens.add(char);
      }
    }
    if (numberBuffer.isNotEmpty) tokens.add(numberBuffer);

    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double val1 = double.parse(tokens[i - 1]);
        double val2 = double.parse(tokens[i + 1]);
        double res = tokens[i] == '*' ? val1 * val2 : val1 / val2;
        tokens[i - 1] = res.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        i--;
      }
    }

    double finalResult = tokens.isNotEmpty ? double.parse(tokens[0]) : 0;
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double val = double.parse(tokens[i + 1]);
      if (op == '+') finalResult += val;
      if (op == '-') finalResult -= val;
    }

    return finalResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
          child: Column(
            children: [
              _buildTopBanner(),
              const SizedBox(height: 15),
              _buildDisplayScreen(),
              const SizedBox(height: 20),
              Expanded(
                child: _buildKeypad(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          'صلّ على النبي ﷺ وذكر غيرك',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayScreen() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF010101), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.5), width: 1), 
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _historyText,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 16,
              fontFamily: 'Arial',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(), 
                  child: Text(
                    _displayText,
                    style: const TextStyle(
                      color: Colors.red, 
                      fontSize: 48,
                      fontWeight: FontWeight.w100,
                      fontFamily: 'CourierNew', 
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Opacity(
                opacity: _shouldShowCursor ? 1 : 0,
                child: Container(
                  width: 3,
                  height: 48,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTopControlBtn('SHIFT', Colors.yellow),
            _buildTopControlBtn('ALPHA', Colors.pinkAccent),
            _buildTopControlBtn('MODE SETUP', Colors.white),
          ],
        ),
        const SizedBox(height: 20),
        
        _buildSciRow4([
          _buildSciBtn('CALC', topL: 'SOLVE =', topLCol: Colors.yellow, topR: 'd/dx', topRCol: Colors.yellow, action: () => _onInputPressed("")),
          _buildSciBtn('∫□', topL: ':', topLCol: Colors.pinkAccent, action: () => _onInputPressed("")),
          _buildSciBtn('x⁻¹', topL: 'x!', topLCol: Colors.yellow, action: () => _onInputPressed("")),
          _buildSciBtn('log₍₎', topL: 'Σ', topLCol: Colors.yellow, action: () => _onInputPressed("log(")),
        ]),
        const SizedBox(height: 12),
        _buildSciRow6([
          _buildSciBtn('■/□', topL: 'a b/c', topLCol: Colors.yellow, action: () => _onInputPressed("")),
          _buildSciBtn('√■', topL: '³√', topLCol: Colors.yellow, action: () => _onInputPressed("√(")),
          _buildSciBtn('x²', topL: 'x³', topLCol: Colors.yellow, topR: 'DEC', topRCol: Colors.cyan, action: () => _onInputPressed("²")),
          _buildSciBtn('x■', topL: 'ˣ√■', topLCol: Colors.yellow, topR: 'HEX', topRCol: Colors.cyan, action: () => _onInputPressed("")),
          _buildSciBtn('log', topL: '10ˣ', topLCol: Colors.yellow, topR: 'BIN', topRCol: Colors.cyan, action: () => _onInputPressed("log(")),
          _buildSciBtn('ln', topL: 'eˣ', topLCol: Colors.yellow, topR: 'OCT', topRCol: Colors.cyan, action: () => _onInputPressed("ln(")),
        ]),
        const SizedBox(height: 12),
        _buildSciRow6([
          _buildSciBtn('(-)', topL: '∠', topLCol: Colors.yellow, topR: 'A', topRCol: Colors.pinkAccent, action: () => _onInputPressed("-")),
          _buildSciBtn('°\'\"', topL: '←', topLCol: Colors.yellow, topR: 'B', topRCol: Colors.pinkAccent, action: () => _onInputPressed("")),
          _buildSciBtn('hyp', topL: 'Abs', topLCol: Colors.yellow, topR: 'C', topRCol: Colors.pinkAccent, action: () => _onInputPressed("")),
          _buildSciBtn('sin', topL: 'sin⁻¹', topLCol: Colors.yellow, topR: 'D', topRCol: Colors.pinkAccent, action: () => _onInputPressed("sin(")),
          _buildSciBtn('cos', topL: 'cos⁻¹', topLCol: Colors.yellow, topR: 'E', topRCol: Colors.pinkAccent, action: () => _onInputPressed("cos(")),
          _buildSciBtn('tan', topL: 'tan⁻¹', topLCol: Colors.yellow, topR: 'F', topRCol: Colors.pinkAccent, action: () => _onInputPressed("tan(")),
        ]),
        const SizedBox(height: 12),
        _buildSciRow6([
          _buildSciBtn('RCL', topL: 'STO', topLCol: Colors.yellow, action: () => _onInputPressed("")),
          _buildSciBtn('ENG', topL: '←', topLCol: Colors.yellow, topR: 'i', topRCol: Colors.pinkAccent, action: () => _onInputPressed("")),
          _buildSciBtn('(', topL: '%', topLCol: Colors.yellow, action: () => _onInputPressed("(")),
          _buildSciBtn(')', topL: ',', topLCol: Colors.yellow, topR: 'X', topRCol: Colors.pinkAccent, action: () => _onInputPressed(")")),
          _buildSciBtn('S⇔D', topL: 'a b/c ⇔ d/c', topLCol: Colors.yellow, topR: 'Y', topRCol: Colors.pinkAccent, action: () => _onInputPressed("")),
          _buildSciBtn('M+', topL: 'M-', topLCol: Colors.yellow, topR: 'M', topRCol: Colors.pinkAccent, action: () => _onInputPressed("")),
        ]),
        const SizedBox(height: 18),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumRow(['7', '8', '9', 'DEL', 'AC'], topLabels: ['CONST', 'CONV', 'CLR', 'INS', 'OFF'], numpds: true),
              _buildNumRow(['4', '5', '6', '×', '÷'], topLabels: ['MATRIX', 'VECTOR', '', 'nPr', 'nCr'], numpds: true),
              _buildNumRow(['1', '2', '3', '+', '-'], topLabels: ['STAT', 'CMPLX', 'BASE', 'Pol', 'Rec'], numpds: true),
              _buildNumRow(['0', '.', '×10ˣ', 'Ans', '='], topLabels: ['Rnd', 'Ran#', 'π', 'DRG', ''], numpds: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopControlBtn(String text, Color textColor) {
    return Column(
      children: [
        Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12, width: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildSciRow4(List<Widget> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: buttons,
    );
  }

  Widget _buildSciRow6(List<Widget> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons,
    );
  }

  Widget _buildSciBtn(String text, {String? topL, Color? topLCol, String? topR, Color? topRCol, required VoidCallback action}) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (topL != null)
                Text(topL, style: TextStyle(color: topLCol, fontSize: 7)),
              if (topL != null && topR != null) const SizedBox(width: 3),
              if (topR != null)
                Text(topR, style: TextStyle(color: topRCol, fontSize: 7)),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            width: 40,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF222222), 
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumRow(List<String> texts, {List<String>? topLabels, bool numpds = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(texts.length, (index) {
        String text = texts[index];
        bool isSpecial = text == 'DEL' || text == 'AC';

        return Column(
          children: [
            if (topLabels != null && topLabels[index].isNotEmpty)
              Text(
                topLabels[index],
                style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 8,
                    fontWeight: FontWeight.bold),
              )
            else
              const SizedBox(height: 10), 
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                if (text == 'AC') {
                  _onACPressed();
                } else if (text == 'DEL') {
                  _onDELPressed();
                } else if (text == '=') {
                  _onEqualPressed();
                } else {
                  _onInputPressed(text);
                }
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 55,
                height: 48,
                decoration: BoxDecoration(
                  color: isSpecial
                      ? const Color(0xFF1B4323) 
                      : const Color(0xFF1A1A1A), 
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSpecial
                        ? Colors.greenAccent.withOpacity(0.5)
                        : Colors.white12,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSpecial ? Colors.greenAccent : Colors.white,
                      fontSize: numpds && !isSpecial ? 22 : 16,
                      fontWeight:
                          isSpecial ? FontWeight.w200 : FontWeight.w400,
                      fontFamily: numpds && !isSpecial ? 'Arial' : 'Courier', 
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
