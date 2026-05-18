import 'package:flutter/foundation.dart';

import '../../domain/event_ops_models.dart';
import '../../domain/event_ops_repository.dart';

class EventOpsController extends ChangeNotifier {
  EventOpsController(this._repository);

  final EventOpsRepository _repository;

  final List<ChatEntry> _chat = [
    const ChatEntry(
      author: ChatAuthor.agent,
      text: 'Listo para planificar el meetup. Voy a consultar memoria operativa, proponer acciones y pedir aprobacion antes de escribir cambios.',
    ),
  ];

  EventPlan? _plan;
  bool _isWorking = false;
  String _lastGoal = 'Organiza un meetup de Flutter Piura para 80 personas sobre Flutter + IA, con 2 charlas, presupuesto de S/500, coffee break y certificados.';

  List<ChatEntry> get chat => List.unmodifiable(_chat);
  EventPlan? get plan => _plan;
  bool get isWorking => _isWorking;
  String get lastGoal => _lastGoal;
  bool get canApprove => _plan?.status == AgentRunStatus.awaitingApproval && !_isWorking;

  Future<void> submitGoal(String goal) async {
    final trimmedGoal = goal.trim();
    if (trimmedGoal.isEmpty || _isWorking) {
      return;
    }

    _lastGoal = trimmedGoal;
    _chat.add(ChatEntry(author: ChatAuthor.user, text: trimmedGoal));
    _chat.add(
      const ChatEntry(
        author: ChatAuthor.agent,
        text: 'Voy a revisar eventos anteriores, speakers, sponsors y feedback antes de proponer el plan.',
      ),
    );
    _setWorking(true);

    try {
      final result = await _repository.planMeetup(trimmedGoal);
      _plan = result;
      _chat.add(
        ChatEntry(
          author: ChatAuthor.agent,
          text: 'Plan creado: readiness ${result.readinessScore}/100, ${result.tasks.length} tareas, ${result.risks.length} riesgos y ${result.messages.length} mensajes. Necesito aprobacion para registrar los cambios.',
        ),
      );
    } catch (error) {
      _chat.add(
        ChatEntry(
          author: ChatAuthor.agent,
          text: 'No pude completar la planificacion. Revisa que el backend este activo o vuelve al modo demo. Detalle tecnico: $error',
        ),
      );
    } finally {
      _setWorking(false);
    }
  }

  Future<void> approvePlan() async {
    final currentPlan = _plan;
    if (currentPlan == null || !canApprove) {
      return;
    }

    _chat.add(
      const ChatEntry(
        author: ChatAuthor.user,
        text: 'Aprobado. Registra el evento, tareas y borradores.',
      ),
    );
    _setWorking(true);

    try {
      final result = await _repository.executePlan(currentPlan);
      _plan = result;
      _chat.add(
        ChatEntry(
          author: ChatAuthor.agent,
          text: 'Ejecucion completada. El dashboard quedo actualizado con readiness ${result.readinessScore}/100 y el primer flujo operativo en progreso.',
        ),
      );
    } catch (error) {
      _chat.add(
        ChatEntry(
          author: ChatAuthor.agent,
          text: 'No pude ejecutar el plan aprobado. Revisa el backend o la respuesta de la API. Detalle tecnico: $error',
        ),
      );
    } finally {
      _setWorking(false);
    }
  }

  void _setWorking(bool value) {
    _isWorking = value;
    notifyListeners();
  }
}

enum ChatAuthor { user, agent }

class ChatEntry {
  const ChatEntry({
    required this.author,
    required this.text,
  });

  final ChatAuthor author;
  final String text;
}
