import 'package:flutter/material.dart';
import 'dart:async';

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
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
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

  // --- Logic for Inputs ---
  void _onInputPressed(String input) {
    setState(() {
      if (_displayText == "0" && input != "." && !['+', '-', '×', '÷'].contains(input)) {
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
        _displayText = _displayText.substring(0, _displayText.length - 1);
        if (_displayText.isEmpty || _displayText == "-") {
          _displayText = "0";
        }
      }
    });
  }

  // --- Basic Math Evaluator (No External Libraries) ---
  void _onEqualPressed() {
    setState(() {
      try {
        String expression = _displayText.replaceAll('×', '*').replaceAll('÷', '/');
        
        // Simple logic to calculate Basic operations between two numbers
        RegExp regex = RegExp(r'([\-0-9.]+)([\+\-\*\/])([0-9.]+)');
        var match = regex.firstMatch(expression);
        
        if (match != null) {
          double num1 = double.parse(match.group(1)!);
          String op = match.group(2)!;
          double num2 = double.parse(match.group(3)!);
          double res = 0;
          
          if (op == '+') res = num1 + num2;
          if (op == '-') res = num1 - num2;
          if (op == '*') res = num1 * num2;
          if (op == '/') res = num1 / num2;
          
          _historyText = _displayText + " =";
          // Remove .0 if it's an integer
          _displayText = res.toString().replaceAll(RegExp(r'\.0$'), ''); 
        } else {
          // If the operation is too complex for basic regex or scientific
          _historyText = "Basic Ops Only";
        }
      } catch (e) {
        _displayText = "Error";
      }
    });
  }

  void _onSciPressed(String text) {
    setState(() {
      _onInputPressed(text + "(");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          // تم زيادة الحواف الجانبية هنا عشان متكونش لازقة في الشاشة
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
            _buildSmallControlBtn('SHIFT', Colors.yellow),
            _buildSmallControlBtn('ALPHA', Colors.pinkAccent),
            _buildDPadArrows(),
            _buildSmallControlBtn('MODE SETUP', Colors.white, largeText: true),
          ],
        ),
        const SizedBox(height: 15),
        _buildSciRow4([
          _buildSciBtn('CALC', topL: 'SOLVE =', topLCol: Colors.yellow, topR: 'd/dx', topRCol: Colors.yellow),
          _buildSciBtn('∫□', topL: ':', topLCol: Colors.pinkAccent),
          _buildSciBtn('x⁻¹', topL: 'x!', topLCol: Colors.yellow),
          _buildSciBtn('log₍₎', topL: 'Σ', topLCol: Colors.yellow),
        ]),
        const SizedBox(height: 12),
        _buildSciRow6([
          _buildSciBtn('■/□', topL: 'a b/c', topLCol: Colors.yellow),
          _buildSciBtn('√■', topL: '³√', topLCol: Colors.yellow),
          _buildSciBtn('x²', topL: 'x³', topLCol: Colors.yellow, topR: 'DEC', topRCol: Colors.cyan),
          _buildSciBtn('x■', topL: 'ˣ√■', topLCol: Colors.yellow, topR: 'HEX', topRCol: Colors.cyan),
          _buildSciBtn('log', topL: '10ˣ', topLCol: Colors.yellow, topR: 'BIN', topRCol: Colors.cyan),
          _buildSciBtn('ln', topL: 'eˣ', topLCol: Colors.yellow, topR: 'OCT', topRCol: Colors.cyan),
        ]),
        const SizedBox(height: 12),
        _buildSciRow6([
          _buildSciBtn('(-)', topL: '∠', topLCol: Colors.yellow, topR: 'A', topRCol: Colors.pinkAccent),
          _buildSciBtn('°\'\"', topL: '←', topLCol: Colors.yellow, topR: 'B', topRCol: Colors.pinkAccent),
          _buildSciBtn('hyp', topL: 'Abs', topLCol: Colors.yellow, topR: 'C', topRCol: Colors.pinkAccent),
          _buildSciBtn('sin', topL: 'sin⁻¹', topLCol: Colors.yellow, topR: 'D', topRCol: Colors.pinkAccent),
          _buildSciBtn('cos', topL: 'cos⁻¹', topLCol: Colors.yellow, topR: 'E', topRCol: Colors.pinkAccent),
          _buildSciBtn('tan', topL: 'tan⁻¹', topLCol: Colors.yellow, topR: 'F', topRCol: Colors.pinkAccent),
        ]),
        const SizedBox(height: 12),
        _buildSciRow6([
          _buildSciBtn('RCL', topL: 'STO', topLCol: Colors.yellow),
          _buildSciBtn('ENG', topL: '←', topLCol: Colors.yellow, topR: 'i', topRCol: Colors.pinkAccent),
          _buildSciBtn('(', topL: '%', topLCol: Colors.yellow),
          _buildSciBtn(')', topL: ',', topLCol: Colors.yellow, topR: 'X', topRCol: Colors.pinkAccent),
          _buildSciBtn('S⇔D', topL: 'a b/c ⇔ d/c', topLCol: Colors.yellow, topR: 'Y', topRCol: Colors.pinkAccent),
          _buildSciBtn('M+', topL: 'M-', topLCol: Colors.yellow, topR: 'M', topRCol: Colors.pinkAccent),
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

  Widget _buildSmallControlBtn(String topText, Color topColor, {bool largeText = false}) {
    return Column(
      children: [
        Text(topText, style: TextStyle(color: topColor, fontSize: largeText ? 9 : 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: 32,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12, width: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildDPadArrows() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12, width: 2),
        color: const Color(0xFF151515), 
      ),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: _buildDPadArrowPlaceholder('^')),
          Align(
              alignment: Alignment.bottomCenter,
              child: _buildDPadArrowPlaceholder('v')),
          Align(
              alignment: Alignment.centerLeft,
              child: _buildDPadArrowPlaceholder('<')),
          Align(
              alignment: Alignment.centerRight,
              child: _buildDPadArrowPlaceholder('>')),
        ],
      ),
    );
  }

  Widget _buildDPadArrowPlaceholder(String text) {
    return InkWell(
      onTap: () {}, 
      child: Container(
        width: 30,
        height: 30,
        color: Colors.transparent, 
        child: Center(
            child: Text(text,
                style: const TextStyle(color: Colors.white38, fontSize: 16))),
      ),
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

  // تم تصغير عرض الزراير هنا عشان تتناسب مع البادينج الجديد
  Widget _buildSciBtn(String text,
      {String? topL, Color? topLCol, String? topR, Color? topRCol}) {
    return InkWell(
      onTap: () => _onSciPressed(text),
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

  // تم تصغير عرض زراير الأرقام هنا عشان تتناسب مع البادينج الجديد
  Widget _buildNumRow(List<String> texts,
      {List<String>? topLabels, bool numpds = false}) {
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
                      fontFamily: numpds && !isSpecial
                          ? 'Arial'
                          : 'Courier', 
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
