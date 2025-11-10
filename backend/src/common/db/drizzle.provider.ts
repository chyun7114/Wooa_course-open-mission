import { drizzle } from 'drizzle-orm/postgres-js';
import { ConfigService } from '@nestjs/config';
import * as schema from './schema';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const postgres = require('postgres');

export const DRIZZLE_ORM = Symbol('DRIZZLE_ORM');

export const drizzleProvider = {
  provide: DRIZZLE_ORM,
  inject: [ConfigService],
  useFactory: async (configService: ConfigService) => {
    const databaseUrl = configService.get<string>('DATABASE_URL');
    
    if (!databaseUrl) {
      throw new Error('DATABASE_URL이 잘못됐습니다.');
    }

    const client = postgres(databaseUrl, { 
      max: 10,
      idle_timeout: 20,
      connect_timeout: 10,
    });
    
    return drizzle(client, { schema });
  },
};
