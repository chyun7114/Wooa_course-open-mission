import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional } from 'class-validator';

export class JoinRoomRequestDto {
    @ApiProperty({
        description: '방 비밀번호 (비공개 방인 경우)',
        example: '1234',
        required: false,
    })
    @IsOptional()
    @IsString()
    password?: string;
}
