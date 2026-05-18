# Setup Steps

These are the manual steps to run the project after the repository changes.

## 1. Flutter Demo Mode

The app uses local in-memory demo data by default.

From the project root:

```bash
flutter pub get
flutter run -d chrome
```

No backend is required for this mode.

## 2. Backend Mode

Install backend dependencies manually:

```bash
cd backend
npm install
```

Create the backend environment file:

```bash
copy .env.example .env
```

The backend can run without Gemini, but it will use the fallback plan. To enable Gemini and MongoDB persistence, fill these values:

```bash
MONGODB_URI=mongodb+srv://communityops_user:YOUR_PASSWORD@communityops-cluster.idgq0um.mongodb.net/communityops?retryWrites=true&w=majority&appName=communityops-cluster
MONGODB_DB=communityops
DNS_SERVERS=1.1.1.1,8.8.8.8
GEMINI_API_KEY=your_google_key
GEMINI_MODEL=gemini-3-pro-preview
GOOGLE_CLOUD_PROJECT_ID=communityops-agent
GOOGLE_CLOUD_LOCATION=us-central1
```

Start the backend:

```bash
npm run dev
```

The backend runs at:

```txt
http://localhost:8787
```

Health check:

```txt
http://localhost:8787/health
```

## 3. Run Flutter Connected To Backend

From the project root:

```bash
flutter run -d chrome --dart-define=USE_BACKEND=true --dart-define=API_BASE_URL=http://localhost:8787
```

This switches the app from:

```txt
InMemoryEventOpsRepository
```

to:

```txt
ApiEventOpsRepository
```

## 4. Where To Connect Real Agent Builder

Edit:

```txt
backend/src/services/agent-gateway.service.ts
```

Replace the simulated response in:

```txt
planEvent()
approveRun()
```

with calls to Google Cloud Agent Builder.

## 5. Where To Connect MongoDB

Recommended next files:

```txt
backend/src/services/mongodb.service.ts
backend/src/services/event-store.service.ts
```

The backend should persist:

```txt
events
tasks
messages
risks
agent_runs
approvals
```

## 6. Where Flutter Reads The API

Edit:

```txt
lib/features/event_ops/data/api_event_ops_repository.dart
```

This file owns:

```txt
POST /api/agent/message
POST /api/agent/approve
```

## 7. Where Demo Data Lives

Flutter local demo:

```txt
lib/features/event_ops/data/in_memory_event_ops_repository.dart
```

JSON examples for MongoDB seed:

```txt
data/sample_events.json
data/sample_speakers.json
data/sample_sponsors.json
data/sample_attendees.json
```
