
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeNotifications();

  runApp(const MahamyApp());
}

// تهيئة الإشعارات
Future<void> initializeNotifications() async {
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

  await notifications.initialize(settings);

  final androidPlugin = notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.requestNotificationsPermission();

  await scheduleAllNotifications();
}

// جدولة الإشعارات
Future<void> scheduleAllNotifications() async {
  await notifications.cancelAll();

  const AndroidNotificationDetails hourlyDetails =
      AndroidNotificationDetails(
    'hourly_reminders',
    'تذكير الصلاة على النبي',
    channelDescription: 'تذكير متكرر بالصلاة على النبي ﷺ',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails hourlyNotificationDetails =
      NotificationDetails(android: hourlyDetails);

  await notifications.periodicallyShow(
    1,
    'تذكير جميل ❤️',
    'هل صليت على النبي اليوم؟ ﷺ',
    RepeatInterval.hourly,
    hourlyNotificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );

  final List<Map<String, String>> reminders = [
    {
      'title': 'ابدأ يومك بنية جميلة 🌅',
      'body': 'لا تدع يومك يمر دون إنجاز شيء مفيد.'
    },
    {
      'title': 'خطوة جديدة نحو الأفضل',
      'body': 'افعل اليوم شيئًا كنت تؤجله أو تظن أنك لا تستطيع إنجازه.'
    },
    {
      'title': 'اهتم بصحتك 💧',
      'body': 'خذ استراحة قصيرة واشرب كوبًا من الماء.'
    },
    {
      'title': 'حافظ على صلاتك',
      'body': 'هل أديت فروضك اليوم؟ لا تجعل انشغالك ينسيك صلاتك.'
    },
    {
      'title': 'وقتك ثمين',
      'body': 'امنح نفسك بعض الوقت بعيدًا عن الهاتف.'
    },
    {
      'title': 'طوّر نفسك 📚',
      'body': 'تعلم معلومة جديدة أو اقرأ شيئًا ينفعك.'
    },
    {
      'title': 'الحمد لله دائمًا',
      'body': 'تذكر نعمة جميلة في حياتك واحمد الله عليها.'
    },
    {
      'title': 'راجع يومك 🌙',
      'body': 'ما أفضل شيء فعلته اليوم؟ وما الذي يمكنك تحسينه غدًا؟'
    },
    {
      'title': 'استعد ليوم جديد',
      'body': 'جهّز ما تحتاجه للغد، ولا تنسَ أن تمنح نفسك الراحة.'
    },
  ];

  const List<int> reminderHours = [
    7, 9, 11, 13, 15, 17, 19, 21, 22
  ];

  final now = tz.TZDateTime.now(tz.local);

  for (int i = 0; i < reminders.length; i++) {
    final hour = reminderHours[i];

    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    if (!scheduledTime.isAfter(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await notifications.zonedSchedule(
      100 + i,
      reminders[i]['title']!,
      reminders[i]['body']!,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'التذكيرات اليومية',
          channelDescription: 'رسائل تحفيزية وتذكيرات يومية',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

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

  // الجمل المرتبطة بكل مهمة
  List<String> taskFeelings = [];

  // تاريخ كتابة كل جملة
  List<String> feelingDates = [];

  final TextEditingController myController =
      TextEditingController();

  static const String tasksStorageKey = 'mahamy_saved_tasks';

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // استرجاع المهام والجمل المحفوظة
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(tasksStorageKey);

    if (savedData == null) return;

    try {
      final List<dynamic> decodedData = jsonDecode(savedData);

      final loadedTasks = <String>[];
      final loadedFinished = <bool>[];
      final loadedFeelings = <String>[];
      final loadedDates = <String>[];

      for (final item in decodedData) {
        if (item is Map) {
          loadedTasks.add(item['task']?.toString() ?? '');
          loadedFinished.add(item['finished'] == true);
          loadedFeelings.add(item['feeling']?.toString() ?? '');
          loadedDates.add(item['feelingDate']?.toString() ?? '');
        }
      }

      if (!mounted) return;

      setState(() {
        myTasks = loadedTasks;
        isFinished = loadedFinished;
        taskFeelings = loadedFeelings;
        feelingDates = loadedDates;
      });
    } catch (e) {
      debugPrint('خطأ في استرجاع المهام: $e');
    }
  }

  // حفظ جميع البيانات على الجهاز
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = List.generate(myTasks.length, (index) {
      return {
        'task': myTasks[index],
        'finished': isFinished[index],
        'feeling': taskFeelings[index],
        'feelingDate': feelingDates[index],
      };
    });

    await prefs.setString(
      tasksStorageKey,
      jsonEncode(savedData),
    );
  }

  void addNewTask() {
    final task = myController.text.trim();

    if (task.isEmpty) return;

    setState(() {
      myTasks.add(task);
      isFinished.add(false);
      taskFeelings.add('');
      feelingDates.add('');
      myController.clear();
    });

    saveTasks();
  }

  void deleteTask(int index) {
    if (index < 0 || index >= myTasks.length) return;

    setState(() {
      myTasks.removeAt(index);
      isFinished.removeAt(index);
      taskFeelings.removeAt(index);
      feelingDates.removeAt(index);
    });

    saveTasks();
  }

  void toggleTask(int index, bool? value) {
    if (index < 0 || index >= isFinished.length) return;

    setState(() {
      isFinished[index] = value ?? false;
    });

    saveTasks();
  }

  // إضافة أو تعديل جملة المهمة
  Future<void> editTaskFeeling(int index) async {
    if (index < 0 || index >= taskFeelings.length) return;

    final controller = TextEditingController(
      text: taskFeelings[index],
    );

    String? result;

    try {
      result = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text(
                'جملة من قلبك ❤️',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اكتب شعورك تجاه هذه المهمة، حتى لو بكلمة واحدة.',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    maxLength: 120,
                    decoration: InputDecoration(
                      hintText: 'مثلاً: كنت خايف بس عملتها...',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      controller.text.trim(),
                    );
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }

    if (!mounted || result == null) return;
    if (index >= taskFeelings.length) return;

    setState(() {
      taskFeelings[index] = result!;
      feelingDates[index] = result.isEmpty
          ? ''
          : DateTime.now().toIso8601String();
    });

    await saveTasks();
  }

  // فتح صفحة كل الجمل والتجارب
  void openFeelingsHistory() {
    final entries = <Map<String, String>>[];

    for (int i = 0; i < myTasks.length; i++) {
      if (taskFeelings[i].trim().isNotEmpty) {
        entries.add({
          'task': myTasks[i],
          'feeling': taskFeelings[i],
          'date': feelingDates[i],
        });
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FeelingsHistoryPage(entries: entries);
        },
      ),
    );
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDark;

    final Color textColor = dark ? Colors.white : lightText;
    final Color primaryColor = dark ? darkAccent : lightPrimary;
    final Color inputColor = dark ? darkCards : Colors.white;

    final int doneCount =
        isFinished.where((e) => e == true).length;

    final int phrasesCount =
        taskFeelings.where((e) => e.trim().isNotEmpty).length;

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
              onPressed: openFeelingsHistory,
              tooltip: 'كلماتي وتجربتي',
              icon: const Icon(
                Icons.favorite_outline,
                size: 25,
              ),
            ),
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
                          borderRadius: BorderRadius.circular(14),
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

            // ملخص المهام والجمل
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عندك ${myTasks.length} مهمة',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    'أنجزت $doneCount',
                    style: const TextStyle(
                      color: completedColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (phrasesCount > 0)
              Padding(
                padding: const EdgeInsets.only(
                  right: 15,
                  left: 15,
                  top: 8,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'كتبت $phrasesCount جملة من قلبك ❤️',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
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
                        final bool finished = isFinished[index];
                        final String feeling = taskFeelings[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
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
                            subtitle: feeling.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '❤️ $feeling',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: feeling.isEmpty
                                      ? 'اكتب شعورك'
                                      : 'تعديل جملتك',
                                  icon: Icon(
                                    feeling.isEmpty
                                        ? Icons.edit_note
                                        : Icons.favorite,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    editTaskFeeling(index);
                                  },
                                ),
                                IconButton(
                                  tooltip: 'حذف المهمة',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    deleteTask(index);
                                  },
                                ),
                              ],
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

// صفحة كلماتي وتجربتي
class FeelingsHistoryPage extends StatelessWidget {
  final List<Map<String, String>> entries;

  const FeelingsHistoryPage({
    super.key,
    required this.entries,
  });

  String formatDate(String dateValue) {
    final date = DateTime.tryParse(dateValue);

    if (date == null) return '';

    final localDate = date.toLocal();

    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final textColor = dark ? Colors.white : lightText;
    final primaryColor = dark ? darkAccent : lightPrimary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'كلماتي وتجربتي',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 75,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'هنا ستجد كلماتك وتجاربك ❤️',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اكتب جملة صغيرة بجانب أي مهمة، وستظهر هنا لتعود إليها وقتما تحب.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 5,
                      bottom: 10,
                    ),
                    child: Text(
                      'كل كلمة كتبتها جزء من تجربتك.',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...entries.reversed.map((entry) {
                    final date = formatDate(entry['date'] ?? '');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: primaryColor,
                                  size: 19,
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    entry['task'] ?? '',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              entry['feeling'] ?? '',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                              ),
                            ),
                            if (date.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'تاريخ الكتابة: $date',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.65),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
