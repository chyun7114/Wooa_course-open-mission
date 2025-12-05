import { DomainException } from '../../common/exceptions';
import { RoomErrorCode } from '../constants/room.error-code';

export class RoomNotFoundException extends DomainException {
    constructor() {
        super(RoomErrorCode.ROOM_NOT_FOUND, 'ROOM_NOT_FOUND');
    }
}

export class AlreadyInGameException extends DomainException {
    constructor() {
        super(RoomErrorCode.ALREADY_IN_GAME, 'ALREADY_IN_GAME');
    }
}

export class RoomIsFullException extends DomainException {
    constructor() {
        super(RoomErrorCode.ROOM_IS_FULL, 'ROOM_IS_FULL');
    }
}

export class InvalidPasswordException extends DomainException {
    constructor() {
        super(RoomErrorCode.INVALID_PASSWORD, 'INVALID_PASSWORD');
    }
}

export class NotHostException extends DomainException {
    constructor() {
        super(RoomErrorCode.NOT_HOST, 'NOT_HOST');
    }
}

export class NotAllPlayersReadyException extends DomainException {
    constructor() {
        super(RoomErrorCode.NOT_ALL_PLAYERS_READY, 'NOT_ALL_PLAYERS_READY');
    }
}
