import { HttpStatus } from '@nestjs/common';

export const RoomErrorCode = {
    ROOM_NOT_FOUND: {
        code: HttpStatus.NOT_FOUND,
        message: '방을 찾을 수 없습니다.',
    },
    ALREADY_IN_GAME: {
        code: HttpStatus.CONFLICT,
        message: '이미 게임이 진행 중입니다.',
    },
    ROOM_IS_FULL: {
        code: HttpStatus.CONFLICT,
        message: '방이 가득 찼습니다.',
    },
    INVALID_PASSWORD: {
        code: HttpStatus.UNAUTHORIZED,
        message: '비밀번호가 일치하지 않습니다.',
    },
    NOT_HOST: {
        code: HttpStatus.FORBIDDEN,
        message: '방장만 이 작업을 수행할 수 있습니다.',
    },
    NOT_ALL_PLAYERS_READY: {
        code: HttpStatus.BAD_REQUEST,
        message: '모든 플레이어가 준비되지 않았습니다.',
    },
};