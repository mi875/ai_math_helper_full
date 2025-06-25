
import { Mastra } from '@mastra/core/mastra';
import { PinoLogger } from '@mastra/loggers';
import { mathHelper } from './agents/mathHelper.js';

export const mastra = new Mastra({
  agents: { mathHelper },
  logger: new PinoLogger({
    name: 'Mastra',
    level: 'info',
  }),
});
