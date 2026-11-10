import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const OneMinGardenApp());
}

class OneMinGardenApp extends StatelessWidget {
  const OneMinGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сад из 1 минуты',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101512),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6BCB77),
          secondary: Color(0xFFFFD93D),
        ),
      ),
      home: const GardenScreen(),
    );
  }
}

class Plant {
  final String name;
  final IconData icon;
  final Color color;
  final DateTime grownAt;

  const Plant({
    required this.name,
    required this.icon,
    required this.color,
    required this.grownAt,
  });
}

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  static const int _sprintSeconds = 60; // 1 минута

  final TextEditingController _taskController = TextEditingController();
  final List<Plant> _garden = [];

  Timer? _timer;
  int _remainingSeconds = _sprintSeconds;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  void _startSprint() {
    if (_isRunning) return;
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        _completeSprint();
      }
    });
  }

  void _giveUpSprint() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _sprintSeconds;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Спринт прерван. Всего 1 минута — попробуй снова, когда будешь готов.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _completeSprint() {
    _timer?.cancel();
    final plant = _createPlantForCount(_garden.length);

    setState(() {
      _isRunning = false;
      _remainingSeconds = _sprintSeconds;
      _garden.add(plant);
    });

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF19221C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('+1 минута в копилке!'),
        content: Text(
          'В вашем саду появилось новое растение: «${plant.name}». '
          'Первый шаг сделан!',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BCB77),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
  }

  Plant _createPlantForCount(int index) {
    const templates = [
      ('Росток мяты', Icons.spa, Color(0xFF6BCB77)),
      ('Полевой цветок', Icons.local_florist, Color(0xFFFFD93D)),
      ('Куст розмарина', Icons.grass, Color(0xFF4D96FF)),
      ('Молодое дерево', Icons.park, Color(0xFF38B000)),
      ('Редкий кактус', Icons.eco, Color(0xFFFF8FA3)),
    ];
    final t = templates[index % templates.length];
    return Plant(name: t.$1, icon: t.$2, color: t.$3, grownAt: DateTime.now());
  }

  String _formatTime(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_remainingSeconds / _sprintSeconds);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Сад из 1 минуты'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Растений: ${_garden.length}',
                style: const TextStyle(
                  color: Color(0xFF6BCB77),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              enabled: !_isRunning,
              decoration: InputDecoration(
                hintText: 'Какое одно крошечное дело сделаем за 1 минуту?',
                filled: true,
                fillColor: const Color(0xFF18201B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _isRunning ? progress : 0,
                    strokeWidth: 10,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6BCB77),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRunning ? 'Всего 60 секунд...' : 'Готов к старту',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton.icon(
                    onPressed: _startSprint,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Начать 1 минуту'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BCB77),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _giveUpSprint,
                    icon: const Icon(Icons.stop),
                    label: const Text('Сдаться'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ваш сад',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _garden.isEmpty
                  ? const Center(
                      child: Text(
                        'Пока пусто. Завершите первый 1-минутный спринт, чтобы посадить росток.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _garden.length,
                      itemBuilder: (context, index) {
                        final plant = _garden[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18201B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: plant.color.withOpacity(0.35),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(plant.icon, color: plant.color, size: 32),
                              const SizedBox(height: 6),
                              Text(
                                plant.name,
                                style: const TextStyle(fontSize: 11),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
