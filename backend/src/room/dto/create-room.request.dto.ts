import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsNumber, Min, Max } from 'class-validator';

export class CreateRoomRequestDto {
    @ApiProperty({
        description: '방 제목',
        example: '초보만 오세요!',
    })
    @IsNotEmpty()
    @IsString()
    title: string;

    @ApiProperty({
        description: '최대 인원',
        example: 4,
        minimum: 2,
        maximum: 8,
    })
    @IsNotEmpty()
    @IsNumber()
    @Min(2)
    @Max(8)
    maxPlayers: number;

    @ApiProperty({
        description: '방 비밀번호 (선택사항)',
        example: '1234',
        required: false,
    })
    @IsString()
    password?: string;
}
