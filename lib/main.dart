import 'dart:async';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'خاتم', 
      theme: ThemeData(fontFamily: 'Cairo'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const TasbeehScreen(),
    );
  }
}

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  _TasbeehScreenState createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> with AutomaticKeepAliveClientMixin {
  bool isFirstText = true;
  Timer? _timer;

  int mainCounter = 0;
  int currentIndex = 0;
  bool isDarkMode = true; 

  Map<String, int> totalCounts = {};
  Map<String, int> dailyCounts = {};
  Map<String, int> monthlyCounts = {};
  String lastDate = "";
  String lastMonth = "";

  List<Map<String, dynamic>> dhikrList = [
    {"text": "استغفر الله العظيم", "target": 33},
    {"text": "سبحان الله", "target": 33},
    {"text": "سبحان الله وبحمده سبحان الله العظيم", "target": 33},
    {"text": "الحمد لله", "target": 33},
    {"text": "الله اكبر", "target": 33},
    {"text": "الله اكبر ولله الحمد", "target": 33},
    {"text": "اللهم صلِّ علي محمد وآل محمد", "target": 33},
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadSavedData(); 
    
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        isFirstText = !isFirstText;
      });
    });
  }

  void _checkAndResetDates() {
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";
    String thisMonth = "${now.year}-${now.month}";
    bool changed = false;

    if (lastDate != today) {
      dailyCounts.clear();
      lastDate = today;
      changed = true;
    }
    if (lastMonth != thisMonth) {
      monthlyCounts.clear();
      lastMonth = thisMonth;
      changed = true;
    }
    if (changed) saveData();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mainCounter = prefs.getInt('counter') ?? 0;
      currentIndex = prefs.getInt('index') ?? 0;
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
      
      totalCounts = Map<String, int>.from(jsonDecode(prefs.getString('totalCounts') ?? '{}'));
      dailyCounts = Map<String, int>.from(jsonDecode(prefs.getString('dailyCounts') ?? '{}'));
      monthlyCounts = Map<String, int>.from(jsonDecode(prefs.getString('monthlyCounts') ?? '{}'));
      lastDate = prefs.getString('lastDate') ?? "";
      lastMonth = prefs.getString('lastMonth') ?? "";
      
      _checkAndResetDates();

      String? savedList = prefs.getString('dhikrList');
      if (savedList != null) {
        List<dynamic> decodedList = jsonDecode(savedList);
        dhikrList = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', mainCounter);
    prefs.setInt('index', currentIndex);
    prefs.setBool('isDarkMode', isDarkMode);
    prefs.setString('dhikrList', jsonEncode(dhikrList));
    
    prefs.setString('totalCounts', jsonEncode(totalCounts));
    prefs.setString('dailyCounts', jsonEncode(dailyCounts));
    prefs.setString('monthlyCounts', jsonEncode(monthlyCounts));
    prefs.setString('lastDate', lastDate);
    prefs.setString('lastMonth', lastMonth);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void incrementCounter() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click); 

    setState(() {
      mainCounter++;
      
      _checkAndResetDates();
      String text = dhikrList[currentIndex]["text"];
      totalCounts[text] = (totalCounts[text] ?? 0) + 1;
      dailyCounts[text] = (dailyCounts[text] ?? 0) + 1;
      monthlyCounts[text] = (monthlyCounts[text] ?? 0) + 1;

      if (mainCounter >= dhikrList[currentIndex]["target"]) {
        currentIndex = (currentIndex + 1) % dhikrList.length;
        mainCounter = 0; 
        HapticFeedback.heavyImpact(); 
      }
      saveData(); 
    });
  }

  void showTotalStats() {
    Color boxColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color borderColor = isDarkMode ? Colors.white30 : Colors.black26;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("الإحصائيات", style: TextStyle(color: textColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dhikrList.length,
              itemBuilder: (context, index) {
                String text = dhikrList[index]["text"];
                int daily = dailyCounts[text] ?? 0;
                int monthly = monthlyCounts[text] ?? 0;
                int total = totalCounts[text] ?? 0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      if (!isDarkMode) BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("اليوم: $daily", style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text("الشهر: $monthly", style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text("الكلي: $total", style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void deleteDhikr(int index) {
    if (dhikrList.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب ترك ذكر واحد على الأقل في القائمة.")),
      );
      return;
    }

    setState(() {
      dhikrList.removeAt(index);
      if (currentIndex >= dhikrList.length) {
        currentIndex = 0;
        mainCounter = 0;
      } else if (currentIndex == index) {
        mainCounter = 0;
      }
      saveData(); 
    });
    
    Navigator.pop(context);
    showDhikrMenu();
  }

  void addNewDhikr(BuildContext context) {
    TextEditingController textController = TextEditingController();
    TextEditingController targetController = TextEditingController(text: "33");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text("إضافة ذكر جديد", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                autofocus: true,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "اكتب الذكر هنا",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.black54)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "الرقم المستهدف (الهدف)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.black54)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  setState(() {
                    int target = int.tryParse(targetController.text) ?? 33;
                    dhikrList.add({
                      "text": textController.text.trim(),
                      "target": target > 0 ? target : 33
                    });
                    saveData(); 
                  });
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                  showDhikrMenu(); 
                }
              },
              child: const Text("إضافة", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void editTarget(BuildContext context, int index) {
    TextEditingController controller = TextEditingController(
      text: dhikrList[index]["target"].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text("تعديل هدف (${dhikrList[index]['text']})", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.black54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  int newTarget = int.tryParse(controller.text) ?? 33;
                  if (newTarget > 0) {
                    dhikrList[index]["target"] = newTarget;
                    saveData(); 
                  }
                });
                Navigator.pop(context); 
                Navigator.pop(context); 
                showDhikrMenu(); 
              },
              child: const Text("حفظ", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void showDhikrMenu() {
    Color boxColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color borderColor = isDarkMode ? Colors.white30 : Colors.black26;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65, 
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "قائمة الأذكار",
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: isDarkMode ? Colors.white24 : Colors.black26, thickness: 1),
                    
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 80), 
                        itemCount: dhikrList.length,
                        itemBuilder: (context, index) {
                          bool isSelected = index == currentIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green.withOpacity(0.15) : boxColor,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                if (!isDarkMode) BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)
                              ]
                            ),
                            child: ListTile(
                              title: Text(
                                dhikrList[index]["text"],
                                style: TextStyle(
                                  color: isSelected ? Colors.green[600] : (isDarkMode ? Colors.white : Colors.black), 
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                ),
                              ),
                              subtitle: Text(
                                "الرقم المستهدف: ${dhikrList[index]["target"]}",
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 22),
                                    onPressed: () => editTarget(context, index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
                                    onPressed: () => deleteDhikr(index),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  currentIndex = index;
                                  mainCounter = 0; 
                                  saveData(); 
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => addNewDhikr(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          if (!isDarkMode) BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)
                        ]
                      ),
                      child: Icon(Icons.add, color: textColor, size: 30),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Color bgColor = isDarkMode ? Colors.black : Colors.grey[50]!;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color boxColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color borderColor = isDarkMode ? Colors.white30 : Colors.black26;

    return Scaffold(
      backgroundColor: bgColor, 
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode, 
                      color: isDarkMode ? Colors.amber : Colors.indigo
                    ),
                    onPressed: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                        saveData(); 
                      });
                    },
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        if (!isDarkMode) BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)
                      ]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600), 
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: Text(
                            isFirstText ? "مَا نَقَصَ مَالٌ مِنْ صَدَقَةٍ" : "الصدقة جسر إلى الجَنَّةِ",
                            key: ValueKey<bool>(isFirstText),
                            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
            ),

            const SizedBox(height: 35),

            // التعديل الأول: مستطيل بحواف دائرية للصورة زي الصورة المرفقة
            Container(
              height: 210,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: Colors.transparent, 
                border: Border.all(color: borderColor), 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [
                  if (!isDarkMode) BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 1) 
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19), 
                child: Image.asset(
                  'gaza.png', 
                  fit: BoxFit.cover, 
                  errorBuilder: (context, error, stackTrace) {
                     return Center(
                       child: Icon(Icons.mosque, size: 80, color: isDarkMode ? Colors.white30 : Colors.black26),
                     );
                  }
                ),
              ),
            ),

            const Expanded(child: SizedBox()), 

            GestureDetector(
              onTap: showDhikrMenu, 
              onLongPress: showDhikrMenu, 
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Text(
                  dhikrList[currentIndex]["text"],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 30, fontWeight: FontWeight.bold, height: 1.4),
                ),
              ),
            ),

            const Expanded(child: SizedBox()), 

            // التعديل التاني: العداد جوه إطار مستطيل زواياه دائرية وبصيغة (0000)
            GestureDetector(
              onTap: () {
                HapticFeedback.vibrate(); 
                setState(() {
                  mainCounter = 0;
                  saveData(); 
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم تصفير العداد"), duration: Duration(seconds: 1)),
                );
              },
              onLongPress: showTotalStats, 
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.transparent : Colors.white,
                  border: Border.all(color: borderColor), 
                  borderRadius: BorderRadius.circular(20), 
                  boxShadow: [
                    if (!isDarkMode) BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 1) 
                  ]
                ),
                child: Text(
                  mainCounter.toString().padLeft(4, '0'), // يخلي الرقم 0000
                  style: TextStyle(color: textColor, fontSize: 60, letterSpacing: 6, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // زرار الضغط متسنتر في النص
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: incrementCounter,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isDarkMode 
                          ? [Colors.grey[800]!, Colors.black] 
                          : [Colors.white, Colors.grey[300]!],
                      radius: 0.85,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.15),
                        spreadRadius: 3,
                        blurRadius: 15,
                        offset: const Offset(0, 5)
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 55),
          ],
        ),
      ),
    );
  }
}
