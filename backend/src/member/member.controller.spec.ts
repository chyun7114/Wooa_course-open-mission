import { Test, TestingModule } from '@nestjs/testing';
import { MemberController } from './member.controller';
import { MemberService } from './member.service';
import { SignUpRequestDto } from './dto/sign-up.request.dto';
import { SignInRequestDto } from './dto/sign-in.request.dto';
import { NotFoundException } from '@nestjs/common';

describe('MemberController', () => {
    let controller: MemberController;

    const mockMemberService = {
        createMember: jest.fn(),
        loginMember: jest.fn(),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            controllers: [MemberController],
            providers: [
                {
                    provide: MemberService,
                    useValue: mockMemberService,
                },
            ],
        }).compile();

        controller = module.get<MemberController>(MemberController);

        // 모든 모킹 함수 초기화
        jest.clearAllMocks();
    });

    it('should be defined', () => {
        expect(controller).toBeDefined();
    });

    describe('signUp', () => {
        it('회원가입에 성공해야 한다', async () => {
            // Given
            const signUpDto: SignUpRequestDto = {
                username: 'testuser',
                email: 'test@example.com',
                password: 'password123',
            };

            const expectedResult = {
                id: 1,
                username: 'testuser',
                email: 'test@example.com',
                createdAt: new Date(),
                updatedAt: new Date(),
                deleted: false,
            };

            mockMemberService.createMember.mockResolvedValue(expectedResult);

            // When
            const result = await controller.signUp(signUpDto);

            // Then
            expect(mockMemberService.createMember).toHaveBeenCalledWith(
                signUpDto,
            );
            expect(mockMemberService.createMember).toHaveBeenCalledTimes(1);
            expect(result).toEqual(expectedResult);
        });

        it('회원가입 시 서비스 에러가 발생하면 에러를 던져야 한다', async () => {
            // Given
            const signUpDto: SignUpRequestDto = {
                username: 'testuser',
                email: 'test@example.com',
                password: 'password123',
            };

            mockMemberService.createMember.mockRejectedValue(
                new Error('Database error'),
            );

            // When & Then
            await expect(controller.signUp(signUpDto)).rejects.toThrow(
                'Database error',
            );
        });
    });

    describe('signIn', () => {
        it('로그인에 성공해야 한다', async () => {
            // Given
            const signInDto: SignInRequestDto = {
                email: 'test@example.com',
                password: 'password123',
            };

            const expectedResult = {
                id: 1,
                username: 'testuser',
                email: 'test@example.com',
                createdAt: new Date(),
                updatedAt: new Date(),
                deleted: false,
            };

            mockMemberService.loginMember.mockResolvedValue(expectedResult);

            // When
            const result = await controller.signIn(signInDto);

            // Then
            expect(mockMemberService.loginMember).toHaveBeenCalledWith(
                signInDto,
            );
            expect(mockMemberService.loginMember).toHaveBeenCalledTimes(1);
            expect(result).toEqual(expectedResult);
        });

        it('존재하지 않는 이메일로 로그인 시 NotFoundException을 던져야 한다', async () => {
            // Given
            const signInDto: SignInRequestDto = {
                email: 'nonexistent@example.com',
                password: 'password123',
            };

            mockMemberService.loginMember.mockRejectedValue(
                new NotFoundException('올바른 이메일을 입력해 주세요'),
            );

            // When & Then
            await expect(controller.signIn(signInDto)).rejects.toThrow(
                NotFoundException,
            );
            await expect(controller.signIn(signInDto)).rejects.toThrow(
                '올바른 이메일을 입력해 주세요',
            );
        });

        it('잘못된 비밀번호로 로그인 시 NotFoundException을 던져야 한다', async () => {
            // Given
            const signInDto: SignInRequestDto = {
                email: 'test@example.com',
                password: 'wrongpassword',
            };

            mockMemberService.loginMember.mockRejectedValue(
                new NotFoundException('올바른 비밀번호를 입력해 주세요'),
            );

            // When & Then
            await expect(controller.signIn(signInDto)).rejects.toThrow(
                NotFoundException,
            );
            await expect(controller.signIn(signInDto)).rejects.toThrow(
                '올바른 비밀번호를 입력해 주세요',
            );
        });
    });
});
