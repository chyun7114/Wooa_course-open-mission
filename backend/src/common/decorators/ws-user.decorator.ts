import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthUser } from './get-user.decorator';

export const WsUser = createParamDecorator(
    (data: unknown, ctx: ExecutionContext): AuthUser => {
        const client = ctx.switchToWs().getClient();
        return client.data?.user;
    },
);
