hereimport 'package:flutter/material.dart';
import 'dart:async'; // For cursor blinking

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
  // State variables for Display
  String _displayText = "0"; // Current input/result
  String _historyText = ""; // Equation history
  bool _shouldShowCursor = true; // Cursor blink state
  Timer? _cursorTimer; // Cursor blink timer

  @override
  void initState() {
    super.initState();
    // Power is ON by default, start cursor blinking
    _startCursorBlink();
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    super.dispose();
  }

  // --- Display Logic ---

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _shouldShowCursor = !_shouldShowCursor;
        });
      }
    });
  }

  // --- Keypad Logic (Basic for now) ---

  void _onNumberPressed(String number) {
    setState(() {
      if (_displayText == "0") {
        _displayText = number;
      } else {
        _displayText += number;
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
        if (_displayText.isEmpty) {
          _displayText = "0";
        }
      }
    });
  }

  // Handle other scientific functions later
  void _onSciPressed(String text) {
    // Basic logic just for show
    setState(() {
      _historyText = text + " ";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            children: [
              // 1. Top Zikr Banner
              _buildTopBanner(),
              const SizedBox(height: 15),

              // 2. Display Screen (Stateful, Power Always ON)
              _buildDisplayScreen(),
              const SizedBox(height: 20),

              // 3. Calculator Keypad (Stateful, with Logic)
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
            fontFamily: 'Arial', // Fallback font
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
        color: const Color(0xFF010101), // Very dark background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.5), width: 1), // Light red border glow
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
          // History line (Small text)
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
          // Main Input Line with Cursor
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _displayText,
                style: const TextStyle(
                  color: Colors.red, // Scientific look (like image_1.png)
                  fontSize: 48,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'CourierNew', // Typo look
                ),
                maxLines: 1,
              ),
              // Blinking Cursor
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
        // 3.1 Control Row (SHIFT, ALPHA, Arrows, MODE SETUP) - ON button removed
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSmallControlBtn('SHIFT', Colors.yellow),
            _buildSmallControlBtn('ALPHA', Colors.pinkAccent),
            // Correct D-Pad (Arrows) implementation as in image_1.png
            _buildDPadArrows(),
            _buildSmallControlBtn('MODE SETUP', Colors.white, largeText: true),
            // ON button removed
          ],
        ),
        const SizedBox(height: 10),

        // 3.2 Scientific Function Rows
        _buildSciRow4([
          _buildSciBtn('CALC', topL: 'SOLVE =', topLCol: Colors.yellow, topR: 'd/dx', topRCol: Colors.yellow),
          _buildSciBtn('∫□', topL: ':', topLCol: Colors.pinkAccent),
          _buildSciBtn('x⁻¹', topL: 'x!', topLCol: Colors.yellow),
          _buildSciBtn('log₍₎', topL: 'Σ', topLCol: Colors.yellow),
        ]),
        const SizedBox(height: 8),
        _buildSciRow6([
          _buildSciBtn('■/□', topL: 'a b/c', topLCol: Colors.yellow),
          _buildSciBtn('√■', topL: '³√', topLCol: Colors.yellow),
          _buildSciBtn('x²', topL: 'x³', topLCol: Colors.yellow, topR: 'DEC', topRCol: Colors.cyan),
          _buildSciBtn('x■', topL: 'ˣ√■', topLCol: Colors.yellow, topR: 'HEX', topRCol: Colors.cyan),
          _buildSciBtn('log', topL: '10ˣ', topLCol: Colors.yellow, topR: 'BIN', topRCol: Colors.cyan),
          _buildSciBtn('ln', topL: 'eˣ', topLCol: Colors.yellow, topR: 'OCT', topRCol: Colors.cyan),
        ]),
        const SizedBox(height: 8),
        _buildSciRow6([
          _buildSciBtn('(-)', topL: '∠', topLCol: Colors.yellow, topR: 'A', topRCol: Colors.pinkAccent),
          _buildSciBtn('°\'\"', topL: '←', topLCol: Colors.yellow, topR: 'B', topRCol: Colors.pinkAccent),
          _buildSciBtn('hyp', topL: 'Abs', topLCol: Colors.yellow, topR: 'C', topRCol: Colors.pinkAccent),
          _buildSciBtn('sin', topL: 'sin⁻¹', topLCol: Colors.yellow, topR: 'D', topRCol: Colors.pinkAccent),
          _buildSciBtn('cos', topL: 'cos⁻¹', topLCol: Colors.yellow, topR: 'E', topRCol: Colors.pinkAccent),
          _buildSciBtn('tan', topL: 'tan⁻¹', topLCol: Colors.yellow, topR: 'F', topRCol: Colors.pinkAccent),
        ]),
        const SizedBox(height: 8),
        _buildSciRow6([
          _buildSciBtn('RCL', topL: 'STO', topLCol: Colors.yellow),
          _buildSciBtn('ENG', topL: '←', topLCol: Colors.yellow, topR: 'i', topRCol: Colors.pinkAccent),
          _buildSciBtn('(', topL: '%', topLCol: Colors.yellow),
          _buildSciBtn(')', topL: ',', topLCol: Colors.yellow, topR: 'X', topRCol: Colors.pinkAccent),
          _buildSciBtn('S⇔D', topL: 'a b/c ⇔ d/c', topLCol: Colors.yellow, topR: 'Y', topRCol: Colors.pinkAccent),
          _buildSciBtn('M+', topL: 'M-', topLCol: Colors.yellow, topR: 'M', topRCol: Colors.pinkAccent),
        ]),
        const SizedBox(height: 15),

        // 3.3 Numpad Rows (Larger, more rounded, functional AC/DEL/Numbers)
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

  // --- Helper Widgets for Keypad ---

  Widget _buildSmallControlBtn(String topText, Color topColor, {bool largeText = false}) {
    return Column(
      children: [
        Text(topText, style: TextStyle(color: topColor, fontSize: largeText ? 10 : 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: 35,
          height: 25,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white12, width: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildDPadArrows() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12, width: 2),
        color: const Color(0xFF151515), // D-Pad color like image_1.png
      ),
      child: Stack(
        children: [
          // Basic Arrow Placeholders (since we don't use custom icons yet)
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
      onTap: () {}, // Arrow logic later
      child: Container(
        width: 30,
        height: 30,
        color: Colors.transparent, // Expand tap area
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
                Text(topL, style: TextStyle(color: topLCol, fontSize: 8)),
              if (topL != null && topR != null) const SizedBox(width: 5),
              if (topR != null)
                Text(topR, style: TextStyle(color: topRCol, fontSize: 8)),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            width: 45,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFF222222), // Sci btn color like image_1.png
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              const SizedBox(height: 10), // Placeholder to keep alignment
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                if (text == 'AC') {
                  _onACPressed();
                } else if (text == 'DEL') {
                  _onDELPressed();
                } else if (int.tryParse(text) != null || text == '.') {
                  _onNumberPressed(text);
                }
              },
              child: Container(
                // Larger and more rounded buttons like image_1.png
                width: 65,
                height: 50,
                decoration: BoxDecoration(
                  color: isSpecial
                      ? const Color(0xFF1B4323) // Green for AC/DEL
                      : const Color(0xFF1A1A1A), // Dark for numbers
                  borderRadius: BorderRadius.circular(30),
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
                      fontSize: numpds && !isSpecial ? 24 : 18,
                      fontWeight:
                          isSpecial ? FontWeight.w200 : FontWeight.w400,
                      fontFamily: numpds && !isSpecial
                          ? 'Arial'
                          : 'Courier', // Numpad special family
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
