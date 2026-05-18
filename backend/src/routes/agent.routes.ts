import { Router } from 'express';

import { AgentGatewayService } from '../services/agent-gateway.service.js';

export const agentRouter = Router();

const agentGateway = new AgentGatewayService();

agentRouter.post('/message', async (request, response, next) => {
  try {
    const result = await agentGateway.planEvent(request.body);
    response.json(result);
  } catch (error) {
    next(error);
  }
});

agentRouter.post('/approve', async (request, response, next) => {
  try {
    const result = await agentGateway.approveRun(request.body);
    response.json(result);
  } catch (error) {
    next(error);
  }
});
