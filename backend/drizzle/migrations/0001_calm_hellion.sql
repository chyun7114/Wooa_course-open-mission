CREATE TABLE "ranking" (
	"id" serial PRIMARY KEY NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"deleted" boolean DEFAULT false,
	"member_id" integer NOT NULL,
	"score" integer NOT NULL
);
--> statement-breakpoint
ALTER TABLE "ranking" ADD CONSTRAINT "ranking_member_id_member_id_fk" FOREIGN KEY ("member_id") REFERENCES "public"."member"("id") ON DELETE no action ON UPDATE no action;