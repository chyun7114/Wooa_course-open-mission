CREATE TABLE "member" (
	"id" serial PRIMARY KEY NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"deleted" boolean DEFAULT false,
	"username" text NOT NULL,
	"email" text NOT NULL,
	"password" text NOT NULL,
<<<<<<<< HEAD:backend/drizzle/migrations/0000_equal_thor.sql
	CONSTRAINT "member_username_unique" UNIQUE("username"),
========
>>>>>>>> a56e290 (Feat(Backend): 회원가입/로그인을 위한 repository 코드 구현):backend/drizzle/migrations/0000_moaning_havok.sql
	CONSTRAINT "member_email_unique" UNIQUE("email")
);
