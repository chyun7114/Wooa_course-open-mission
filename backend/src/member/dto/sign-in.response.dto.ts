import { ApiProperty } from '@nestjs/swagger';

export class SignInResponseDto {
    @ApiProperty({ description: '사용자명', example: 'lumi' })
    username: string;

    @ApiProperty({ description: '이메일', example: 'lui@flutter.com' })
    email: string;

    @ApiProperty({
        description: 'JWT 액세스 토큰',
        example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    })
    accessToken: string;
}
