import 'package:flutter/material.dart';

class StaffScheduleUi extends StatefulWidget {
  const StaffScheduleUi({super.key});

  @override
  State<StaffScheduleUi> createState() => _StaffScheduleUiState();
}

class _StaffScheduleUiState extends State<StaffScheduleUi>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}