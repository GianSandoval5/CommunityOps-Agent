import type { AgentRun } from '../types/event-ops.js';

interface GeminiGenerateContentResponse {
  candidates?: Array<{
    content?: {
      parts?: Array<{
        text?: string;
      }>;
    };
  }>;
}

export class GeminiPlannerService {
  private readonly apiKey = process.env.GEMINI_API_KEY;
  private readonly model = process.env.GEMINI_MODEL ?? 'gemini-3-pro-preview';

  async createPlan(goal: string, fallback: AgentRun): Promise<AgentRun> {
    if (!this.apiKey) {
      return fallback;
    }

    try {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': this.apiKey,
          },
          body: JSON.stringify({
            contents: [
              {
                role: 'user',
                parts: [
                  {
                    text: this.buildPrompt(goal, fallback),
                  },
                ],
              },
            ],
            generationConfig: {
              temperature: 0.35,
              responseMimeType: 'application/json',
            },
          }),
        },
      );

      if (!response.ok) {
        const detail = await response.text();
        console.warn(`Gemini planning failed: ${response.status} ${detail}`);
        return fallback;
      }

      const payload = (await response.json()) as GeminiGenerateContentResponse;
      const text = payload.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!text) {
        return fallback;
      }

      return this.mergePlan(fallback, JSON.parse(text) as Partial<AgentRun>);
    } catch (error) {
      console.warn('Gemini planning fallback used:', error);
      return fallback;
    }
  }

  private buildPrompt(goal: string, fallback: AgentRun): string {
    return `
Eres CommunityOps Agent, un agente operativo para eventos de comunidades tech.

Objetivo del usuario:
${goal}

Genera un plan accionable para Flutter Piura. Debe consultar memoria operativa, proponer agenda, tareas, riesgos, speakers, sponsors y mensajes. No inventes confirmaciones reales; marca como pending lo que falte.

Devuelve SOLO JSON valido con esta forma:
{
  "readinessScore": number,
  "event": {
    "name": string,
    "dateLabel": string,
    "location": string,
    "capacity": number,
    "budget": number,
    "status": string,
    "topics": string[]
  },
  "agenda": string[],
  "speakers": [
    {
      "name": string,
      "topic": string,
      "availability": string,
      "rating": number,
      "reason": string
    }
  ],
  "sponsors": [
    {
      "name": string,
      "offer": string,
      "status": string,
      "contactHint": string
    }
  ],
  "tasks": [
    {
      "title": string,
      "owner": string,
      "priority": "low" | "medium" | "high",
      "deadline": string,
      "status": "pending" | "in_progress" | "done"
    }
  ],
  "risks": [
    {
      "title": string,
      "detail": string,
      "level": "low" | "medium" | "high"
    }
  ],
  "messages": [
    {
      "type": string,
      "recipient": string,
      "content": string,
      "status": "draft"
    }
  ],
  "steps": [
    {
      "title": string,
      "detail": string,
      "tool": string,
      "done": boolean
    }
  ]
}

Usa este plan base como referencia y mejora el contenido sin cambiar el contrato:
${JSON.stringify(fallback)}
`;
  }

  private mergePlan(fallback: AgentRun, generated: Partial<AgentRun>): AgentRun {
    return {
      ...fallback,
      readinessScore: this.numberOr(fallback.readinessScore, generated.readinessScore),
      event: {
        ...fallback.event,
        ...(generated.event ?? {}),
      },
      agenda: this.arrayOr(fallback.agenda, generated.agenda),
      speakers: this.arrayOr(fallback.speakers, generated.speakers),
      sponsors: this.arrayOr(fallback.sponsors, generated.sponsors),
      tasks: this.arrayOr(fallback.tasks, generated.tasks),
      messages: this.arrayOr(fallback.messages, generated.messages),
      risks: this.arrayOr(fallback.risks, generated.risks),
      steps: this.arrayOr(fallback.steps, generated.steps),
    };
  }

  private numberOr(fallback: number, value: unknown): number {
    return typeof value === 'number' ? value : fallback;
  }

  private arrayOr<T>(fallback: T[], value: unknown): T[] {
    return Array.isArray(value) && value.length > 0 ? (value as T[]) : fallback;
  }
}
