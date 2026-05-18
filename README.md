# CommunityOps Agent

AI-powered event operations assistant for tech communities, built for the Google Cloud Agent Builder + Gemini hackathon and the MongoDB partner track.

CommunityOps Agent helps organizers plan meetups, coordinate speakers, manage sponsors, create tasks, detect risks, draft communications, request human approval, and persist the approved plan in MongoDB Atlas.

## Author

Created by **Gian Sandoval**.

- GitHub: [@GianSandoval5](https://github.com/GianSandoval5)
- LinkedIn: [giansandoval](https://www.linkedin.com/in/giansandoval)

## Hackathon Track

Recommended track: **MongoDB**.

MongoDB Atlas is used as the agent's operational memory and persistence layer for:

- events
- tasks
- messages
- risks
- approvals
- agent runs

The agent goes beyond chat: it plans, generates operational artifacts, asks for approval, and writes the approved result into the database.

## Core Demo

Example user goal:

```txt
Organiza un meetup de Flutter Piura para 80 personas sobre Flutter + IA,
con 2 charlas, presupuesto de S/500, coffee break y certificados.
```

The system then:

1. Uses Gemini to generate an event operations plan.
2. Suggests agenda, tasks, risks, speakers, sponsors, and message drafts.
3. Shows readiness score and agent run steps in the Flutter dashboard.
4. Requires human approval before writing operational data.
5. Persists the approved run in MongoDB Atlas.

## Architecture

```txt
Flutter Web UI
  |
  v
Backend API / Agent Gateway
  |
  v
Gemini API / Agent reasoning
  |
  v
MongoDB Atlas
```

Planned/compatible hackathon framing:

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
- Node.js + TypeScript
- Express
- Gemini API
- MongoDB Atlas
- MongoDB Node.js Driver
- Google Cloud / Agent Platform setup

## Project Structure

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

## Running Locally

Flutter local demo mode:

```bash
flutter pub get
flutter run -d chrome
```

Backend mode:

```bash
cd backend
npm install
npm run dev
```

Run Flutter connected to the backend:

```bash
flutter run -d chrome --dart-define=USE_BACKEND=true --dart-define=API_BASE_URL=http://localhost:8787 --dart-define=GEMINI_MODEL_LABEL="Gemini 3 Pro Preview"
```

Manual setup details are available in [docs/setup_steps.md](docs/setup_steps.md).

## Environment Variables

Create a local file:

```txt
backend/.env
```

Use [backend/.env.example](backend/.env.example) as the template.

Required local values:

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

## Security

Do **not** commit secrets.

Never push these files or values to GitHub:

- `backend/.env`
- `.env`
- Gemini API keys
- MongoDB Atlas connection strings
- database usernames/passwords
- service account secrets

The repository includes `.gitignore` rules for `.env`, `backend/.env`, `node_modules`, `dist`, and Flutter build output. Keep real credentials only in local environment files or your deployment provider's secret manager.

Safe files to commit:

- `backend/.env.example`
- docs
- source code
- sample JSON data without real personal data

## Deployment Notes

Recommended production-style deployment:

```txt
https://giansandoval.com/communityops_agent
  -> Flutter Web static build

Cloud Run / backend hosting
  -> Node.js API

MongoDB Atlas
  -> operational data

Gemini API
  -> planning and reasoning
```

Flutter web build example:

```bash
flutter build web --base-href /communityops_agent/ --dart-define=USE_BACKEND=true --dart-define=API_BASE_URL=https://YOUR_BACKEND_URL --dart-define=GEMINI_MODEL_LABEL="Gemini 3 Pro Preview"
```

## License

This project is open source under the [MIT License](LICENSE).

You are free to use, copy, modify, merge, publish, distribute, sublicense, and sell copies of the software under the license terms. Attribution to the original copyright holder must remain in copies or substantial portions of the software.
