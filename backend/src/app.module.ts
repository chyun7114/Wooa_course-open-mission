import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DrizzleModule } from './common/db/drizzle.module';
import { MemberModule } from './member/member.module';
import { RoomModule } from './room/room.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),
        DrizzleModule,
        MemberModule,
        RoomModule,
    ],
    controllers: [AppController],
    providers: [AppService],
})
export class AppModule {}
