import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/event_ops_controller.dart';

class AgentChatPanel extends StatefulWidget {
  const AgentChatPanel({
    super.key,
    required this.controller,
  });

  final EventOpsController controller;

  @override
  State<AgentChatPanel> createState() => _AgentChatPanelState();
}

class _AgentChatPanelState extends State<AgentChatPanel> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.lastGoal);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const _ChatHeader(),
          const Divider(height: 1, color: AppColors.line),
          SizedBox(
            height: 360,
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: controller.chat.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _ChatBubble(entry: controller.chat[index]);
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.line),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  minLines: 4,
                  maxLines: 5,
                  enabled: !controller.isWorking,
                  decoration: const InputDecoration(
                    hintText: 'Describe el evento que quieres organizar',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: controller.isWorking
                            ? null
                            : () => controller.submitGoal(_textController.text),
                        icon: controller.isWorking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.psychology_alt_outlined, size: 18),
                        label: Text(controller.isWorking ? 'Trabajando...' : 'Planificar meetup'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.smart_toy_outlined, color: AppColors.brand),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent mission control',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  'Consulta, planea y ejecuta con aprobacion',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.entry});

  final ChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final isUser = entry.author == ChatAuthor.user;
    final color = isUser ? AppColors.brand : AppColors.surface;
    final textColor = isUser ? Colors.white : AppColors.ink;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: isUser ? null : Border.all(color: AppColors.line),
          ),
          child: Text(
            entry.text,
            style: TextStyle(color: textColor, fontSize: 13, height: 1.35),
          ),
        ),
      ),
    );
  }
}
