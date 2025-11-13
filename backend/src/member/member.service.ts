import { Injectable, NotFoundException } from '@nestjs/common';
import { MemberRepository } from './member.repository';
import * as bcrypt from 'bcrypt';
import { SignUpRequestDto } from './dto/sign-up.request.dto';
import { SignInRequestDto } from './dto/sign-in.request.dto';
import { JwtService } from '@nestjs/jwt';
import { SignInResponseDto } from './dto/sign-in.response.dto';

@Injectable()
export class MemberService {
    constructor(
        private readonly memberRepository: MemberRepository,
        private readonly jwtService: JwtService,
    ) {}

    async createMember(data: SignUpRequestDto) {
        const hashedPassword = await bcrypt.hash(data.password, 10);

        const member = await this.memberRepository.createMember({
            username: data.username,
            email: data.email,
            password: hashedPassword,
        });

        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        const { password: _, ...memberWithoutPassword } = member;
        return memberWithoutPassword;
    }

    async loginMember(data: SignInRequestDto): Promise<SignInResponseDto> {
        const member = await this.memberRepository.findByEmail(data.email);

        if (!member) {
            throw new NotFoundException('올바른 이메일을 입력해 주세요');
        }

        const isPasswordValid = await this.validatePassword(
            data.password,
            member.password,
        );

        if (!isPasswordValid) {
            throw new NotFoundException('올바른 비밀번호를 입력해 주세요');
        }

        const payload = {
            sub: member.id,
            email: member.email,
            username: member.username,
        };
        const accessToken = this.jwtService.sign(payload);

        return {
            userId: member.id,
            username: member.username,
            email: member.email,
            accessToken,
        };
    }

    private async validatePassword(
        plainPassword: string,
        hashedPassword: string,
    ) {
        return await bcrypt.compare(plainPassword, hashedPassword);
    }

    private async findById(id: number) {
        return await this.memberRepository.findById(id);
    }

    private async findByEmail(email: string) {
        return await this.memberRepository.findByEmail(email);
    }
}
