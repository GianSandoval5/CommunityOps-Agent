import type { AgentRun, ApprovalRequest, EventGoalRequest } from '../types/event-ops.js';
import { EventStoreService } from './event-store.service.js';
import { GeminiPlannerService } from './gemini-planner.service.js';

export class AgentGatewayService {
  private lastRun: AgentRun | null = null;

  constructor(
    private readonly planner = new GeminiPlannerService(),
    private readonly eventStore = new EventStoreService(),
  ) {}

  async planEvent(request: EventGoalRequest): Promise<AgentRun> {
    const runId = request.runId ?? `run_${Date.now()}`;

    const fallbackRun: AgentRun = {
      id: runId,
      status: 'awaiting_approval',
      goal: request.goal,
      readinessScore: 72,
      event: {
        name: 'Flutter Piura Meetup: Flutter + AI',
        dateLabel: 'Saturday, May 30 2026',
        location: 'Piura, Peru',
        capacity: 80,
        budget: 500,
        status: 'planning',
        topics: ['Flutter', 'AI', 'Firebase'],
      },
      agenda: [
        '05:00 PM - Registration and welcome',
        '05:20 PM - Talk 1: Flutter apps with applied AI',
        '06:05 PM - Coffee break and networking',
        '06:25 PM - Talk 2: Firebase + Gemini for real products',
        '07:10 PM - Q&A, community announcements, and group photo',
      ],
      speakers: [
        {
          name: 'Maria Torres',
          topic: 'Flutter apps with applied AI',
          availability: 'Saturday afternoon',
          rating: 4.8,
          reason: 'High historical rating and strong fit for Flutter + AI.',
        },
        {
          name: 'Luis Mendoza',
          topic: 'Firebase + Gemini for real products',
          availability: 'Pending confirmation',
          rating: 4.6,
          reason: 'Practical serverless experience and live demo background.',
        },
      ],
      sponsors: [
        {
          name: 'Tech Sponsor Piura',
          offer: 'Partial coffee break sponsorship',
          status: 'pending',
          contactHint: 'Needs confirmation this week.',
        },
      ],
      tasks: [
        {
          title: 'Confirm venue capacity for 80 attendees',
          owner: 'Organizer',
          priority: 'high',
          deadline: 'May 22',
          status: 'pending',
        },
        {
          title: 'Confirm second speaker and final topic',
          owner: 'Speakers lead',
          priority: 'high',
          deadline: 'May 23',
          status: 'pending',
        },
        {
          title: 'Close coffee break sponsor',
          owner: 'Sponsors lead',
          priority: 'high',
          deadline: 'May 24',
          status: 'pending',
        },
        {
          title: 'Publish registration form',
          owner: 'Communications',
          priority: 'medium',
          deadline: 'May 24',
          status: 'pending',
        },
      ],
      messages: [
        {
          type: 'sponsor_followup',
          recipient: 'Tech Sponsor Piura',
          content: 'We are organizing a Flutter Piura meetup for 80 attendees and would like to confirm coffee break sponsorship support.',
          status: 'draft',
        },
        {
          type: 'speaker_invitation',
          recipient: 'Luis Mendoza',
          content: 'We would like to invite you to speak at Flutter Piura about Firebase + Gemini for real products.',
          status: 'draft',
        },
        {
          type: 'attendee_announcement',
          recipient: 'Flutter Piura community',
          content: 'This Saturday we will host a Flutter + AI meetup with practical talks, networking, and certificates.',
          status: 'draft',
        },
      ],
      risks: [
        {
          title: 'Sponsor not confirmed',
          detail: 'Coffee break depends on sponsor confirmation.',
          level: 'high',
        },
        {
          title: 'Second speaker pending',
          detail: 'One recommended speaker still needs confirmation.',
          level: 'medium',
        },
      ],
      steps: [
        {
          title: 'Read community memory',
          detail: 'Checked previous events, feedback, and topic performance.',
          tool: 'MongoDB MCP: find events, feedback',
          done: true,
        },
        {
          title: 'Match speakers and sponsors',
          detail: 'Selected candidates by topic fit and operational need.',
          tool: 'MongoDB MCP: aggregate speakers, sponsors',
          done: true,
        },
        {
          title: 'Build event plan',
          detail: 'Created agenda, tasks, risks, and message drafts.',
          tool: 'Gemini reasoning',
          done: true,
        },
        {
          title: 'Wait for approval',
          detail: 'Important writes are blocked until organizer approval.',
          tool: 'Approval checkpoint',
          done: false,
        },
      ],
    };

    const run = await this.planner.createPlan(request.goal, fallbackRun);
    await this.trySaveDraftRun(run);

    this.lastRun = run;
    return run;
  }

  async approveRun(request: ApprovalRequest): Promise<AgentRun> {
    const storedRun = await this.tryFindRun(request.runId);
    const run = this.lastRun?.id === request.runId
      ? this.lastRun
      : storedRun ?? (await this.planEvent({ goal: 'Approved CommunityOps event plan', runId: request.runId }));

    const executedRun: AgentRun = {
      ...run,
      status: 'executed',
      readinessScore: 78,
      tasks: run.tasks.map((task, index) => ({
        ...task,
        status: index === 0 ? 'in_progress' : task.status,
      })),
      steps: [
        ...run.steps.slice(0, 3),
        {
          title: 'Approval received',
          detail: `${request.approvedBy} approved event, tasks, and message drafts.`,
          tool: 'Human approval',
          done: true,
        },
        {
          title: 'Persist operational records',
          detail: 'Event, tasks, messages, risk summary, and run log are ready for MongoDB persistence.',
          tool: 'MongoDB MCP: insertMany',
          done: true,
        },
      ],
    };

    const persisted = await this.tryPersistApprovedRun(executedRun, request);
    const finalRun: AgentRun = persisted
      ? executedRun
      : {
          ...executedRun,
          steps: [
            ...executedRun.steps.slice(0, -1),
            {
              title: 'MongoDB persistence pending',
              detail: 'The plan was approved, but MongoDB could not be reached from this machine. Check DNS/network access and retry.',
              tool: 'MongoDB MCP: connection pending',
              done: false,
            },
          ],
        };

    this.lastRun = finalRun;
    return finalRun;
  }

  private async trySaveDraftRun(run: AgentRun): Promise<void> {
    try {
      await this.eventStore.saveDraftRun(run);
    } catch (error) {
      console.warn('MongoDB draft persistence skipped:', error);
    }
  }

  private async tryFindRun(runId: string): Promise<AgentRun | null> {
    try {
      return await this.eventStore.findRun(runId);
    } catch (error) {
      console.warn('MongoDB run lookup skipped:', error);
      return null;
    }
  }

  private async tryPersistApprovedRun(run: AgentRun, approval: ApprovalRequest): Promise<boolean> {
    try {
      await this.eventStore.persistApprovedRun(run, approval);
      return true;
    } catch (error) {
      console.warn('MongoDB approved persistence skipped:', error);
      return false;
    }
  }
}
