# CommunityOps Agent

**AI event operations assistant for tech communities.**

CommunityOps Agent turns a high-level community event goal into an executable operations plan: agenda, tasks, risks, speaker outreach, sponsor follow-up, message drafts, approval checkpoints, and MongoDB persistence.

Built by **Gian Sandoval** for the Google Cloud Agent Builder + Gemini hackathon, targeting the **MongoDB partner track**.

- GitHub: [@GianSandoval5](https://github.com/GianSandoval5)
- LinkedIn: [giansandoval](https://www.linkedin.com/in/giansandoval)
- License: [MIT](LICENSE)

## Why This Exists

Community events are often coordinated across WhatsApp chats, spreadsheets, notes, memory, and last-minute reminders. That creates repeated planning work, missed tasks, unclear ownership, weak sponsor follow-up, and poor continuity between events.

CommunityOps Agent solves that by giving organizers an operational AI assistant that can:

- understand a real event goal,
- reason through the logistics,
- produce an actionable plan,
- draft communication,
- detect risk,
- ask for human approval,
- and persist the approved plan in MongoDB.

The initial use case is **Flutter Piura**, but the workflow can apply to developer communities, university clubs, bootcamps, meetups, and local tech groups.

## Hackathon Fit

This project is designed for the challenge goal: **AI that does not only answer, but helps people act.**

CommunityOps Agent is not just a chatbot. It performs a multi-step supervised workflow:

1. Receives an event objective.
2. Uses Gemini to generate an operations plan.
3. Produces event agenda, tasks, risks, and message drafts.
4. Shows a readiness score and execution timeline.
5. Requests human approval before important writes.
6. Persists approved records in MongoDB Atlas.
7. Displays integration status for Gemini, MongoDB, and the current run.

## Partner Track

**Selected partner: MongoDB**

MongoDB is used as the operational memory and persistence layer for:

- `agent_runs`
- `events`
- `tasks`
- `messages`
- `risks`
- `approvals`

The current MVP persists approved outputs to MongoDB Atlas through the backend. The repository also includes MCP-oriented agent documentation in [`agent/tools.md`](agent/tools.md) and [`agent/workflows.md`](agent/workflows.md), so the workflow can be connected to a MongoDB MCP server as the hackathon environment requires.

## Demo Scenario

Prompt used in the demo:

```txt
Organiza un meetup de Flutter Piura para 80 personas sobre Flutter + IA,
con 2 charlas, presupuesto de S/500, coffee break y certificados.
```

The agent creates:

- event plan,
- agenda,
- readiness score,
- task list,
- risk analysis,
- speaker and sponsor recommendations,
- message drafts,
- human approval checkpoint,
- MongoDB records after approval.

## What Judges Should Notice

- **Beyond chat:** the agent creates operational artifacts and writes approved records.
- **Human control:** important writes happen only after approval.
- **Real persistence:** approved runs are stored in MongoDB Atlas.
- **Visible trace:** the dashboard shows agent steps, readiness score, Gemini status, MongoDB sync status, and run ID.
- **Practical problem:** the workflow is grounded in real community event operations.

## Architecture

```txt
Flutter Web Dashboard
  |
  v
Node.js / Express Agent Gateway
  |
  v
Gemini API
  |
  v
MongoDB Atlas
```

Hackathon framing:

```txt
Google Cloud Agent Builder + Gemini
  |
  v
MongoDB MCP Server
  |
  v
MongoDB Atlas
```

## Tech Stack

- Flutter Web
- Dart
- Node.js
- TypeScript
- Express
- Gemini API
- MongoDB Atlas
- MongoDB Node.js Driver
- Google Cloud / Agent Platform setup

## Key Features

- Multi-step event planning.
- Gemini-generated operations plan.
- Event readiness score.
- Agent run timeline.
- Human approval before persistence.
- MongoDB-backed event memory.
- Speaker invitation drafts.
- Sponsor follow-up drafts.
- Risk detection.
- Production-oriented secret handling.

## Repository Structure

```txt
communityops_agent/
  lib/
    app/
    core/
    features/event_ops/
      data/
      domain/
      presentation/

  backend/
    src/
      routes/
      services/
      types/

  agent/
    system_prompt.md
    tools.md
    workflows.md

  data/
    sample_events.json
    sample_speakers.json
    sample_sponsors.json
    sample_attendees.json

  docs/
    architecture.md
    demo_script.md
    setup_steps.md
```

## Local Setup

Install Flutter dependencies:

```bash
flutter pub get
```

Install backend dependencies:

```bash
cd backend
npm install
```

Create the backend environment file:

```bash
copy .env.example .env
```

Fill `backend/.env` with your own local secrets.

## Environment Variables

Use [`backend/.env.example`](backend/.env.example) as the template.

Required values:

```env
PORT=8787
MONGODB_URI=your_mongodb_atlas_uri
MONGODB_DB=communityops
DNS_SERVERS=1.1.1.1,8.8.8.8
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-3-pro-preview
GOOGLE_CLOUD_PROJECT_ID=communityops-agent
GOOGLE_CLOUD_LOCATION=us-central1
```

Optional placeholders:

```env
AGENT_BUILDER_ENDPOINT=
AGENT_BUILDER_API_KEY=
```

## Running The App

Run backend:

```bash
cd backend
npm run dev
```

Run Flutter in local demo mode:

```bash
flutter run -d chrome
```

Run Flutter connected to the backend:

```bash
flutter run -d chrome --dart-define=USE_BACKEND=true --dart-define=API_BASE_URL=http://localhost:8787 --dart-define=GEMINI_MODEL_LABEL="Gemini 3 Pro Preview"
```

More setup notes are available in [`docs/setup_steps.md`](docs/setup_steps.md).

## Demo Verification

After planning and approving an event, MongoDB Atlas should contain records in:

```txt
agent_runs
approvals
events
messages
risks
tasks
```

The backend health endpoint:

```txt
http://localhost:8787/health
```

Expected response:

```json
{
  "ok": true,
  "service": "communityops-agent-backend"
}
```

## Deployment Target

Recommended production-style deployment:

```txt
https://giansandoval.com/communityops_agent
  -> Flutter Web static build

Cloud Run / backend hosting
  -> Node.js API

MongoDB Atlas
  -> operational database

Gemini API
  -> planning and reasoning
```

Flutter web build example:

```bash
flutter build web --base-href /communityops_agent/ --dart-define=USE_BACKEND=true --dart-define=API_BASE_URL=https://YOUR_BACKEND_URL --dart-define=GEMINI_MODEL_LABEL="Gemini 3 Pro Preview"
```

Detailed Cloud Run and `giansandoval.com/communityops_agent` deployment steps are available in [`docs/deploy.md`](docs/deploy.md).

## Security

Do **not** commit secrets.

Never push these files or values to GitHub:

- `backend/.env`
- `.env`
- Gemini API keys
- MongoDB Atlas connection strings
- database usernames/passwords
- service account credentials
- private tokens

Safe files to commit:

- `backend/.env.example`
- source code
- documentation
- sample JSON data without real personal data

The repository `.gitignore` already excludes local environment files, `node_modules`, build output, and backend generated output. Keep real secrets in local environment files or deployment provider secret managers.

## Open Source License

CommunityOps Agent is open source under the [MIT License](LICENSE).

Anyone can use, copy, modify, merge, publish, distribute, sublicense, and sell copies of this software under the MIT terms. The copyright notice must remain in copies or substantial portions of the software.

Copyright (c) 2026 Gian Sandoval.
