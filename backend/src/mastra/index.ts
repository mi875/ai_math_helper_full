
import { Mastra } from '@mastra/core/mastra';
import { PinoLogger } from '@mastra/loggers';
import { mathHelperAgent } from './agents/mathHelper.js';


export const mastra = new Mastra({
  agents: { mathHelperAgent },
  logger: new PinoLogger({
    name: 'Mastra',
    level: 'info',
  }),
});
