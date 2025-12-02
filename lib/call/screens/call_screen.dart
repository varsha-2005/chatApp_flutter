import 'package:chat_app/auth/widgets/bottom_navigation.dart';
import 'package:chat_app/call/models/call_model.dart';
import 'package:chat_app/call/providers/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    /// A small delay to show loading indicator cleanly (UI smoothness)
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final callHistoryStream = ref.watch(callControllerProvider).getCallHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calls",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF128C7E),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.white)),
        ],
      ),

      body: Stack(
        children: [
          StreamBuilder<List<CallModel>>(
            stream: callHistoryStream,
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final calls = snapshot.data ?? [];

              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFF128C7E),
                          child: Icon(Icons.link, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Create call link",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 3),
                            Text("Share a link for your WhatsApp call",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Recent",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey),
                    ),
                  ),

                  if (calls.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text("No recent calls")),
                    ),

                  ...calls.map((call) => _CallRow(call: call)).toList(),
                ],
              );
            },
          ),

          /// ⭐ FULL-SCREEN LOADING OVERLAY ⭐
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Color(0xFF128C7E),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
    );
  }
}

class _CallRow extends StatelessWidget {
  final CallModel call;

  const _CallRow({required this.call});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.jm().format(call.timestamp);
    final dateStr = DateFormat.MMMd().format(call.timestamp);

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: call.receiverPic.startsWith("http")
            ? NetworkImage(call.receiverPic)
            : const AssetImage("assets/google_logo.png") as ImageProvider,
      ),
      title: Text(
        call.receiverName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.call_made, color: Colors.green, size: 16),
          const SizedBox(width: 5),
          Text("$dateStr, $timeStr"),
        ],
      ),
      trailing: Icon(
        call.isVideo ? Icons.videocam : Icons.call,
        color: const Color(0xFF128C7E),
      ),
      onTap: () {},
    );
  }
}
