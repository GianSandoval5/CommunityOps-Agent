import cors from 'cors';
import 'dotenv/config';
import express from 'express';

import { agentRouter } from './routes/agent.routes.js';
import { eventsRouter } from './routes/events.routes.js';

const app = express();
const port = Number(process.env.PORT ?? 8787);

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/health', (_request, response) => {
  response.json({ ok: true, service: 'communityops-agent-backend' });
});

app.use('/api/agent', agentRouter);
app.use('/api/events', eventsRouter);

app.use((error: unknown, _request: express.Request, response: express.Response, _next: express.NextFunction) => {
  console.error(error);
  response.status(500).json({
    error: 'internal_server_error',
    detail: error instanceof Error ? error.message : String(error),
  });
});

app.listen(port, () => {
  console.log(`CommunityOps backend listening on http://localhost:${port}`);
});
