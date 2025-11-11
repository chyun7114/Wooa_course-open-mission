import { Module } from '@nestjs/common';
import { MemberService } from './member.service';
import { MemberController } from './member.controller';
import { MemberRepository } from './member.repository';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
    imports: [
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: (configService: ConfigService) => {
                return {
                    secret:
                        configService.get<string>('JWT_SECRET') ||
                        'default-secret',
                    signOptions: {
                        expiresIn: '1d',
                    },
                };
            },
            inject: [ConfigService],
        }),
    ],
    providers: [MemberService, MemberRepository],
    controllers: [MemberController],
})
export class MemberModule {}
