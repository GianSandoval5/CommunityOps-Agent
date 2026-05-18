import 'package:flutter/material.dart';

import '../../domain/event_ops_repository.dart';
import '../controllers/event_ops_controller.dart';
import '../widgets/agent_chat_panel.dart';
import '../widgets/operations_dashboard.dart';

class EventOpsPage extends StatefulWidget {
  const EventOpsPage({
    super.key,
    required this.repository,
  });

  final EventOpsRepository repository;

  @override
  State<EventOpsPage> createState() => _EventOpsPageState();
}

class _EventOpsPageState extends State<EventOpsPage> {
  late final EventOpsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EventOpsController(widget.repository);
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
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const _AppTitle(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FilledButton.icon(
                  onPressed: _controller.canApprove ? _controller.approvePlan : null,
                  icon: const Icon(Icons.verified_user_outlined, size: 18),
                  label: const Text('Aprobar ejecucion'),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1040;
                final chatPanel = SizedBox(
                  width: isWide ? 390 : double.infinity,
                  child: AgentChatPanel(controller: _controller),
                );

                if (isWide) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        chatPanel,
                        const SizedBox(width: 16),
                        Expanded(
                          child: OperationsDashboard(plan: _controller.plan),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                  children: [
                    chatPanel,
                    const SizedBox(height: 14),
                    OperationsDashboard(plan: _controller.plan),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('CommunityOps Agent'),
            Text(
              'Gemini + Agent Builder + MongoDB MCP',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
