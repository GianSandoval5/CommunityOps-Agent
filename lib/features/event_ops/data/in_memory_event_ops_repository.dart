import '../domain/event_ops_models.dart';
import '../domain/event_ops_repository.dart';

class InMemoryEventOpsRepository implements EventOpsRepository {
  @override
  Future<EventPlan> planMeetup(String goal) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final steps = <AgentStep>[
      const AgentStep(
        title: 'Leer memoria historica',
        detail: 'Eventos anteriores, asistencia, feedback y temas con mayor traccion.',
        tool: 'MongoDB MCP: find events, feedback',
        done: true,
      ),
      const AgentStep(
        title: 'Cruzar speakers y sponsors',
        detail: 'Disponibilidad de ponentes, afinidad tematica y posibles sponsors.',
        tool: 'MongoDB MCP: aggregate speakers, sponsors',
        done: true,
      ),
      const AgentStep(
        title: 'Generar plan operativo',
        detail: 'Agenda, tareas, responsables, mensajes y riesgos.',
        tool: 'Gemini reasoning',
        done: true,
      ),
      const AgentStep(
        title: 'Esperar aprobacion humana',
        detail: 'El agente no escribe cambios importantes sin confirmacion.',
        tool: 'Approval checkpoint',
      ),
    ];

    return EventPlan(
      event: const CommunityEvent(
        id: 'fp-meetup-2026-05',
        name: 'Flutter Piura Meetup: Flutter + IA',
        dateLabel: 'Sabado 30 Mayo 2026',
        location: 'Piura, Peru',
        capacity: 80,
        budget: 500,
        status: 'planning',
        topics: ['Flutter', 'IA', 'Firebase'],
      ),
      readinessScore: 72,
      agenda: const [
        '05:00 PM - Registro y bienvenida',
        '05:20 PM - Charla 1: Flutter apps con IA aplicada',
        '06:05 PM - Coffee break y networking',
        '06:25 PM - Charla 2: Firebase + Gemini para productos reales',
        '07:10 PM - Q&A, anuncios y foto de comunidad',
      ],
      speakers: const [
        Speaker(
          name: 'Maria Torres',
          topic: 'Flutter apps con IA aplicada',
          availability: 'Sabado tarde',
          rating: 4.8,
          reason: 'Alta valoracion y buen encaje con Flutter + IA.',
        ),
        Speaker(
          name: 'Luis Mendoza',
          topic: 'Firebase + Gemini para productos reales',
          availability: 'Pendiente de confirmar',
          rating: 4.6,
          reason: 'Experiencia practica en backend serverless y demos en vivo.',
        ),
      ],
      sponsors: const [
        Sponsor(
          name: 'Tech Sponsor Piura',
          offer: 'Coffee break parcial',
          status: 'pending',
          contactHint: 'Requiere mensaje de confirmacion esta semana.',
        ),
      ],
      tasks: const [
        EventTask(
          title: 'Confirmar venue con aforo para 80 personas',
          owner: 'Organizador',
          priority: 'high',
          deadline: '22 Mayo',
        ),
        EventTask(
          title: 'Confirmar segundo speaker y tema final',
          owner: 'Speakers lead',
          priority: 'high',
          deadline: '23 Mayo',
        ),
        EventTask(
          title: 'Cerrar sponsor de coffee break',
          owner: 'Sponsors lead',
          priority: 'high',
          deadline: '24 Mayo',
        ),
        EventTask(
          title: 'Publicar formulario de registro',
          owner: 'Comunicaciones',
          priority: 'medium',
          deadline: '24 Mayo',
        ),
        EventTask(
          title: 'Preparar plantilla de certificados',
          owner: 'Voluntarios',
          priority: 'medium',
          deadline: '28 Mayo',
        ),
        EventTask(
          title: 'Enviar recordatorio a asistentes registrados',
          owner: 'Comunicaciones',
          priority: 'medium',
          deadline: '29 Mayo',
        ),
      ],
      risks: const [
        EventRisk(
          title: 'Sponsor sin confirmar',
          detail: 'El presupuesto de S/500 queda ajustado para 80 personas si el coffee break no se cubre.',
          level: 'high',
        ),
        EventRisk(
          title: 'Speaker pendiente',
          detail: 'Hay un segundo ponente recomendado, pero todavia falta confirmacion.',
          level: 'medium',
        ),
        EventRisk(
          title: 'Certificados sin responsable final',
          detail: 'La tarea existe, pero necesita aprobacion de plantilla antes del evento.',
          level: 'medium',
        ),
      ],
      messages: const [
        MessageDraft(
          type: 'speaker_invitation',
          recipient: 'Luis Mendoza',
          content: 'Hola Luis, queremos invitarte al meetup Flutter Piura sobre Flutter + IA. Seria una charla practica de 35 minutos con Q&A.',
        ),
        MessageDraft(
          type: 'sponsor_followup',
          recipient: 'Tech Sponsor Piura',
          content: 'Hola equipo, estamos organizando un meetup para 80 asistentes y buscamos confirmar apoyo para coffee break. Podemos incluir presencia de marca y mencion durante el evento.',
        ),
        MessageDraft(
          type: 'attendee_announcement',
          recipient: 'Comunidad Flutter Piura',
          content: 'Este sabado tendremos meetup de Flutter + IA en Piura. Cupos limitados, dos charlas practicas, networking y certificados.',
        ),
      ],
      steps: steps,
      status: AgentRunStatus.awaitingApproval,
    );
  }

  @override
  Future<EventPlan> executePlan(EventPlan plan) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final completedSteps = [
      ...plan.steps.take(3),
      const AgentStep(
        title: 'Aprobacion recibida',
        detail: 'El organizador autorizo registrar el evento, tareas y mensajes.',
        tool: 'Human approval',
        done: true,
      ),
      const AgentStep(
        title: 'Escribir documentos operativos',
        detail: 'Evento, tareas, mensajes y readiness score quedaron listos para sincronizar con MongoDB.',
        tool: 'MongoDB MCP: insertMany',
        done: true,
      ),
    ];

    final updatedTasks = plan.tasks
        .asMap()
        .entries
        .map(
          (entry) => entry.key == 0
              ? entry.value.copyWith(status: EventTaskStatus.inProgress)
              : entry.value,
        )
        .toList();

    return plan.copyWith(
      readinessScore: 78,
      tasks: updatedTasks,
      steps: completedSteps,
      status: AgentRunStatus.executed,
    );
  }
}
