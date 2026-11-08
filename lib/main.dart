import 'package:flutter/material.dart';

void main() {
  runApp(const MahamyApp());
}

// ألوان الوضع الفاتح
const Color lightBackground = Color(0xFFEAF4FA);
const Color lightPrimary = Color(0xFF397A9B);
const Color lightText = Color(0xFF243B53);

// ألوان الوضع الداكن
const Color darkBackground = Color(0xFF14212B);
const Color darkCards = Color(0xFF203747);
const Color darkPrimary = Color(0xFF397A9B);
const Color darkAccent = Color(0xFFA9D6E8);

// لون المهام المكتملة
const Color completedColor = Color(0xFF2EAD62);

class MahamyApp extends StatefulWidget {
  const MahamyApp({super.key});

  @override
  State<MahamyApp> createState() => _MahamyAppState();
}

class _MahamyAppState extends State<MahamyApp> {
  bool isDark = false;

  void changeTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مهامي',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightPrimary,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackground,
          foregroundColor: lightText,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPrimary,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: darkAccent,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: darkCards,
          elevation: 1,
        ),
      ),

      home: HomePage(
        isDark: isDark,
        onThemeChanged: changeTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const HomePage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> myTasks = [];
  List<bool> isFinished = [];

  final TextEditingController myController =
      TextEditingController();

  void addNewTask() {
    if (myController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      myTasks.add(myController.text.trim());
      isFinished.add(false);
      myController.clear();
    });
  }

  void deleteTask(int index) {
    setState(() {
      myTasks.removeAt(index);
      isFinished.removeAt(index);
    });
  }

  void toggleTask(int index, bool? value) {
    setState(() {
      isFinished[index] = value ?? false;
    });
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDark;

    final Color textColor =
        dark ? Colors.white : lightText;

    final Color primaryColor =
        dark ? darkAccent : lightPrimary;

    final Color inputColor =
        dark ? darkCards : Colors.white;

    int doneCount =
        isFinished.where((e) => e == true).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'مهامي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          actions: [
            IconButton(
              onPressed: widget.onThemeChanged,
              tooltip: dark ? 'الوضع الفاتح' : 'الوضع الداكن',
              icon: Icon(
                dark ? Icons.light_mode : Icons.dark_mode,
                size: 25,
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: myController,
                      onSubmitted: (_) => addNewTask(),
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'اكتب مهمة جديدة...',
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: addNewTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor:
                          dark ? darkBackground : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                    ),
                    child: const Text(
                      'إضافة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عندك ${myTasks.length} مهمة',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    'أنجزت $doneCount',
                    style: TextStyle(
                      color: completedColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: myTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 70,
                            color: primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'يوم جديد وفرصة جديدة!',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أضف أول مهمة وابدأ إنجاز يومك',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: myTasks.length,
                      itemBuilder: (context, index) {
                        final bool finished =
                            isFinished[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: finished,
                              activeColor: completedColor,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                toggleTask(index, value);
                              },
                            ),
                            title: Text(
                              myTasks[index],
                              style: TextStyle(
                                color: finished
                                    ? completedColor
                                    : textColor,
                                fontWeight: finished
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                deleteTask(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
