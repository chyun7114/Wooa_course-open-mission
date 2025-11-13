import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { WsException } from '@nestjs/websockets';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class WsJwtGuard implements CanActivate {
    constructor(
        private jwtService: JwtService,
        private configService: ConfigService,
    ) {}

    async canActivate(context: ExecutionContext): Promise<boolean> {
        try {
            const client = context.switchToWs().getClient();
            const token = this.extractToken(client);

            if (!token) {
                throw new WsException('인증 토큰이 없습니다.');
            }

            const secret =
                this.configService.get<string>('JWT_SECRET') ||
                'default-secret';
            const payload = this.jwtService.verify(token, { secret });

            // 사용자 정보를 클라이언트 객체에 저장
            client.data = client.data || {};
            client.data.user = payload;

            return true;
        } catch (error) {
            throw new WsException('유효하지 않은 토큰입니다.');
        }
    }

    private extractToken(client: any): string | null {
        // 1. handshake auth에서 토큰 추출
        const authToken = client.handshake?.auth?.token;
        if (authToken) {
            return authToken;
        }

        // 2. query parameter에서 토큰 추출
        const queryToken = client.handshake?.query?.token;
        if (queryToken) {
            return queryToken;
        }

        // 3. Authorization 헤더에서 토큰 추출
        const authHeader = client.handshake?.headers?.authorization;
        if (authHeader && authHeader.startsWith('Bearer ')) {
            return authHeader.substring(7);
        }

        return null;
    }
}
