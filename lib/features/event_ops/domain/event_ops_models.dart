enum EventTaskStatus { pending, inProgress, done }

enum AgentRunStatus { draft, awaitingApproval, executed }

class CommunityEvent {
  const CommunityEvent({
    required this.id,
    required this.name,
    required this.dateLabel,
    required this.location,
    required this.capacity,
    required this.budget,
    required this.status,
    required this.topics,
  });

  final String id;
  final String name;
  final String dateLabel;
  final String location;
  final int capacity;
  final int budget;
  final String status;
  final List<String> topics;
}

class Speaker {
  const Speaker({
    required this.name,
    required this.topic,
    required this.availability,
    required this.rating,
    required this.reason,
  });

  final String name;
  final String topic;
  final String availability;
  final double rating;
  final String reason;
}

class Sponsor {
  const Sponsor({
    required this.name,
    required this.offer,
    required this.status,
    required this.contactHint,
  });

  final String name;
  final String offer;
  final String status;
  final String contactHint;
}

class EventTask {
  const EventTask({
    required this.title,
    required this.owner,
    required this.priority,
    required this.deadline,
    this.status = EventTaskStatus.pending,
  });

  final String title;
  final String owner;
  final String priority;
  final String deadline;
  final EventTaskStatus status;

  EventTask copyWith({EventTaskStatus? status}) {
    return EventTask(
      title: title,
      owner: owner,
      priority: priority,
      deadline: deadline,
      status: status ?? this.status,
    );
  }
}

class EventRisk {
  const EventRisk({
    required this.title,
    required this.detail,
    required this.level,
  });

  final String title;
  final String detail;
  final String level;
}

class MessageDraft {
  const MessageDraft({
    required this.type,
    required this.recipient,
    required this.content,
  });

  final String type;
  final String recipient;
  final String content;
}

class AgentStep {
  const AgentStep({
    required this.title,
    required this.detail,
    required this.tool,
    this.done = false,
  });

  final String title;
  final String detail;
  final String tool;
  final bool done;

  AgentStep complete() {
    return AgentStep(title: title, detail: detail, tool: tool, done: true);
  }
}

class EventPlan {
  const EventPlan({
    required this.event,
    required this.readinessScore,
    required this.agenda,
    required this.speakers,
    required this.sponsors,
    required this.tasks,
    required this.risks,
    required this.messages,
    required this.steps,
    required this.status,
  });

  final CommunityEvent event;
  final int readinessScore;
  final List<String> agenda;
  final List<Speaker> speakers;
  final List<Sponsor> sponsors;
  final List<EventTask> tasks;
  final List<EventRisk> risks;
  final List<MessageDraft> messages;
  final List<AgentStep> steps;
  final AgentRunStatus status;

  EventPlan copyWith({
    int? readinessScore,
    List<EventTask>? tasks,
    List<AgentStep>? steps,
    AgentRunStatus? status,
  }) {
    return EventPlan(
      event: event,
      readinessScore: readinessScore ?? this.readinessScore,
      agenda: agenda,
      speakers: speakers,
      sponsors: sponsors,
      tasks: tasks ?? this.tasks,
      risks: risks,
      messages: messages,
      steps: steps ?? this.steps,
      status: status ?? this.status,
    );
  }
}
