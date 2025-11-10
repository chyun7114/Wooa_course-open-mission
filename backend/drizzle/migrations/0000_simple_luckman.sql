CREATE TABLE "member" (
	"id" serial PRIMARY KEY NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"deleted" boolean DEFAULT false,
	"user_id" text NOT NULL,
	"password" text NOT NULL,
	"name" text NOT NULL,
	CONSTRAINT "member_user_id_unique" UNIQUE("user_id")
);
