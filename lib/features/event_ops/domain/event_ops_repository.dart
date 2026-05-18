import 'event_ops_models.dart';

abstract interface class EventOpsRepository {
  Future<EventPlan> planMeetup(String goal);

  Future<EventPlan> executePlan(EventPlan plan);
}
