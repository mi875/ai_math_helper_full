CREATE TABLE "ai_feedbacks" (
	"id" serial PRIMARY KEY NOT NULL,
	"uid" varchar(128) NOT NULL,
	"problem_id" integer NOT NULL,
	"user_id" varchar(128) NOT NULL,
	"feedback_type" varchar(50) NOT NULL,
	"content" text NOT NULL,
	"tokens_used" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "math_problems" (
	"id" serial PRIMARY KEY NOT NULL,
	"uid" varchar(128) NOT NULL,
	"notebook_id" integer NOT NULL,
	"user_id" varchar(128) NOT NULL,
	"title" varchar(255) NOT NULL,
	"description" text,
	"image_paths" text,
	"scribble_data" text,
	"status" varchar(20) DEFAULT 'unsolved',
	"tags" text,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "notebooks" (
	"id" serial PRIMARY KEY NOT NULL,
	"uid" varchar(128) NOT NULL,
	"user_id" varchar(128) NOT NULL,
	"title" varchar(255) NOT NULL,
	"description" text,
	"cover_color" varchar(50) DEFAULT 'default',
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
