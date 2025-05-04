import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class OpenTicketScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tickets;

  const OpenTicketScreen({super.key, required this.tickets});

  @override
  State<OpenTicketScreen> createState() => _OpenTicketScreenState();
}

class _OpenTicketScreenState extends State<OpenTicketScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    debugPrint('Opening OpenTicketScreen');
    // Update durasi setiap 1 menit
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A192F);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'open_tickets'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: themeColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          widget.tickets.isEmpty
              ? Center(child: Text('no_tickets_found'.tr()))
              : ListView.separated(
                itemCount: widget.tickets.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final ticket = widget.tickets[index];
                  final name = ticket['name'] ?? 'Unnamed';
                  final total = (ticket['total'] ?? 0.0) as double;
                  final createdAtStr = ticket['created_at'] ?? '';

                  final createdAt =
                      DateTime.tryParse(createdAtStr) ?? DateTime.now();
                  final duration = DateTime.now().difference(createdAt);
                  final durationText =
                      '${duration.inHours}h ${duration.inMinutes % 60}m ago';

                  return ListTile(
                    title: Text(name),
                    subtitle: Text(durationText),
                    trailing: Text(
                      'Rp${total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context, ticket['id']);
                    },
                  );
                },
              ),
    );
  }
}
