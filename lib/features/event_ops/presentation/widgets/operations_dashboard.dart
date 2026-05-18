import 'package:flutter/material.dart';

import '../../../../app/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/event_ops_models.dart';

class OperationsDashboard extends StatelessWidget {
  const OperationsDashboard({
    super.key,
    required this.plan,
  });

  final EventPlan? plan;

  @override
  Widget build(BuildContext context) {
    final currentPlan = plan;

    if (currentPlan == null) {
      return const _EmptyDashboard();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EventSummary(plan: currentPlan),
          const SizedBox(height: 14),
          _IntegrationStatusPanel(plan: currentPlan),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth >= 720;
              if (!useTwoColumns) {
                return Column(
                  children: [
                    _ReadinessPanel(plan: currentPlan),
                    const SizedBox(height: 14),
                    _TimelinePanel(steps: currentPlan.steps),
                  ],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _ReadinessPanel(plan: currentPlan)),
                    const SizedBox(width: 14),
                    Expanded(child: _TimelinePanel(steps: currentPlan.steps)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _AgendaPanel(agenda: currentPlan.agenda),
          const SizedBox(height: 14),
          _TasksPanel(tasks: currentPlan.tasks),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth >= 720;
              if (!useTwoColumns) {
                return Column(
                  children: [
                    _RisksPanel(risks: currentPlan.risks),
                    const SizedBox(height: 14),
                    _MessagesPanel(messages: currentPlan.messages),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _RisksPanel(risks: currentPlan.risks)),
                  const SizedBox(width: 14),
                  Expanded(child: _MessagesPanel(messages: currentPlan.messages)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IntegrationStatusPanel extends StatelessWidget {
  const _IntegrationStatusPanel({required this.plan});

  final EventPlan plan;

  @override
  Widget build(BuildContext context) {
    final mongoSynced = plan.status == AgentRunStatus.executed &&
        plan.steps.any((step) {
          final title = step.title.toLowerCase();
          final tool = step.tool.toLowerCase();
          return step.done &&
              (title.contains('persist') ||
                  title.contains('mongodb') ||
                  tool.contains('insertmany'));
        });

    return _Panel(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _StatusMetric(
            icon: Icons.auto_awesome,
            label: 'Gemini',
            value: AppConfig.geminiModel,
            color: AppColors.info,
          ),
          _StatusMetric(
            icon: mongoSynced ? Icons.cloud_done_outlined : Icons.cloud_sync_outlined,
            label: 'MongoDB',
            value: mongoSynced ? 'Synced' : 'Pending',
            color: mongoSynced ? AppColors.success : AppColors.accent,
          ),
          _StatusMetric(
            icon: Icons.fingerprint,
            label: 'Run ID',
            value: plan.event.id,
            color: AppColors.brand,
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
     height: 540,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.dashboard_customize_outlined, color: AppColors.brand),
          ),
          const SizedBox(height: 18),
          Text(
            'Operational event workspace',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Aqui aparecera el evento, readiness score, timeline del agente, tareas, riesgos y mensajes listos para MongoDB.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CapabilityChip(icon: Icons.storage_outlined, label: 'MongoDB memory'),
              _CapabilityChip(icon: Icons.route_outlined, label: 'Multi-step planning'),
              _CapabilityChip(icon: Icons.verified_user_outlined, label: 'Human approval'),
              _CapabilityChip(icon: Icons.task_alt_outlined, label: 'Actionable tasks'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventSummary extends StatelessWidget {
  const _EventSummary({required this.plan});

  final EventPlan plan;

  @override
  Widget build(BuildContext context) {
    final event = plan.event;
    final statusLabel = switch (plan.status) {
      AgentRunStatus.draft => 'Draft',
      AgentRunStatus.awaitingApproval => 'Awaiting approval',
      AgentRunStatus.executed => 'Executed',
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.name, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${event.dateLabel} / ${event.location} / ${event.capacity} asistentes / S/${event.budget}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: statusLabel, status: plan.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: event.topics.map((topic) => _TopicPill(topic)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel({required this.plan});

  final EventPlan plan;

  @override
  Widget build(BuildContext context) {
    final score = plan.readinessScore;
    final color = score >= 80 ? AppColors.success : AppColors.accent;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.speed_outlined, title: 'Event readiness'),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  height: 0.9,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text('/100', style: TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              color: color,
              backgroundColor: AppColors.line,
            ),
          ),
          const SizedBox(height: 14),
          Text(_readinessDetail(plan), style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }

  String _readinessDetail(EventPlan plan) {
    final hasPendingPersistence = plan.status == AgentRunStatus.executed &&
        plan.steps.any((step) => !step.done && step.title.toLowerCase().contains('mongodb'));

    if (hasPendingPersistence) {
      return 'La operacion fue aprobada, pero MongoDB todavia no pudo sincronizar desde esta maquina.';
    }

    if (plan.status == AgentRunStatus.executed) {
      return 'La operacion fue aprobada y registrada en MongoDB.';
    }

    return 'El plan esta listo, pero el agente espera aprobacion antes de escribir datos.';
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.steps});

  final List<AgentStep> steps;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.account_tree_outlined, title: 'Agent run'),
          const SizedBox(height: 12),
          for (final step in steps) _TimelineRow(step: step),
        ],
      ),
    );
  }
}

class _AgendaPanel extends StatelessWidget {
  const _AgendaPanel({required this.agenda});

  final List<String> agenda;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.calendar_month_outlined, title: 'Agenda sugerida'),
          const SizedBox(height: 12),
          for (final item in agenda)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppColors.brand),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TasksPanel extends StatelessWidget {
  const _TasksPanel({required this.tasks});

  final List<EventTask> tasks;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.checklist_outlined, title: 'Tareas creadas'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tasks.map((task) => _TaskTile(task: task)).toList(),
          ),
        ],
      ),
    );
  }
}

class _RisksPanel extends StatelessWidget {
  const _RisksPanel({required this.risks});

  final List<EventRisk> risks;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.warning_amber_outlined, title: 'Riesgos detectados'),
          const SizedBox(height: 12),
          for (final risk in risks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RiskTile(risk: risk),
            ),
        ],
      ),
    );
  }
}

class _MessagesPanel extends StatelessWidget {
  const _MessagesPanel({required this.messages});

  final List<MessageDraft> messages;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.mark_email_unread_outlined, title: 'Borradores'),
          const SizedBox(height: 12),
          for (final message in messages)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MessageTile(message: message),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.brand),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step});

  final AgentStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            step.done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: step.done ? AppColors.success : AppColors.muted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(step.detail, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(step.tool, style: const TextStyle(color: AppColors.info, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final EventTask task;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (task.status) {
      EventTaskStatus.pending => AppColors.muted,
      EventTaskStatus.inProgress => AppColors.info,
      EventTaskStatus.done => AppColors.success,
    };

    return SizedBox(
      width: 245,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(task.priority.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${task.owner} / ${task.deadline}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({required this.risk});

  final EventRisk risk;

  @override
  Widget build(BuildContext context) {
    final isHigh = risk.level == 'high';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isHigh ? AppColors.danger : AppColors.accent).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHigh ? AppColors.danger.withValues(alpha: 0.35) : AppColors.accent.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHigh ? Icons.priority_high : Icons.error_outline,
            color: isHigh ? AppColors.danger : AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(risk.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(risk.detail, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final MessageDraft message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.recipient, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(message.type, style: const TextStyle(color: AppColors.info, fontSize: 11)),
          const SizedBox(height: 8),
          Text(message.content, maxLines: 4, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.brand),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.status,
  });

  final String label;
  final AgentRunStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AgentRunStatus.draft => AppColors.muted,
      AgentRunStatus.awaitingApproval => AppColors.accent,
      AgentRunStatus.executed => AppColors.success,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  const _TopicPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.brandDark, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
