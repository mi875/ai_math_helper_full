import { Context as HonoContext } from 'hono';

// Define user type for authentication
export interface User {
  uid: string;
  email?: string;
  displayName?: string;
}

// Extend Hono's Context interface to include our custom types
declare module 'hono' {
  interface Context {
    get(key: 'user'): User;
  }
  
  interface ContextVariableMap {
    user: User;
  }
}
