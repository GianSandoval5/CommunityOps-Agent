# Deployment Guide

This guide deploys the CommunityOps Agent backend to Cloud Run and builds Flutter Web for:

```txt
https://giansandoval.com/communityops_agent
```

## 1. Backend: Cloud Run

The backend lives in:

```txt
backend/
```

It exposes:

```txt
GET  /health
POST /api/agent/message
POST /api/agent/approve
GET  /api/events/:eventId
```

## 2. Required Cloud Run Environment Variables

Use Cloud Run variables/secrets for these values:

```env
MONGODB_URI=your_mongodb_atlas_uri
MONGODB_DB=communityops
DNS_SERVERS=1.1.1.1,8.8.8.8
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-3-pro-preview
GOOGLE_CLOUD_PROJECT_ID=communityops-agent
GOOGLE_CLOUD_LOCATION=us-central1
```

Do not commit real values to GitHub.

## 3. Deploy Backend From Local Machine

From the repository root:

```bash
cd backend
gcloud config set project communityops-agent
gcloud run deploy communityops-agent-api --source . --region us-central1 --allow-unauthenticated
```

During deployment, Cloud Run builds the Docker image from `backend/Dockerfile`.

After deployment, open the service in Google Cloud Console:

```txt
Cloud Run > communityops-agent-api > Edit & deploy new revision > Variables & Secrets
```

Add the required environment variables listed above.

Then deploy the new revision.

## 4. Deploy Backend From Cloud Shell

If the repository is on GitHub:

```bash
git clone https://github.com/GianSandoval5/YOUR_REPOSITORY_NAME.git
cd YOUR_REPOSITORY_NAME/backend
gcloud config set project communityops-agent
gcloud run deploy communityops-agent-api --source . --region us-central1 --allow-unauthenticated
```

Then configure the environment variables in Cloud Run.

## 5. Test Backend

Cloud Run returns a URL like:

```txt
https://communityops-agent-api-xxxxx-uc.a.run.app
```

Test:

```txt
https://communityops-agent-api-xxxxx-uc.a.run.app/health
```

Expected response:

```json
{
  "ok": true,
  "service": "communityops-agent-backend"
}
```

## 6. MongoDB Atlas Network Access

For a quick hackathon deployment, Atlas can allow:

```txt
0.0.0.0/0
```

For production, use a tighter network policy.

## 7. Build Flutter Web For giansandoval.com

From the repository root:

```bash
flutter pub get
flutter build web --base-href /communityops_agent/ --dart-define=USE_BACKEND=true --dart-define=API_BASE_URL=https://YOUR_CLOUD_RUN_URL --dart-define=GEMINI_MODEL_LABEL="Gemini 3 Pro Preview"
```

Replace:

```txt
https://YOUR_CLOUD_RUN_URL
```

with your real Cloud Run backend URL.

Upload everything inside:

```txt
build/web/
```

to:

```txt
public_html/communityops_agent/
```

## 8. Final Test

Open:

```txt
https://giansandoval.com/communityops_agent
```

Then:

1. Plan a meetup.
2. Approve execution.
3. Confirm the dashboard shows `MongoDB: Synced`.
4. Confirm MongoDB Atlas has new documents in:

```txt
agent_runs
approvals
events
messages
risks
tasks
```
