import { pgTable, text } from 'drizzle-orm/pg-core';
import { baseColumns } from 'src/common/db/base.entity';

export const Member = pgTable('member', {
    ...baseColumns,
    username: text('username').notNull(),
    email: text('email').notNull().unique(),
    password: text('password').notNull(),
});
