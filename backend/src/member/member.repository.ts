import { Inject, Injectable } from '@nestjs/common';
import { DRIZZLE_ORM } from '../common/db';
import { drizzle } from 'drizzle-orm/postgres-js';
import * as schema from '../common/db/schema';
import { Member } from './entity';
import { eq } from 'drizzle-orm';

type DrizzleDB = ReturnType<typeof drizzle<typeof schema>>;

@Injectable()
export class MemberRepository {
    constructor(
        @Inject(DRIZZLE_ORM)
        private readonly db: DrizzleDB,
    ) {}

    async createMember(data: {
        username: string;
        email: string;
        password: string;
    }) {
        const [member] = await this.db
            .insert(Member)
            .values({
                username: data.username,
                email: data.email,
                password: data.password,
            })
            .returning();

        return member;
    }

    async findById(id: number) {
        const [member] = await this.db
            .select()
            .from(Member)
            .where(eq(Member.id, id));

        return member;
    }

    async findByEmail(email: string) {
        const [member] = await this.db
            .select()
            .from(Member)
            .where(eq(Member.email, email));

        return member;
    }
}
