import { Test, TestingModule } from '@nestjs/testing';
import { MemberService } from './member.service';
import { MemberRepository } from './member.repository';
import { NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

// bcrypt 모킹
jest.mock('bcrypt');

describe('MemberService', () => {
    let service: MemberService;

    const mockMemberRepository = {
        createMember: jest.fn(),
        findByEmail: jest.fn(),
        findById: jest.fn(),
    };

    const mockJwtService = {
        sign: jest.fn(),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                MemberService,
                {
                    provide: MemberRepository,
                    useValue: mockMemberRepository,
                },
                {
                    provide: JwtService,
                    useValue: mockJwtService,
                },
            ],
        }).compile();

        service = module.get<MemberService>(MemberService);

        // 모든 모킹 함수 초기화
        jest.clearAllMocks();
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    describe('createMember', () => {
        it('회원가입에 성공해야 한다', async () => {
            // Given
            const signUpDto = {
                username: 'testuser',
                email: 'test@example.com',
                password: 'password123',
            };

            const hashedPassword = 'hashedPassword123';
            const createdMember = {
                id: 1,
                username: 'testuser',
                email: 'test@example.com',
                password: hashedPassword,
                createdAt: new Date(),
                updatedAt: new Date(),
                deleted: false,
            };

            (bcrypt.hash as jest.Mock).mockResolvedValue(hashedPassword);
            mockMemberRepository.createMember.mockResolvedValue(createdMember);

            // When
            const result = await service.createMember(signUpDto);

            // Then
            expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
            expect(mockMemberRepository.createMember).toHaveBeenCalledWith({
                username: 'testuser',
                email: 'test@example.com',
                password: hashedPassword,
            });
            expect(result).toEqual({
                id: 1,
                username: 'testuser',
                email: 'test@example.com',
                createdAt: createdMember.createdAt,
                updatedAt: createdMember.updatedAt,
                deleted: false,
            });
            expect(result).not.toHaveProperty('password');
        });
    });

    describe('loginMember', () => {
        it('로그인에 성공해야 한다', async () => {
            // Given
            const signInDto = {
                email: 'test@example.com',
                password: 'password123',
            };

            const member = {
                id: 1,
                username: 'testuser',
                email: 'test@example.com',
                password: 'hashedPassword123',
                createdAt: new Date(),
                updatedAt: new Date(),
                deleted: false,
            };

            const mockToken = 'mock.jwt.token';

            mockMemberRepository.findByEmail.mockResolvedValue(member);
            (bcrypt.compare as jest.Mock).mockResolvedValue(true);
            mockJwtService.sign.mockReturnValue(mockToken);

            // When
            const result = await service.loginMember(signInDto);

            // Then
            expect(mockMemberRepository.findByEmail).toHaveBeenCalledWith(
                'test@example.com',
            );
            expect(bcrypt.compare).toHaveBeenCalledWith(
                'password123',
                'hashedPassword123',
            );
            expect(mockJwtService.sign).toHaveBeenCalledWith({
                sub: 1,
                email: 'test@example.com',
                username: 'testuser',
            });
            expect(result).toEqual({
                username: 'testuser',
                email: 'test@example.com',
                accessToken: mockToken,
            });
            expect(result).not.toHaveProperty('password');
        });

        it('존재하지 않는 이메일로 로그인 시 NotFoundException을 던져야 한다', async () => {
            // Given
            const signInDto = {
                email: 'nonexistent@example.com',
                password: 'password123',
            };

            mockMemberRepository.findByEmail.mockResolvedValue(null);

            // When & Then
            await expect(service.loginMember(signInDto)).rejects.toThrow(
                NotFoundException,
            );
            await expect(service.loginMember(signInDto)).rejects.toThrow(
                '올바른 이메일을 입력해 주세요',
            );
        });

        it('잘못된 비밀번호로 로그인 시 NotFoundException을 던져야 한다', async () => {
            // Given
            const signInDto = {
                email: 'test@example.com',
                password: 'wrongpassword',
            };

            const member = {
                id: 1,
                username: 'testuser',
                email: 'test@example.com',
                password: 'hashedPassword123',
                createdAt: new Date(),
                updatedAt: new Date(),
                deleted: false,
            };

            mockMemberRepository.findByEmail.mockResolvedValue(member);
            (bcrypt.compare as jest.Mock).mockResolvedValue(false);

            // When & Then
            await expect(service.loginMember(signInDto)).rejects.toThrow(
                NotFoundException,
            );
            await expect(service.loginMember(signInDto)).rejects.toThrow(
                '올바른 비밀번호를 입력해 주세요',
            );
        });
    });
});
