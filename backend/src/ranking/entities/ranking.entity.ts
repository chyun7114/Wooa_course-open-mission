import { relations } from 'drizzle-orm';
import { pgTable, integer } from 'drizzle-orm/pg-core';
import { baseColumns } from 'src/common/db/base.entity';
import { Member } from 'src/member/entity';

export const Ranking = pgTable('ranking', {
    ...baseColumns,
    score: integer('score').notNull(),
});

export const rankingRelations = relations(Member, ({ one }) => ({
    member: one(Member, {
        fields: [Member.id],
        references: [Member.id],
    }),
}));
