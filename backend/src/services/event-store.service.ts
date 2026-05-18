import type { AgentRun, ApprovalRequest } from '../types/event-ops.js';
import { MongoDbService } from './mongodb.service.js';

export class EventStoreService {
  constructor(private readonly mongoDb = new MongoDbService()) {}

  async saveDraftRun(run: AgentRun): Promise<void> {
    const db = await this.mongoDb.getDb();
    if (!db) {
      return;
    }

    await db.collection('agent_runs').updateOne(
      { id: run.id },
      {
        $set: {
          ...run,
          updatedAt: new Date(),
        },
        $setOnInsert: {
          createdAt: new Date(),
        },
      },
      { upsert: true },
    );
  }

  async findRun(runId: string): Promise<AgentRun | null> {
    const db = await this.mongoDb.getDb();
    if (!db) {
      return null;
    }

    return db.collection<AgentRun>('agent_runs').findOne({ id: runId });
  }

  async persistApprovedRun(run: AgentRun, approval: ApprovalRequest): Promise<void> {
    const db = await this.mongoDb.getDb();
    if (!db) {
      return;
    }

    const eventId = run.eventId ?? run.id;
    const now = new Date();

    await db.collection('events').updateOne(
      { id: eventId },
      {
        $set: {
          id: eventId,
          ...run.event,
          readinessScore: run.readinessScore,
          agenda: run.agenda,
          speakers: run.speakers,
          sponsors: run.sponsors,
          agentRunId: run.id,
          updatedAt: now,
        },
        $setOnInsert: {
          createdAt: now,
        },
      },
      { upsert: true },
    );

    await db.collection('tasks').deleteMany({ eventId });
    if (run.tasks.length > 0) {
      await db.collection('tasks').insertMany(
        run.tasks.map((task, index) => ({
          ...task,
          id: `${eventId}_task_${index + 1}`,
          eventId,
          agentRunId: run.id,
          createdAt: now,
        })),
      );
    }

    await db.collection('messages').deleteMany({ eventId });
    if (run.messages.length > 0) {
      await db.collection('messages').insertMany(
        run.messages.map((message, index) => ({
          ...message,
          id: `${eventId}_message_${index + 1}`,
          eventId,
          agentRunId: run.id,
          createdAt: now,
        })),
      );
    }

    await db.collection('risks').deleteMany({ eventId });
    if (run.risks.length > 0) {
      await db.collection('risks').insertMany(
        run.risks.map((risk, index) => ({
          ...risk,
          id: `${eventId}_risk_${index + 1}`,
          eventId,
          agentRunId: run.id,
          createdAt: now,
        })),
      );
    }

    await db.collection('approvals').insertOne({
      runId: run.id,
      eventId,
      approvedBy: approval.approvedBy,
      approvedAt: now,
    });

    await db.collection('agent_runs').updateOne(
      { id: run.id },
      {
        $set: {
          ...run,
          eventId,
          updatedAt: now,
        },
        $setOnInsert: {
          createdAt: now,
        },
      },
      { upsert: true },
    );
  }

  async getEventSnapshot(eventId: string): Promise<{
    event: Record<string, unknown> | null;
    tasks: Array<Record<string, unknown>>;
    messages: Array<Record<string, unknown>>;
    risks: Array<Record<string, unknown>>;
  }> {
    const db = await this.mongoDb.getDb();
    if (!db) {
      return {
        event: null,
        tasks: [],
        messages: [],
        risks: [],
      };
    }

    const [event, tasks, messages, risks] = await Promise.all([
      db.collection('events').findOne({ id: eventId }),
      db.collection('tasks').find({ eventId }).toArray(),
      db.collection('messages').find({ eventId }).toArray(),
      db.collection('risks').find({ eventId }).toArray(),
    ]);

    return {
      event,
      tasks,
      messages,
      risks,
    };
  }
}
