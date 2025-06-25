CREATE TABLE "ai_feedbacks" (
	"id" serial PRIMARY KEY NOT NULL,
	"uid" varchar(128) NOT NULL,
	"problem_id" integer NOT NULL,
	"user_id" varchar(128) NOT NULL,
	"feedback_text" text NOT NULL,
	"feedback_type" varchar(20) NOT NULL,
	"tokens_consumed" integer NOT NULL,
	"created_at" timestamp DEFAULT now()
);
