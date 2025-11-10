import { ApiProperty } from '@nestjs/swagger';

export class CommonResponse<T> {
    @ApiProperty({ example: 200 })
    code: number;
    @ApiProperty({ type: () => Object, required: false })
    data?: T;

    constructor(code: number, data?: T) {
        this.code = code;
        if (data !== undefined) {
            this.data = data;
        }
    }
}
