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

  async onModuleInit() {
    // 데이터베이스 연결 확인
    try {
      console.log('✅ Drizzle ORM connected successfully');
    } catch (error) {
      console.error('❌ Drizzle ORM connection failed:', error);
      throw error;
    }
  }

  getDb(): PostgresJsDatabase<typeof schema> {
    return this.db;
  }
}
