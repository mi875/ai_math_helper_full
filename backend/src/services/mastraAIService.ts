// Mastra AI Service Integration
// This service connects the Hono API with Mastra AI agents

import { mastra } from "../mastra/index.js";



export interface MathProblemRequest {
  problem: string;
  difficulty?: 'easy' | 'medium' | 'hard';
  gradeLevel?: string;
  showSteps?: boolean;
}

export interface ConceptExplanationRequest {
  concept: string;
  gradeLevel?: string;
  includeExamples?: boolean;
  language?: 'japanese' | 'english' | 'both';
}

export interface PracticeGenerationRequest {
  topic: string;
  difficulty?: 'easy' | 'medium' | 'hard';
  count?: number;
  gradeLevel?: string;
}

export class MastraAIService {
  
  async solveMathProblem(request: MathProblemRequest): Promise<string> {
    try {
      const { problem, difficulty = 'medium', gradeLevel, showSteps = true } = request;
      
      const prompt = `
Grade Level: ${gradeLevel || 'General'}
Difficulty: ${difficulty}
Show Steps: ${showSteps}

Problem: ${problem}

Please solve this math problem step by step. Provide a clear, educational solution that would help a Japanese student understand the process.
      `.trim();

      // Use the math solver agent from Mastra
      const response = await mastra.getAgent('mathSolver').generate(prompt);

      return response.text || 'Sorry, I could not solve this problem at the moment.';
      
    } catch (error) {
      console.error('Mastra AI solve error:', error);
      throw new Error('AI service error: Unable to solve the problem');
    }
  }

  async explainConcept(request: ConceptExplanationRequest): Promise<string> {
    try {
      const { concept, gradeLevel, includeExamples = true, language = 'both' } = request;
      
      const prompt = `
Concept: ${concept}
Grade Level: ${gradeLevel || 'General'}
Include Examples: ${includeExamples}
Language: ${language}

Please explain this mathematical concept in a way that's appropriate for Japanese students at the specified grade level. Include practical examples and real-world applications where relevant.
      `.trim();

      const response = await mastra.getAgent('mathExplainer').generate(prompt);

      return response.text || 'Sorry, I could not explain this concept at the moment.';
      
    } catch (error) {
      console.error('Mastra AI explain error:', error);
      throw new Error('AI service error: Unable to explain the concept');
    }
  }

  async generatePracticeProblems(request: PracticeGenerationRequest): Promise<any[]> {
    try {
      const { topic, difficulty = 'medium', count = 5, gradeLevel } = request;
      
      const prompt = `
Topic: ${topic}
Difficulty: ${difficulty}
Number of Problems: ${count}
Grade Level: ${gradeLevel || 'General'}

Generate ${count} practice problems for the topic "${topic}" at ${difficulty} difficulty level. 
Each problem should be appropriate for Japanese students.

Please format your response as a JSON array where each problem has:
- problem: The problem statement
- solution: Complete step-by-step solution
- difficulty: The difficulty level
- topic: The mathematical topic

Example format:
[
  {
    "problem": "Solve: 2x + 5 = 13",
    "solution": "Step 1: Subtract 5 from both sides...",
    "difficulty": "medium",
    "topic": "Linear Equations"
  }
]
      `.trim();

      const response = await mastra.getAgent('practiceGenerator').generate(prompt);

      try {
        // Try to parse the JSON response
        const problems = JSON.parse(response.text || '[]');
        return Array.isArray(problems) ? problems : [];
      } catch (parseError) {
        // If JSON parsing fails, create a structured response from the text
        console.warn('Failed to parse JSON from AI response, creating fallback structure');
        return [{
          problem: `Practice problem for ${topic}`,
          solution: response.text || 'No solution provided',
          difficulty,
          topic
        }];
      }
      
    } catch (error) {
      console.error('Mastra AI generate error:', error);
      throw new Error('AI service error: Unable to generate practice problems');
    }
  }

  // Utility method to estimate token usage (for billing purposes)
  estimateTokenUsage(operation: string, textLength: number): number {
    const baseTokens = {
      solve: 15,
      explain: 20,
      generate: 25
    };
    
    const baseToken = baseTokens[operation as keyof typeof baseTokens] || 10;
    const lengthFactor = Math.ceil(textLength / 100); // 1 additional token per 100 characters
    
    return baseToken + lengthFactor;
  }
}

export const mastraAIService = new MastraAIService();
