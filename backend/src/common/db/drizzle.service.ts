import { Injectable, Inject, OnModuleInit } from '@nestjs/common';
import { DRIZZLE_ORM } from './drizzle.provider';
import { PostgresJsDatabase } from 'drizzle-orm/postgres-js';
import * as schema from './schema';

@Injectable()
export class DrizzleService implements OnModuleInit {
    constructor(
        @Inject(DRIZZLE_ORM)
        private readonly db: PostgresJsDatabase<typeof schema>,
    ) {}

    onModuleInit() {
        try {
            console.log('✅ Drizzle ORM 연결 성공');
        } catch (error) {
            console.error('❌ Drizzle ORM 연결 실패:', error);
            throw error;
        }
    }

    getDb(): PostgresJsDatabase<typeof schema> {
        return this.db;
    }
}
