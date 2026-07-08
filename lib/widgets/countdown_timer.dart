import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  const CountdownTimer({super.key, required this.targetTime});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final diff = widget.targetTime.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return const Text('LIVE HADDA', style: TextStyle(color: AppColors.liveRed, fontWeight: FontWeight.bold));
    }
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    return Text(
      d > 0 ? '$d maalmood ${_two(h)}:${_two(m)}:${_two(s)}' : '${_two(h)}:${_two(m)}:${_two(s)}',
      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
    );
  }
}
