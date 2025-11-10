import {
    CallHandler,
    ExecutionContext,
    Injectable,
    NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { CommonResponse } from '../response/common.response';

@Injectable()
export class ResponseInterceptor<T>
    implements NestInterceptor<T, CommonResponse<T>>
{
    intercept(
        context: ExecutionContext,
        next: CallHandler,
    ): Observable<CommonResponse<T>> {
        return next.handle().pipe(
            map((data) => {
                const response = context.switchToHttp().getResponse();
                const statusCode = response.statusCode;
                
                // 이미 CommonResponse 형태라면 그대로 반환
                if (data instanceof CommonResponse) {
                    return data;
                }
                
                // 아니라면 CommonResponse로 래핑
                return new CommonResponse(statusCode, data);
            }),
        );
    }
}
