import { Global, Module } from '@nestjs/common';
import { drizzleProvider } from './drizzle.provider';
import { DrizzleService } from './drizzle.service';

@Global()
@Module({
  providers: [drizzleProvider, DrizzleService],
  exports: [drizzleProvider, DrizzleService],
})
export class DrizzleModule {}
