import 'package:flutter/material.dart';

// --- MAIN ENTRY POINT ---
void main() {
  runApp(const FitnessApp());
}

// --- DATA MODEL ---
class Workout {
  final String id;
  String title;
  int durationMinutes;
  int calories;
  DateTime date;

  Workout({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.calories,
    required this.date,
  });
}

// --- APP WIDGET ---
class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness CRUD',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
        // Стилизация диалоговых окон
        dialogTheme: const DialogTheme(
          backgroundColor: Color(0xFF252526),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- DASHBOARD SCREEN (STATEFUL FOR CRUD) ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Начальные данные (Fake Data)
  final List<Workout> _workouts = [
    Workout(id: '1', title: "Бег на улице", durationMinutes: 45, calories: 320, date: DateTime.now().subtract(const Duration(hours: 2))),
    Workout(id: '2', title: "Силовая", durationMinutes: 60, calories: 410, date: DateTime.now().subtract(const Duration(days: 1))),
    Workout(id: '3', title: "Йога", durationMinutes: 30, calories: 120, date: DateTime.now().subtract(const Duration(days: 2))),
  ];

  // CREATE / UPDATE Logic
  void _showWorkoutDialog({Workout? existingWorkout}) {
    final titleController = TextEditingController(text: existingWorkout?.title ?? '');
    final durationController = TextEditingController(text: existingWorkout?.durationMinutes.toString() ?? '');
    final kcalController = TextEditingController(text: existingWorkout?.calories.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingWorkout == null ? 'Новая тренировка' : 'Редактировать'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Название (напр. Бег)', filled: true, fillColor: Colors.black12),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Мин', filled: true, fillColor: Colors.black12),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: kcalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ккал', filled: true, fillColor: Colors.black12),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          // Кнопка удаления (только при редактировании)
          if (existingWorkout != null)
            TextButton(
              onPressed: () {
                _deleteWorkout(existingWorkout.id);
                Navigator.pop(ctx);
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) return;
              
              final String title = titleController.text;
              final int duration = int.tryParse(durationController.text) ?? 0;
              final int calories = int.tryParse(kcalController.text) ?? 0;

              if (existingWorkout == null) {
                // CREATE
                _addWorkout(title, duration, calories);
              } else {
                // UPDATE
                _updateWorkout(existingWorkout.id, title, duration, calories);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addWorkout(String title, int duration, int kcal) {
    setState(() {
      _workouts.insert(0, Workout(
        id: DateTime.now().toIso8601String(), // Простая генерация ID
        title: title,
        durationMinutes: duration,
        calories: kcal,
        date: DateTime.now(),
      ));
    });
  }

  void _updateWorkout(String id, String title, int duration, int kcal) {
    setState(() {
      final index = _workouts.indexWhere((w) => w.id == id);
      if (index != -1) {
        _workouts[index] = Workout(
          id: id,
          title: title,
          durationMinutes: duration,
          calories: kcal,
          date: _workouts[index].date, // Оставляем старую дату
        );
      }
    });
  }

  void _deleteWorkout(String id) {
    setState(() {
      _workouts.removeWhere((w) => w.id == id);
    });
  }

  // Подсчет статистики для виджетов
  int get totalKcal => _workouts.fold(0, (sum, item) => sum + item.calories);
  int get totalMinutes => _workouts.fold(0, (sum, item) => sum + item.durationMinutes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Сегодня", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {},
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        onPressed: () => _showWorkoutDialog(),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Кольца активности
            Center(child: ActivityRings(percent: (totalKcal / 1000).clamp(0.0, 1.0))),
            const SizedBox(height: 30),
            
            // Статистика (Динамическая)
            const Text("Статистика", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: StatCard(title: "Тренировок", value: "${_workouts.length}", icon: Icons.fitness_center, color: Colors.orange)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(title: "Ккал", value: "$totalKcal", icon: Icons.local_fire_department, color: Colors.red)),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Список тренировок
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Список тренировок", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (_workouts.isEmpty) 
                   const Text("Нет записей", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 15),
            
            // Генерация списка (Read)
            ..._workouts.map((workout) {
              return Dismissible(
                key: Key(workout.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteWorkout(workout.id),
                child: GestureDetector(
                  onTap: () => _showWorkoutDialog(existingWorkout: workout),
                  child: WorkoutTile(workout: workout),
                ),
              );
            }).toList(),
            
            // Отступ снизу, чтобы FAB не закрывал контент
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Обзор'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Зал'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

// --- WIDGETS ---

class ActivityRings extends StatelessWidget {
  final double percent;
  const ActivityRings({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Внешнее кольцо (Ккал - динамическое)
          SizedBox(
            width: 200, height: 200,
            child: CircularProgressIndicator(value: percent, strokeWidth: 15, color: Colors.red, backgroundColor: Colors.red.withOpacity(0.2)),
          ),
          // Среднее кольцо (Статика для примера)
          SizedBox(
            width: 160, height: 160,
            child: CircularProgressIndicator(value: 0.5, strokeWidth: 15, color: Colors.green, backgroundColor: Colors.green.withOpacity(0.2)),
          ),
          // Внутреннее кольцо
          SizedBox(
            width: 120, height: 120,
            child: CircularProgressIndicator(value: 0.8, strokeWidth: 15, color: Colors.blue, backgroundColor: Colors.blue.withOpacity(0.2)),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, color: Colors.yellow, size: 30),
              Text("Активность", style: TextStyle(fontWeight: FontWeight.bold))
            ],
          )
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class WorkoutTile extends StatelessWidget {
  final Workout workout;

  const WorkoutTile({super.key, required this.workout});

  String _formatDate(DateTime dt) {
    return "${dt.day}.${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workout.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_formatDate(workout.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${workout.durationMinutes} мин", style: const TextStyle(color: Colors.white)),
                  Text("${workout.calories} ккал", style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(Icons.edit, size: 16, color: Colors.grey)
            ],
          )
        ],
      ),
    );
  }
}
