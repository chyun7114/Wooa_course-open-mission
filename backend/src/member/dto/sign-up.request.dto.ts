import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SignUpRequestDto {
    @ApiProperty({ description: '사용자명', example: 'lumi' })
    @IsString()
    @IsNotEmpty()
    username: string;

    @ApiProperty({ description: '이메일', example: 'lumi@flutter.com' })
    @IsEmail()
    @IsNotEmpty()
    email: string;

    @ApiProperty({ description: '비밀번호', example: 'password123' })
    @IsString()
    @MinLength(6)
    @IsNotEmpty()
    password: string;
}
