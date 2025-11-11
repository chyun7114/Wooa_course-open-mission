import { Body, Controller, Post } from '@nestjs/common';
import { MemberService } from './member.service';
import { SignUpRequestDto } from './dto/sign-up.request.dto';
import { SignInRequestDto } from './dto/sign-in.request.dto';
import { SignInResponseDto } from './dto/sign-in.response.dto';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

@ApiTags('회원')
@Controller('member')
export class MemberController {
    constructor(private readonly memberService: MemberService) {}

    @Post('sign-up')
    @ApiOperation({ summary: '회원가입' })
    @ApiResponse({ status: 201, description: '회원가입 성공' })
    async signUp(@Body() signUpDto: SignUpRequestDto) {
        return await this.memberService.createMember(signUpDto);
    }

    @Post('sign-in')
    @ApiOperation({ summary: '로그인' })
    @ApiResponse({
        status: 200,
        description: '로그인 성공',
        type: SignInResponseDto,
    })
    async signIn(@Body() signInDto: SignInRequestDto) {
        return await this.memberService.loginMember(signInDto);
    }
}
