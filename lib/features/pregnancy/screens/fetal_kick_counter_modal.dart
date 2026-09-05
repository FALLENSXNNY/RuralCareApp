import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/child_care.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Interactive modal for counting and recording fetal movements (Kick Counter)
class FetalKickCounterModal extends ConsumerStatefulWidget {
  const FetalKickCounterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FetalKickCounterModal(),
    );
  }

  @override
  ConsumerState<FetalKickCounterModal> createState() =>
      _FetalKickCounterModalState();
}

class _FetalKickCounterModalState extends ConsumerState<FetalKickCounterModal> {
  int _kickCount = 0;
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isActive = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isActive) return;
    setState(() => _isActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsElapsed++);
    });
  }

  void _recordKick() {
    if (!_isActive) {
      _startTimer();
    }
    setState(() => _kickCount++);

    if (_kickCount == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 10 kicks recorded! Fetal movement is healthy.'),
          backgroundColor: Color(0xFF065F18),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _kickCount = 0;
      _secondsElapsed = 0;
      _isActive = false;
    });
  }

  Future<void> _saveSession() async {
    if (_kickCount == 0) return;
    _timer?.cancel();

    final minutes = (_secondsElapsed / 60).ceil().clamp(1, 120);
    final session = FetalKickSession(
      timestamp: DateTime.now(),
      kicksCount: _kickCount,
      durationMinutes: minutes,
      isNormal: _kickCount >= 10,
    );

    await ref.read(childCareRepositoryProvider).saveKickSession(session);
    ref.invalidate(fetalKickSessionsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Session saved: $_kickCount kicks in $minutes mins'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(fetalKickSessionsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Top pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFECB3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFF57F17),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fetal Kick Counter',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Goal: 10 movements within 2 hours',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF506079),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Guidance Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EEFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD5E3FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rest comfortably on your left side after a meal. Tap the heart button every time you feel a kick, flutter, or roll.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF24334A),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timer Display
                  Text(
                    _formatTime(_secondsElapsed),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF24334A),
                    ),
                  ),
                  Text(
                    _isActive ? 'Session in progress...' : 'Tap heart to start counting',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF506079),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Big Interactive Heart Tap Button
                  GestureDetector(
                    onTap: _recordKick,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _kickCount >= 10
                              ? [const Color(0xFFA3F69C), const Color(0xFF2E7D32)]
                              : [const Color(0xFFFF80AB), const Color(0xFFE91E63)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_kickCount >= 10
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFE91E63))
                                .withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _kickCount >= 10 ? Icons.check_circle : Icons.favorite,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_kickCount',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'TAP FOR KICK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress Bar to 10 kicks
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF506079),
                              ),
                            ),
                            Text(
                              '$_kickCount / 10 kicks',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _kickCount >= 10
                                    ? const Color(0xFF065F18)
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (_kickCount / 10).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: const Color(0xFFDEE8FF),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _kickCount >= 10
                                  ? const Color(0xFF065F18)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons: Reset & Save
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _kickCount > 0 ? _saveSession : null,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Save Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Past Sessions History
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Kick Count History',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  historyAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'No recorded sessions yet. Start your first count above.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF506079),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: sessions.take(4).map((s) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFD5E3FF)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  s.isNormal
                                      ? Icons.check_circle
                                      : Icons.warning_amber_rounded,
                                  color: s.isNormal
                                      ? const Color(0xFF065F18)
                                      : const Color(0xFFF57F17),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${s.kicksCount} kicks in ${s.durationMinutes} mins',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd MMM yyyy · hh:mm a')
                                            .format(s.timestamp),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF506079),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: s.isNormal
                                        ? const Color(0xFFA3F69C)
                                        : const Color(0xFFFFECB3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    s.isNormal ? 'Healthy' : 'Low',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: s.isNormal
                                          ? const Color(0xFF065F18)
                                          : const Color(0xFFF57F17),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
