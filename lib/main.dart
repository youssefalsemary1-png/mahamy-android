
import 'package:flutter/material.dart';

void main() {
  runApp(const MahamyApp());
}

const Color backgroundColor = Color(0xFFF7F3EA);
const Color textColor = Color(0xFF26334A);
const Color primaryColor = Color(0xFFA8DCCB);
const Color accentColor = Color(0xFFC9B9DF);

class MahamyApp extends StatelessWidget {
  const MahamyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مهامي',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    int doneCount =
        isFinished.where((e) => e == true).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            "مهامي",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          backgroundColor: backgroundColor,
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            // إضافة مهمة جديدة
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: myController,
                      onSubmitted: (_) => addNewTask(),
                      decoration: InputDecoration(
                        hintText: "اكتب مهمة جديدة...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
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
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 18,
                      ),
                    ),
                    child: const Text("إضافة"),
                  ),
                ],
              ),
            ),

            // عداد المهام
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text("عندك ${myTasks.length} مهمة"),
                  Text("أنجزت $doneCount"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // قائمة المهام
            Expanded(
              child: myTasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 65,
                            color: accentColor,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "يوم جديد وفرصة جديدة!",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "أضف أول مهمة وابدأ إنجاز يومك",
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
                        return Card(
                          color: Colors.white,
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
                              value: isFinished[index],
                              activeColor: primaryColor,
                              checkColor: textColor,
                              onChanged: (value) {
                                toggleTask(index, value);
                              },
                            ),
                            title: Text(
                              myTasks[index],
                              style: TextStyle(
                                color: textColor,
                                decoration: isFinished[index]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
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
