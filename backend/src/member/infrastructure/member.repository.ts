import { Inject, Injectable } from '@nestjs/common';
import { drizzle } from 'drizzle-orm/postgres-js';
import { DATABASE_CONNECTION } from 'src/common/db/constants';
import { Member } from '../entity';
import { eq } from 'drizzle-orm';

@Injectable()
export class MemberRepository {
    constructor(
        @Inject(DATABASE_CONNECTION)
        private readonly db: ReturnType<typeof drizzle>,
    ) {}

    async create(username: string, email: string, password: string) {
        const [member] = await this.db
            .insert(Member)
            .values({
                username,
                email,
                password,
            })
            .returning();
        return member;
    }

    async findById(id: number) {
        const [member] = await this.db
            .select()
            .from(Member)
            .where(eq(Member.id, id))
            .limit(1);

        return member;
    }

    async findByEmail(email: string) {
        const [member] = await this.db
            .select()
            .from(Member)
            .where(eq(Member.email, email))
            .limit(1);
        return member;
    }
}
