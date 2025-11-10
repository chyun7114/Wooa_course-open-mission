import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';
import { baseColumns } from 'src/common/db/base.entity';

export const member = pgTable('member', {
    ...baseColumns,
    userId: text('user_id').notNull().unique(),
    password: text('password').notNull(),
    name: text('name').notNull(),
});
