ALTER TABLE "users" ADD COLUMN "username" varchar(50);--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "is_profile_complete" boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_username_unique" UNIQUE("username");