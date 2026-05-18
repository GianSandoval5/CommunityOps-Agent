import { Router } from 'express';

import { EventStoreService } from '../services/event-store.service.js';

export const eventsRouter = Router();

const eventStore = new EventStoreService();

eventsRouter.get('/:eventId', async (request, response, next) => {
  try {
    const snapshot = await eventStore.getEventSnapshot(request.params.eventId);
    response.json(snapshot);
  } catch (error) {
    next(error);
  }
});

eventsRouter.get('/:eventId/tasks', async (request, response, next) => {
  try {
    const snapshot = await eventStore.getEventSnapshot(request.params.eventId);
    response.json({
      eventId: request.params.eventId,
      tasks: snapshot.tasks,
    });
  } catch (error) {
    next(error);
  }
});

eventsRouter.get('/:eventId/messages', async (request, response, next) => {
  try {
    const snapshot = await eventStore.getEventSnapshot(request.params.eventId);
    response.json({
      eventId: request.params.eventId,
      messages: snapshot.messages,
    });
  } catch (error) {
    next(error);
  }
});
