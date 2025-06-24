CREATE TABLE "api_usage" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" varchar(128) NOT NULL,
	"endpoint" varchar(255) NOT NULL,
	"tokens_consumed" integer NOT NULL,
	"request_data" text,
	"response_data" text,
	"status" varchar(20) NOT NULL,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "math_problems" ADD COLUMN "tokens_used" integer DEFAULT 0;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "total_tokens" integer DEFAULT 1000;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "used_tokens" integer DEFAULT 0;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "remaining_tokens" integer DEFAULT 1000;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "token_reset_date" timestamp;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "is_active" boolean DEFAULT true;