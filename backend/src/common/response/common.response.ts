import { ApiProperty } from '@nestjs/swagger';

export class CommonResponse<T> {
    @ApiProperty({ example: 200 })
    code: number;
    @ApiProperty({ type: () => Object, required: false })
    data?: T;
    @ApiProperty({ required: false })
    message?: string;

    constructor(code: number, data?: T, message?: string) {
        this.code = code;
        if (data !== undefined) {
            this.data = data;
        }
        if (message !== undefined) {
            this.message = message;
        }
    }

    static success<T>(data?: T, message?: string): CommonResponse<T> {
        return new CommonResponse(200, data, message);
    }

    static fail(code: number, message: string): CommonResponse<any> {
        return new CommonResponse(code, undefined, message);
    }
}
