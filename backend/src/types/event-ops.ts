export type AgentRunStatus = 'draft' | 'awaiting_approval' | 'executed';

export interface EventGoalRequest {
  goal: string;
  runId?: string;
}

export interface ApprovalRequest {
  runId: string;
  approvedBy: string;
}

export interface EventTask {
  title: string;
  owner: string;
  priority: 'low' | 'medium' | 'high';
  deadline: string;
  status: 'pending' | 'in_progress' | 'done';
}

export interface CommunityEvent {
  name: string;
  dateLabel: string;
  location: string;
  capacity: number;
  budget: number;
  status: string;
  topics: string[];
}

export interface Speaker {
  name: string;
  topic: string;
  availability: string;
  rating: number;
  reason: string;
}

export interface Sponsor {
  name: string;
  offer: string;
  status: string;
  contactHint: string;
}

export interface MessageDraft {
  type: string;
  recipient: string;
  content: string;
  status: 'draft' | 'approved' | 'sent';
}

export interface AgentRun {
  id: string;
  status: AgentRunStatus;
  goal: string;
  readinessScore: number;
  event: CommunityEvent;
  agenda: string[];
  speakers: Speaker[];
  sponsors: Sponsor[];
  eventId?: string;
  tasks: EventTask[];
  messages: MessageDraft[];
  risks: Array<{
    title: string;
    detail: string;
    level: 'low' | 'medium' | 'high';
  }>;
  steps: Array<{
    title: string;
    detail: string;
    tool: string;
    done: boolean;
  }>;
}
