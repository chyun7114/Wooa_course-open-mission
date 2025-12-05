import { Test, TestingModule } from '@nestjs/testing';
import { RoomService } from './room.service';
import { Logger } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import {
    AlreadyInGameException,
    InvalidPasswordException,
    RoomIsFullException,
    RoomNotFoundException,
} from './exceptions/room.exception';

jest.mock('uuid');

interface Player {
    playerId: string;
    nickname: string;
    socketId: string;
}

describe('RoomService', () => {
    let roomService: RoomService;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [RoomService, Logger],
        }).compile();

        roomService = module.get<RoomService>(RoomService);

        (uuidv4 as jest.Mock).mockReturnValue('test-room-id');

        jest.spyOn(Logger.prototype, 'log').mockImplementation(() => {});
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should be defined', () => {
        expect(roomService).toBeDefined();
    });

    describe('createRoom', () => {
        it('새로운 방을 생성하고 반환해야한다.', () => {
            // given
            const hostInfo = {
                hostId: 'host-user-id',
                hostNickname: 'host',
                hostSocketId: 'host-socket-id',
            };

            // when
            const room = roomService.createRoom(
                'Test Room',
                4,
                hostInfo.hostId,
                hostInfo.hostNickname,
                hostInfo.hostSocketId,
                'password123',
            );

            // then
            expect(room).toBeDefined();
            expect(room.id).toBe('test-room-id');
            expect(room.hostId).toBe('host-user-id');
            expect(room.title).toBe('Test Room');
        });
    });

    describe('joinRoom', () => {
        let roomId: string;
        let player: Player;

        beforeEach(() => {
            const room = roomService.createRoom(
                '참가용 방',
                2,
                'host-id',
                'host-nickname',
                'host-socket-id',
            );

            player = {
                playerId: 'player-2-id',
                nickname: '참가자',
                socketId: 'player-2-socket',
            };

            roomId = room.id;
        });

        it('플레이어가 성공적으로 방에 참여할 수 있다.', () => {
            // when
            const result = roomService.joinRoom(
                roomId,
                player.playerId,
                player.nickname,
                player.socketId,
            );

            // then
            expect(result).toBeDefined();
            expect(result.id).toBe(roomId);
        });

        it('존재하지 않는 방에는 들어갈 수 없다', () => {
            // given
            const wrongRoomId = 'wrong-room-id';

            // when & then
            expect(() =>
                roomService.joinRoom(
                    wrongRoomId,
                    player.playerId,
                    player.nickname,
                    player.socketId,
                ),
            ).toThrowError(RoomNotFoundException);
        });

        it('이미 게임이 진행 중인 방에는 들어갈 수 없다.', () => {
            // given
            const playingRoom = roomService.findRoom(roomId);
            if (playingRoom) {
                playingRoom.isPlaying = true;
            }

            // when & then
            expect(() =>
                roomService.joinRoom(
                    roomId,
                    player.playerId,
                    player.nickname,
                    player.socketId,
                ),
            ).toThrowError(AlreadyInGameException);
        });

        it('방이 가득 차면 입장에 실패해야 한다.', () => {
            // given
            // beforeEach에서 생성된 방은 maxPlayers가 2이고, 호스트가 이미 들어가 있음
            roomService.joinRoom(
                roomId,
                'player-2-id',
                'player-2-nickname',
                'player-2-socket',
            ); // 방을 가득 채움

            // when & then
            expect(() =>
                roomService.joinRoom(
                    roomId,
                    'extra-player-id',
                    'extra-player',
                    'extra-socket',
                ),
            ).toThrowError(RoomIsFullException);
        });

        it('비밀번호가 틀리면 비공개 방 참가에 실패해야 합니다.', () => {
            // given
            const privateRoom = roomService.createRoom(
                '비밀방',
                2,
                'host-id',
                '호스트',
                'host-socket',
                '1234',
            );

            // when & then
            expect(() =>
                roomService.joinRoom(
                    privateRoom.id,
                    'p-id',
                    'p-nick',
                    'p-socket',
                    'wrong-password',
                ),
            ).toThrowError(InvalidPasswordException);
        });
    });
});
