# Architecture

CommunityOps Agent uses a practical hackathon architecture:

```txt
User
  |
  v
Flutter Web App
  |
  v
Backend Agent Gateway
  |
  v
Google Cloud Agent Builder / Gemini
  |
  v
MongoDB MCP Server
  |
  v
MongoDB Atlas
```

## Frontend

The Flutter app is the operational console:

- Agent chat.
- Event dashboard.
- Readiness score.
- Agent run timeline.
- Agenda.
- Tasks.
- Risks.
- Message drafts.
- Approval action.

## Backend Agent Gateway

The backend should own:

- Session state.
- Auth and environment variables.
- Agent invocation.
- Approval validation.
- API responses for the dashboard.
- Audit logging.

Suggested endpoints:

```txt
POST /api/agent/message
POST /api/agent/approve
GET  /api/events/:eventId
GET  /api/events/:eventId/tasks
GET  /api/events/:eventId/messages
GET  /api/agent-runs/:runId
```

## Agent Layer

Google Cloud Agent Builder coordinates Gemini reasoning and tool use.

The agent must work in two phases:

1. Planning phase: read data, reason, prepare plan.
2. Execution phase: write only after approval.

## MongoDB Collections

```txt
events
attendees
speakers
sponsors
tasks
messages
feedback
agent_runs
approvals
```

MongoDB MCP is the partner integration that gives the agent useful operational memory and action capability.
