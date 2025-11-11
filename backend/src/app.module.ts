import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DrizzleModule } from './common/db/drizzle.module';
import { MemberModule } from './member/member.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),
        DrizzleModule,
        MemberModule,
    ],
    controllers: [AppController],
    providers: [AppService],
})
export class AppModule {}
