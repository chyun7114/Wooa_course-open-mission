import {
    CallHandler,
    ExecutionContext,
    Injectable,
    Logger,
    NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';

@Injectable()
export class WsLoggingInterceptor implements NestInterceptor {
    private readonly logger = new Logger('WebSocket');

    intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
        const wsContext = context.switchToWs();
        const client = wsContext.getClient();
        const data = wsContext.getData();
        const pattern = context.getHandler().name;
        const now = Date.now();

        const user = client.data?.user;
        const userId = user?.userId || 'anonymous';
        const nickname = user?.nickname || 'unknown';

        this.logger.log(
            `📨 [${pattern}] Client: ${client.id} | User: ${nickname}(${userId}) | Data: ${JSON.stringify(data)}`,
        );

        return next.handle().pipe(
            tap((response) => {
                const delay = Date.now() - now;
                this.logger.log(
                    `[${pattern}] Client: ${client.id} | Response: ${JSON.stringify(response)} | ${delay}ms`,
                );
            }),
            catchError((error) => {
                const delay = Date.now() - now;
                this.logger.error(
                    `[${pattern}] Client: ${client.id} | Error: ${error.message} | ${delay}ms`,
                );
                throw error;
            }),
        );
    }
}
