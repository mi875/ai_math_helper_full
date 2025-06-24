
import { Mastra } from '@mastra/core';
import { createGoogleGenerativeAI } from '@ai-sdk/google';
import { mathExplainerAgent, mathSolverAgent, practiceGeneratorAgent } from './agents/problemReader.js';


export const google = createGoogleGenerativeAI({
  // custom settings
});

export const mastra = new Mastra({
  agents: {
    mathSolver: mathSolverAgent,
    mathExplainer: mathExplainerAgent,
    practiceGenerator: practiceGeneratorAgent
  }
});