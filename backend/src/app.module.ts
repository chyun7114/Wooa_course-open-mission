import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DrizzleModule } from './common/db/drizzle.module';
import { MemberModule } from './member/member.module';
import { RoomModule } from './room/room.module';
import { GameModule } from './game/game.module';
import { LoggingInterceptor } from './common/interceptors';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),
        DrizzleModule,
        MemberModule,
        RoomModule,
        GameModule,
    ],
    controllers: [AppController],
    providers: [
        AppService,
        {
            provide: APP_INTERCEPTOR,
            useClass: LoggingInterceptor,
        },
    ],
})
export class AppModule {}
