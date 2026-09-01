import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';

class VideoConsultationScreen extends StatefulWidget {
  const VideoConsultationScreen({super.key, this.doctorName = 'Dr. Rajesh Kumar'});
  final String doctorName;

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  bool _inCall = false;
  bool _micMuted = false;
  bool _camOff = false;
  int _callDurationSeconds = 0;
  Timer? _timer;

  void _startCall() {
    setState(() {
      _inCall = true;
      _callDurationSeconds = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _inCall) {
        setState(() => _callDurationSeconds++);
      }
    });
  }

  void _endCall() {
    _timer?.cancel();
    setState(() {
      _inCall = false;
      _callDurationSeconds = 0;
    });
  }

  String get _formattedDuration {
    final minutes = (_callDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callDurationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _inCall ? Colors.black : AppColors.surfaceVariant,
      appBar: _inCall
          ? null
          : AppBar(
              title: const Text('Teleconsultation'),
              backgroundColor: AppColors.surface,
            ),
      body: _inCall ? _buildCallUI(context) : _buildWaitingRoom(context),
    );
  }

  Widget _buildWaitingRoom(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Doctor avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.doctorName, style: AppTextStyles.headlineMedium),
          Text(
            'General Physician',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'PHC Koregaon',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 32),

          // Prep checklist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Before you join the call', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                ...[
                  'Make sure you are in a quiet, private space',
                  'Have good room lighting on your face',
                  'Keep previous prescriptions & reports ready',
                  'Ensure stable internet connection',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(tip, style: AppTextStyles.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          RuralCareButton(
            label: 'Join Consultation Call',
            onPressed: _startCall,
            icon: Icons.video_call_outlined,
          ),

          const SizedBox(height: 16),

          RuralCareButton(
            label: 'Go Back',
            onPressed: () => Navigator.of(context).pop(),
            variant: RuralCareButtonVariant.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildCallUI(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Remote video area
          Expanded(
            child: Stack(
              children: [
                // Remote feed background
                Container(
                  color: const Color(0xFF1A1A2E),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 56,
                          backgroundColor: Color(0xFF2D2D4E),
                          child: Icon(
                            Icons.person,
                            size: 56,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.doctorName,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PulsingDot(),
                      ],
                    ),
                  ),
                ),

                // Self view PIP
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _camOff
                          ? Colors.grey.shade800
                          : const Color(0xFF0D47A1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: _camOff
                        ? const Icon(
                            Icons.videocam_off,
                            color: Colors.white54,
                            size: 28,
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white54,
                            size: 40,
                          ),
                  ),
                ),

                // Call duration badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // In-call control bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallControl(
                  icon: _micMuted ? Icons.mic_off : Icons.mic,
                  label: _micMuted ? 'Unmute' : 'Mute',
                  onTap: () => setState(() => _micMuted = !_micMuted),
                  active: !_micMuted,
                ),
                // End call button
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('End Consultation?'),
                        content: const Text(
                            'Are you sure you want to end this video consultation call?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Stay in Call'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emergency,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _endCall();
                            },
                            child: const Text('End Call'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.emergency,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                _CallControl(
                  icon: _camOff ? Icons.videocam_off : Icons.videocam,
                  label: _camOff ? 'Camera Off' : 'Camera',
                  onTap: () => setState(() => _camOff = !_camOff),
                  active: !_camOff,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active ? Colors.white12 : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : Colors.white60,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => Opacity(
        opacity: 0.5 + 0.5 * _controller.value,
        child: const Text(
          'Connecting clinical stream...',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }
}
