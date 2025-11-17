import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AuthUser {
    userId: string;
    nickname: string;
    email: string;
}

export const GetUser = createParamDecorator(
    (data: string | undefined, ctx: ExecutionContext) => {
        const request = ctx.switchToHttp().getRequest();
        const user = request.user;

        // data가 지정되면 해당 속성값만 반환
        return data ? user?.[data] : user;
    },
);
