import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_cute_app/utils/constants.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Configuración de tiempos y metas
  int workMinutes = 25;
  int breakMinutes = 5;
  int targetPomodoros = 4;

  // Estado actual
  int currentPomodoros = 0;
  int remainingSeconds = 25 * 60;
  bool isRunning = false;
  bool isWorkPhase = true;
  Timer? _timer;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> get _audioFiles =>
      AppColors.currentTheme.value == AppThemeMode.edward
      ? [
          'HoldonTightSpiderMonkey.wav',
          'LetsStartWithForever.wav',
          'NoMeasure.wav',
          'SayItOutLoud.wav',
          'ThisIsTheSkinOfaKillerBella.wav',
          'ToMyBeautifulBride.wav',
        ]
      : [
          'WhereTheHellHaveYouBeenLoca.mp3',
          'ItsaWerewolfThing.mp3',
          'IamHotterThanU.mp3',
          'DontGetmeUpset.mp3',
          'SheHasRightoKnow.mp3',
          'HoldOnTight.mp3',
        ];

  // Imágenes para los popups
  List<String> get _imageFiles =>
      AppColors.currentTheme.value == AppThemeMode.edward
      ? ['Edward.jpg', 'Edward2.png', 'Edward3.png', 'Edward4.png']
      : ['Jacob1.png', 'Jacob2.png', 'Jacob3.png', 'Jacob4.png'];

  String get _backgroundImage =>
      AppColors.currentTheme.value == AppThemeMode.edward
      ? 'assets/images/wp8944474.jpg'
      : 'assets/images/jacob_bg.png';

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playRandomAudio() async {
    try {
      final random = Random();
      final audioFile = _audioFiles[random.nextInt(_audioFiles.length)];
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$audioFile'));
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
    }
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    // Mostrar el popup y reproducir audio solo al iniciar la fase de estudio por primera vez
    if (isWorkPhase && remainingSeconds == workMinutes * 60) {
      _showCharacterPopup();
      _playRandomAudio();
    }

    setState(() {
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _handlePhaseComplete();
      }
    });
  }

  void _showCharacterPopup() {
    final random = Random();
    final selectedImage = _imageFiles[random.nextInt(_imageFiles.length)];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/$selectedImage',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      remainingSeconds = (isWorkPhase ? workMinutes : breakMinutes) * 60;
    });
  }

  void _handlePhaseComplete() {
    _pauseTimer();
    if (isWorkPhase) {
      // Mostrar el popup del personaje al terminar el estudio de pomodoro
      _showCharacterPopup();
      // Reproducir audio al terminar el estudio de pomodoro
      _playRandomAudio();
      setState(() {
        currentPomodoros++;
        isWorkPhase = false;
        remainingSeconds = breakMinutes * 60;
      });
      if (currentPomodoros >= targetPomodoros) {
        // ¡Meta completada! Podríamos mostrar un diálogo
        _showGoalCompletedDialog();
      }
    } else {
      setState(() {
        isWorkPhase = true;
        remainingSeconds = workMinutes * 60;
      });
    }
  }

  void _showGoalCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Felicidades!', textAlign: TextAlign.center),
        content: const Text(
          '¡Has completado tu meta de pomodoros! 🎉',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentPomodoros = 0;
                isWorkPhase = true;
                _resetTimer();
              });
            },
            child: const Text('Reiniciar Meta'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _openSettings() {
    if (isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pausa el timer para ajustar configuraciones'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ajustes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildSettingRow(
                  'Tiempo de Trabajo',
                  '$workMinutes min',
                  () {
                    if (workMinutes > 1) {
                      setModalState(() => workMinutes--);
                      setState(() {
                        if (isWorkPhase) _resetTimer();
                      });
                    }
                  },
                  () {
                    setModalState(() => workMinutes++);
                    setState(() {
                      if (isWorkPhase) _resetTimer();
                    });
                  },
                ),
                _buildSettingRow(
                  'Tiempo de Descanso',
                  '$breakMinutes min',
                  () {
                    if (breakMinutes > 1) {
                      setModalState(() => breakMinutes--);
                      setState(() {
                        if (!isWorkPhase) _resetTimer();
                      });
                    }
                  },
                  () {
                    setModalState(() => breakMinutes++);
                    setState(() {
                      if (!isWorkPhase) _resetTimer();
                    });
                  },
                ),
                _buildSettingRow(
                  'Meta de Pomodoros',
                  '$targetPomodoros',
                  () {
                    if (targetPomodoros > 1) {
                      setModalState(() => targetPomodoros--);
                      setState(() {});
                    }
                  },
                  () {
                    setModalState(() => targetPomodoros++);
                    setState(() {});
                  },
                ),
                _buildThemeSelectionRow(setModalState),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Listo'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeSelectionRow(StateSetter setModalState) {
    final currentTheme = AppColors.currentTheme.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tema del Personaje', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              _buildThemeButton(
                label: 'Edward',
                isSelected: currentTheme == AppThemeMode.edward,
                onTap: () {
                  setModalState(() {
                    AppColors.currentTheme.value = AppThemeMode.edward;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(width: 8),
              _buildThemeButton(
                label: 'Jacob',
                isSelected: currentTheme == AppThemeMode.jacob,
                onTap: () {
                  setModalState(() {
                    AppColors.currentTheme.value = AppThemeMode.jacob;
                  });
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.cardBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.textDark.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    String value,
    VoidCallback onMinus,
    VoidCallback onPlus,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.primary,
                ),
                onPressed: onMinus,
              ),
              SizedBox(
                width: 60,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(_backgroundImage, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/Logo@150x.png', height: 50),
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          size: 40,
                          color: AppColors.textDark,
                        ),
                        onPressed: _openSettings,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Phase Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isWorkPhase
                          ? AppColors.primary
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isWorkPhase
                          ? '✨ Tiempo de Enfoque ✨'
                          : '☕ Tiempo de Descanso ☕',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isWorkPhase
                            ? Colors.white
                            : AppColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Timer Display
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardBg,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isWorkPhase
                                      ? AppColors.primary
                                      : AppColors.secondary)
                                  .withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _formatTime(remainingSeconds),
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: isWorkPhase
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Meta Counters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag_rounded, color: AppColors.textDark),
                      const SizedBox(width: 8),
                      Text(
                        'Meta: $currentPomodoros / $targetPomodoros',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.refresh,
                        onPressed: _resetTimer,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: isRunning ? _pauseTimer : _startTimer,
                        color: isWorkPhase
                            ? AppColors.primary
                            : AppColors.secondary,
                        isLarge: true,
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: Icons.skip_next_rounded,
                        onPressed: _handlePhaseComplete,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isLarge = false,
  }) {
    double size = isLarge ? 80 : 60;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: isLarge ? 40 : 30),
      ),
    );
  }
}
