CREATE TABLE "problem_images" (
	"id" serial PRIMARY KEY NOT NULL,
	"uid" varchar(128) NOT NULL,
	"problem_id" integer NOT NULL,
	"user_id" varchar(128) NOT NULL,
	"original_filename" varchar(255) NOT NULL,
	"filename" varchar(255) NOT NULL,
	"file_path" varchar(500) NOT NULL,
	"file_url" varchar(500) NOT NULL,
	"mime_type" varchar(50) NOT NULL,
	"file_size" integer NOT NULL,
	"width" integer,
	"height" integer,
	"display_order" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "math_problems" DROP COLUMN "image_paths";