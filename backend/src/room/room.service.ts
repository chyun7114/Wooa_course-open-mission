import { Injectable, Logger } from '@nestjs/common';
import { Room } from './entity';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class RoomService {
    private readonly logger = new Logger(RoomService.name);
    private rooms: Map<string, Room> = new Map();

    createRoom(
        title: string,
        maxPlayers: number,
        hostId: string,
        hostNickname: string,
        hostSocketId: string,
        password?: string,
    ): Room {
        const roomId = uuidv4();
        const room = new Room(
            roomId,
            title,
            maxPlayers,
            hostId,
            hostNickname,
            hostSocketId,
            password,
        );

        this.rooms.set(roomId, room);
        this.logger.log(
            `Room created: ${roomId} by ${hostNickname} (${maxPlayers} players max)`,
        );

        return room;
    }

    findRoom(roomId: string): Room | undefined {
        return this.rooms.get(roomId);
    }

    findAllRooms(): Room[] {
        return Array.from(this.rooms.values())
            .filter((room) => !room.isPlaying) // 게임 중이 아닌 방만 조회
            .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
    }

    joinRoom(
        roomId: string,
        playerId: string,
        nickname: string,
        socketId: string,
        password?: string,
    ): { success: boolean; message?: string; room?: Room } {
        const room = this.rooms.get(roomId);

        if (!room) {
            return { success: false, message: '존재하지 않는 방입니다.' };
        }

        if (room.isPlaying) {
            return { success: false, message: '이미 게임이 진행 중입니다.' };
        }

        if (room.isFull()) {
            return { success: false, message: '방이 가득 찼습니다.' };
        }

        if (room.isPrivate && room.password !== password) {
            return { success: false, message: '비밀번호가 일치하지 않습니다.' };
        }

        const added = room.addPlayer(playerId, nickname, socketId);
        if (!added) {
            return { success: false, message: '방 입장에 실패했습니다.' };
        }

        this.logger.log(`Player ${nickname} joined room ${roomId}`);
        return { success: true, room };
    }

    leaveRoom(
        roomId: string,
        playerId: string,
    ): {
        success: boolean;
        roomDeleted: boolean;
        newHostId?: string;
    } {
        const room = this.rooms.get(roomId);

        if (!room) {
            return { success: false, roomDeleted: false };
        }

        const wasHost = room.hostId === playerId;
        room.removePlayer(playerId);

        // 방이 비었으면 삭제
        if (room.isEmpty()) {
            this.rooms.delete(roomId);
            this.logger.log(`Room ${roomId} deleted (empty)`);
            return { success: true, roomDeleted: true };
        }

        // 방장이 바뀌었으면 새 방장 ID 반환
        if (wasHost && room.hostId !== playerId) {
            this.logger.log(`New host for room ${roomId}: ${room.hostId}`);
            return {
                success: true,
                roomDeleted: false,
                newHostId: room.hostId,
            };
        }

        return { success: true, roomDeleted: false };
    }

    toggleReady(roomId: string, playerId: string): boolean {
        const room = this.rooms.get(roomId);
        if (!room) {
            return false;
        }

        return room.toggleReady(playerId);
    }

    startGame(
        roomId: string,
        playerId: string,
    ): {
        success: boolean;
        message?: string;
    } {
        const room = this.rooms.get(roomId);

        if (!room) {
            return { success: false, message: '존재하지 않는 방입니다.' };
        }

        if (room.hostId !== playerId) {
            return {
                success: false,
                message: '방장만 게임을 시작할 수 있습니다.',
            };
        }

        if (!room.canStartGame()) {
            return {
                success: false,
                message: '모든 플레이어가 준비되지 않았습니다.',
            };
        }

        room.startGame();
        this.logger.log(`Game started in room ${roomId}`);
        return { success: true };
    }

    endGame(roomId: string): boolean {
        const room = this.rooms.get(roomId);
        if (!room) {
            return false;
        }

        room.endGame();
        this.logger.log(`Game ended in room ${roomId}`);
        return true;
    }

    findRoomBySocketId(socketId: string): Room | undefined {
        return Array.from(this.rooms.values()).find((room) =>
            room.getPlayerBySocketId(socketId),
        );
    }

    getRoomCount(): number {
        return this.rooms.size;
    }

    getActivePlayerCount(): number {
        return Array.from(this.rooms.values()).reduce(
            (total, room) => total + room.getCurrentPlayers(),
            0,
        );
    }
}
