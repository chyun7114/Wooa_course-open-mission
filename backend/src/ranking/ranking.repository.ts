import { drizzle } from 'drizzle-orm/postgres-js';
import * as schema from '../common/db/schema';
import { Inject, Injectable } from '@nestjs/common';
import { DRIZZLE_ORM } from 'src/common/db';
import { Ranking } from './entities';
import { desc, eq } from 'drizzle-orm';

type DrizzleDB = ReturnType<typeof drizzle<typeof schema>>;

@Injectable()
export class MemberRepository {
    constructor(
        @Inject(DRIZZLE_ORM)
        private readonly db: DrizzleDB,
    ) {}

    async findByMember(memberId: number) {
        return await this.db
            .select()
            .from(Ranking)
            .where(eq(Ranking.memberId, memberId))
            .orderBy(desc(Ranking.score))
            .limit(1);
    }

    async upsertRanking(memberId: number, score: number) {
        const existing = await this.findByMember(memberId);

        if (existing.length > 0 && existing[0].score >= score) {
            return existing[0];
        }

        if (existing.length > 0) {
            return await this.db
                .update(Ranking)
                .set({ score })
                .where(eq(Ranking.memberId, memberId))
                .returning();
        } else {
            return await this.db.insert(Ranking).values({ memberId, score });
        }
    }

    async findTopRankings(limit: number = 10) {
        return await this.db
            .select()
            .from(Ranking)
            .orderBy(desc(Ranking.score))
            .limit(limit);
    }
}
