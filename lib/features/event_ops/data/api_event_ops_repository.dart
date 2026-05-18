import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/event_ops_models.dart';
import '../domain/event_ops_repository.dart';

class ApiEventOpsRepository implements EventOpsRepository {
  ApiEventOpsRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<EventPlan> planMeetup(String goal) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/agent/message'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'goal': goal}),
    );

    _throwIfFailed(response);
    return _EventPlanDto.fromJson(_decodeObject(response.body)).toDomain();
  }

  @override
  Future<EventPlan> executePlan(EventPlan plan) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/agent/approve'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'runId': plan.event.id,
        'approvedBy': 'organizer',
      }),
    );

    _throwIfFailed(response);
    return _EventPlanDto.fromJson(_decodeObject(response.body)).toDomain();
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected JSON object from CommunityOps API.');
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw CommunityOpsApiException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }
}

class CommunityOpsApiException implements Exception {
  const CommunityOpsApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'CommunityOpsApiException($statusCode): $message';
}

class _EventPlanDto {
  const _EventPlanDto({
    required this.id,
    required this.status,
    required this.readinessScore,
    required this.event,
    required this.agenda,
    required this.speakers,
    required this.sponsors,
    required this.tasks,
    required this.risks,
    required this.messages,
    required this.steps,
  });

  final String id;
  final String status;
  final int readinessScore;
  final Map<String, dynamic> event;
  final List<dynamic> agenda;
  final List<dynamic> speakers;
  final List<dynamic> sponsors;
  final List<dynamic> tasks;
  final List<dynamic> risks;
  final List<dynamic> messages;
  final List<dynamic> steps;

  factory _EventPlanDto.fromJson(Map<String, dynamic> json) {
    return _EventPlanDto(
      id: json['id'] as String? ?? 'run_unknown',
      status: json['status'] as String? ?? 'awaiting_approval',
      readinessScore: json['readinessScore'] as int? ?? 0,
      event: json['event'] as Map<String, dynamic>? ?? const {},
      agenda: json['agenda'] as List<dynamic>? ?? const [],
      speakers: json['speakers'] as List<dynamic>? ?? const [],
      sponsors: json['sponsors'] as List<dynamic>? ?? const [],
      tasks: json['tasks'] as List<dynamic>? ?? const [],
      risks: json['risks'] as List<dynamic>? ?? const [],
      messages: json['messages'] as List<dynamic>? ?? const [],
      steps: json['steps'] as List<dynamic>? ?? const [],
    );
  }

  EventPlan toDomain() {
    return EventPlan(
      event: CommunityEvent(
        id: id,
        name: event['name'] as String? ?? 'Community meetup',
        dateLabel: event['dateLabel'] as String? ?? 'Date pending',
        location: event['location'] as String? ?? 'Location pending',
        capacity: event['capacity'] as int? ?? 0,
        budget: event['budget'] as int? ?? 0,
        status: event['status'] as String? ?? status,
        topics: _stringList(event['topics']),
      ),
      readinessScore: readinessScore,
      agenda: _stringList(agenda),
      speakers: speakers.map<Speaker>(_speakerFromJson).toList(),
      sponsors: sponsors.map<Sponsor>(_sponsorFromJson).toList(),
      tasks: tasks.map<EventTask>(_taskFromJson).toList(),
      risks: risks.map<EventRisk>(_riskFromJson).toList(),
      messages: messages.map<MessageDraft>(_messageFromJson).toList(),
      steps: steps.map<AgentStep>(_stepFromJson).toList(),
      status: _runStatus(status),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList();
  }

  static Speaker _speakerFromJson(dynamic value) {
    final json = value as Map<String, dynamic>? ?? const {};
    return Speaker(
      name: json['name'] as String? ?? 'Speaker pending',
      topic: json['topic'] as String? ?? 'Topic pending',
      availability: json['availability'] as String? ?? 'Pending',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String? ?? 'Recommended by the agent.',
    );
  }

  static Sponsor _sponsorFromJson(dynamic value) {
    final json = value as Map<String, dynamic>? ?? const {};
    return Sponsor(
      name: json['name'] as String? ?? 'Sponsor pending',
      offer: json['offer'] as String? ?? 'Offer pending',
      status: json['status'] as String? ?? 'pending',
      contactHint: json['contactHint'] as String? ?? 'Needs follow-up.',
    );
  }

  static EventTask _taskFromJson(dynamic value) {
    final json = value as Map<String, dynamic>? ?? const {};
    return EventTask(
      title: json['title'] as String? ?? 'Task pending',
      owner: json['owner'] as String? ?? 'Organizer',
      priority: json['priority'] as String? ?? 'medium',
      deadline: json['deadline'] as String? ?? 'Pending',
      status: _taskStatus(json['status'] as String?),
    );
  }

  static EventRisk _riskFromJson(dynamic value) {
    final json = value as Map<String, dynamic>? ?? const {};
    return EventRisk(
      title: json['title'] as String? ?? 'Risk pending',
      detail: json['detail'] as String? ?? 'Needs review.',
      level: json['level'] as String? ?? 'medium',
    );
  }

  static MessageDraft _messageFromJson(dynamic value) {
    final json = value as Map<String, dynamic>? ?? const {};
    return MessageDraft(
      type: json['type'] as String? ?? 'message',
      recipient: json['recipient'] as String? ?? 'Recipient pending',
      content: json['content'] as String? ?? '',
    );
  }

  static AgentStep _stepFromJson(dynamic value) {
    final json = value as Map<String, dynamic>? ?? const {};
    return AgentStep(
      title: json['title'] as String? ?? 'Agent step',
      detail: json['detail'] as String? ?? '',
      tool: json['tool'] as String? ?? 'Agent Builder',
      done: json['done'] as bool? ?? false,
    );
  }

  static AgentRunStatus _runStatus(String status) {
    return switch (status) {
      'draft' => AgentRunStatus.draft,
      'executed' => AgentRunStatus.executed,
      _ => AgentRunStatus.awaitingApproval,
    };
  }

  static EventTaskStatus _taskStatus(String? status) {
    return switch (status) {
      'in_progress' => EventTaskStatus.inProgress,
      'done' => EventTaskStatus.done,
      _ => EventTaskStatus.pending,
    };
  }
}
