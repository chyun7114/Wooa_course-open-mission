import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';
import { baseColumns } from 'src/common/db/base.entity';

export const Member = pgTable('member', {
    ...baseColumns,
    username: text('username').notNull().unique(),
    email: text('email').notNull().unique(),
    password: text('password').notNull(),
});
