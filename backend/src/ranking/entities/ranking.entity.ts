import { relations } from 'drizzle-orm';
import { pgTable, integer } from 'drizzle-orm/pg-core';
import { baseColumns } from 'src/common/db/base.entity';
import { Member } from 'src/member/entity';

export const Ranking = pgTable('ranking', {
    ...baseColumns,
    memberId: integer('member_id')
        .notNull()
        .references(() => Member.id),
    score: integer('score').notNull(),
});

export const rankingRelations = relations(Ranking, ({ one }) => ({
    member: one(Member, {
        fields: [Ranking.memberId],
        references: [Member.id],
    }),
}));
