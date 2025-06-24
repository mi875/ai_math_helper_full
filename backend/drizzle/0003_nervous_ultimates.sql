ALTER TABLE "users" ADD COLUMN "profile_image_url" varchar(500);--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "profile_image_original_name" varchar(255);--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "profile_image_size" integer;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "profile_image_mime_type" varchar(50);