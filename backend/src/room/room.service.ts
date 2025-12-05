import { Injectable, Logger } from '@nestjs/common';
import { Room } from './entity';
import { v4 as uuidv4 } from 'uuid';
import {
    AlreadyInGameException,
    InvalidPasswordException,
    NotAllPlayersReadyException,
    NotHostException,
    RoomIsFullException,
    RoomNotFoundException,
} from './exceptions/room.exception';

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

    findRoom(roomId: string): Room {
        const room = this.rooms.get(roomId);
        if (!room) {
            throw new RoomNotFoundException();
        }
        return room;
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
    ): Room {
        const room = this.findRoom(roomId);

        if (room.isPlaying) {
            throw new AlreadyInGameException();
        }

        if (room.isFull()) {
            throw new RoomIsFullException();
        }

        if (room.isPrivate && room.password !== password) {
            throw new InvalidPasswordException();
        }

        room.addPlayer(playerId, nickname, socketId);
        this.logger.log(`Player ${nickname} joined room ${roomId}`);
        return room;
    }

    leaveRoom(
        roomId: string,
        playerId: string,
    ): {
        success: boolean;
        roomDeleted: boolean;
        newHostId?: string;
    } {
        const room = this.findRoom(roomId);

        const wasHost = room.hostId === playerId;
        room.removePlayer(playerId);

        if (room.isEmpty()) {
            this.rooms.delete(roomId);
            this.logger.log(`Room ${roomId} deleted (empty)`);
            return { success: true, roomDeleted: true };
        }

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
        const room = this.findRoom(roomId);
        return room.toggleReady(playerId);
    }

    startGame(roomId: string, playerId: string): void {
        const room = this.findRoom(roomId);

        if (room.hostId !== playerId) {
            throw new NotHostException();
        }

        if (!room.canStartGame()) {
            throw new NotAllPlayersReadyException();
        }

        room.startGame();
        this.logger.log(`Game started in room ${roomId}`);
    }

    endGame(roomId: string): boolean {
        const room = this.findRoom(roomId);
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

    deleteRoom(roomId: string): boolean {
        const existed = this.rooms.delete(roomId);
        if (existed) {
            this.logger.log(`Room ${roomId} deleted`);
        }
        return existed;
    }
}
