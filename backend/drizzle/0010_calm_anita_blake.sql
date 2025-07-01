CREATE TABLE "chat_threads" (
	"id" serial PRIMARY KEY NOT NULL,
	"uid" varchar(128) NOT NULL,
	"problem_id" integer NOT NULL,
	"user_id" varchar(128) NOT NULL,
	"thread_id" varchar(128) NOT NULL,
	"resource_id" varchar(256) NOT NULL,
	"title" varchar(255),
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
