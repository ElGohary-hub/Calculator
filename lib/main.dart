import 'package:flutter/material.dart';

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

class CalculatorHome extends StatelessWidget {
  const CalculatorHome({super.key});

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

              // 2. Display Screen with Red Border Effect
              _buildDisplayScreen(),
              const SizedBox(height: 20),

              // 3. Calculator Keypad
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
            fontFamily: 'Arial', // Fallback font, adjust if you have a specific Arabic font
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
        color: const Color(0xFF0A0A0A), // Very dark grey/black
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade900, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      // Empty container for now, logic will be added later
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        // Top row (SHIFT, ALPHA, Arrows, MODE, ON)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSmallControlBtn('SHIFT', Colors.yellow, '', Colors.transparent),
            _buildSmallControlBtn('ALPHA', Colors.pinkAccent, '', Colors.transparent),
            // Placeholder for D-Pad
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 2),
                color: const Color(0xFF151515),
              ),
              child: const Center(child: Text('Arrows', style: TextStyle(color: Colors.white38, fontSize: 10))),
            ),
            _buildSmallControlBtn('MODE SETUP', Colors.white, '', Colors.transparent),
            _buildSmallControlBtn('ON', Colors.white, '', Colors.transparent),
          ],
        ),
        const SizedBox(height: 10),

        // Scientific Function Rows
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

        // Numpad Rows
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumRow(['7', '8', '9', 'DEL', 'AC'], topLabels: ['CONST', 'CONV', 'CLR', 'INS', 'OFF']),
              _buildNumRow(['4', '5', '6', '×', '÷'], topLabels: ['MATRIX', 'VECTOR', '', 'nPr', 'nCr']),
              _buildNumRow(['1', '2', '3', '+', '-'], topLabels: ['STAT', 'CMPLX', 'BASE', 'Pol', 'Rec']),
              _buildNumRow(['0', '.', '×10ˣ', 'Ans', '='], topLabels: ['Rnd', 'Ran#', 'π', 'DRG', '']),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets for Building Buttons ---

  Widget _buildSmallControlBtn(String topText, Color topColor, String mainText, Color mainColor) {
    return Column(
      children: [
        Text(topText, style: TextStyle(color: topColor, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildSciBtn(String text, {String? topL, Color? topLCol, String? topR, Color? topRCol}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topL != null) Text(topL, style: TextStyle(color: topLCol, fontSize: 8)),
            if (topL != null && topR != null) const SizedBox(width: 5),
            if (topR != null) Text(topR, style: TextStyle(color: topRCol, fontSize: 8)),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          width: 45,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
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
    );
  }

  Widget _buildNumRow(List<String> texts, {List<String>? topLabels}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(texts.length, (index) {
        String text = texts[index];
        bool isGreen = text == 'DEL' || text == 'AC';
        
        return Column(
          children: [
            if (topLabels != null && topLabels[index].isNotEmpty)
              Text(
                topLabels[index],
                style: const TextStyle(color: Colors.yellow, fontSize: 10),
              )
            else
              const SizedBox(height: 12), // Placeholder to keep alignment
            const SizedBox(height: 4),
            Container(
              width: 60,
              height: 45,
              decoration: BoxDecoration(
                color: isGreen ? const Color(0xFF1B4323) : const Color(0xFF151515),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isGreen ? Colors.greenAccent.withOpacity(0.5) : Colors.white12,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isGreen ? Colors.greenAccent : Colors.white,
                    fontSize: 20,
                    fontWeight: isGreen ? FontWeight.normal : FontWeight.w300,
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
