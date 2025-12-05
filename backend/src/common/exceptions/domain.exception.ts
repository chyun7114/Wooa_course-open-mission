import { HttpException, HttpStatus } from '@nestjs/common';

interface ErrorCode {
    code: number;
    message: string;
}

export class DomainException extends HttpException {
    constructor(
        error: ErrorCode,
        public readonly errorCode?: string,
        public readonly path?: string,
    ) {
        super(
            {
                errorCode: errorCode ?? HttpStatus[error.code],
                message: error.message,
                path: path ?? null,
                timestamp: new Date().toISOString(),
            },
            error.code,
        );
        Error.captureStackTrace(this, new.target);
    }
}
