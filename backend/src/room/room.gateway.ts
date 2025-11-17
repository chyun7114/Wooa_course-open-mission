import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    MessageBody,
    ConnectedSocket,
} from '@nestjs/websockets';
import { UseGuards, Logger, UseInterceptors } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { RoomService } from './room.service';
import { GameService } from '../game/game.service';
import { WsJwtGuard } from '../common/guards/ws-jwt.guard';
import { WsUser } from '../common/decorators/ws-user.decorator';
import { AuthUser } from '../common/decorators/get-user.decorator';
import { WsLoggingInterceptor } from '../common/interceptors';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
    namespace: '/game',
})
@UseGuards(WsJwtGuard)
@UseInterceptors(WsLoggingInterceptor)
export class RoomGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(RoomGateway.name);

    constructor(
        private readonly roomService: RoomService,
        private readonly gameService: GameService,
    ) {}

    handleConnection(client: Socket) {
        this.logger.log(`Client connected: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected: ${client.id}`);

        const user = client.data?.user as AuthUser;
        if (!user) {
            return;
        }

        const room = this.roomService.findRoomBySocketId(client.id);
        if (room) {
            const player = room.getPlayerBySocketId(client.id);
            if (player) {
                const result = this.roomService.leaveRoom(room.id, player.id);

                if (result.roomDeleted) {
                    // 방이 삭제되었으면 게임 상태도 정리
                    this.gameService.deleteGame(room.id);
                    this.logger.log(
                        `Game state cleaned for deleted room ${room.id}`,
                    );
                } else {
                    this.server.to(room.id).emit('playerLeft', {
                        playerId: player.id,
                        nickname: player.nickname,
                        newHostId: result.newHostId,
                        room: room.toDetailResponse(),
                    });
                }

                this.server.emit('roomListUpdated', {
                    rooms: this.roomService
                        .findAllRooms()
                        .map((r) => r.toResponse()),
                });
            }
        }
    }

    @SubscribeMessage('createRoom')
    handleCreateRoom(
        @WsUser() user: AuthUser,
        @ConnectedSocket() client: Socket,
        @MessageBody()
        data: { title: string; maxPlayers: number; password?: string },
    ) {
        this.logger.log(
            `Creating room: ${data.title} by ${user.nickname} (${user.userId})`,
        );

        const room = this.roomService.createRoom(
            data.title,
            data.maxPlayers,
            user.userId,
            user.nickname,
            client.id,
            data.password,
        );

        client.join(room.id);

        this.server.emit('roomListUpdated', {
            rooms: this.roomService.findAllRooms().map((r) => r.toResponse()),
        });

        return {
            success: true,
            room: room.toDetailResponse(),
        };
    }

    @SubscribeMessage('joinRoom')
    handleJoinRoom(
        @WsUser() user: AuthUser,
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { roomId: string; password?: string },
    ) {
        this.logger.log(
            `Joining room: ${data.roomId} by ${user.nickname} (${user.userId})`,
        );

        const result = this.roomService.joinRoom(
            data.roomId,
            user.userId,
            user.nickname,
            client.id,
            data.password,
        );

        if (!result.success || !result.room) {
            return { success: false, message: result.message };
        }

        client.join(data.roomId);

        client.to(data.roomId).emit('playerJoined', {
            player: {
                id: user.userId,
                nickname: user.nickname,
                isHost: false,
                isReady: false,
            },
            room: result.room.toDetailResponse(),
        });

        this.server.emit('roomListUpdated', {
            rooms: this.roomService.findAllRooms().map((r) => r.toResponse()),
        });

        return {
            success: true,
            room: result.room.toDetailResponse(),
        };
    }

    @SubscribeMessage('leaveRoom')
    handleLeaveRoom(
        @WsUser() user: AuthUser,
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { roomId: string },
    ) {
        this.logger.log(
            `Leaving room: ${data.roomId} by ${user.nickname} (${user.userId})`,
        );

        const result = this.roomService.leaveRoom(data.roomId, user.userId);

        if (result.success) {
            client.leave(data.roomId);

            // 방이 삭제되었으면 게임 상태도 정리
            if (result.roomDeleted) {
                this.gameService.deleteGame(data.roomId);
                this.logger.log(
                    `Game state cleaned for deleted room ${data.roomId}`,
                );
            } else {
                const room = this.roomService.findRoom(data.roomId);
                if (room) {
                    this.server.to(data.roomId).emit('playerLeft', {
                        playerId: user.userId,
                        nickname: user.nickname,
                        newHostId: result.newHostId,
                        room: room.toDetailResponse(),
                    });
                }
            }

            this.server.emit('roomListUpdated', {
                rooms: this.roomService
                    .findAllRooms()
                    .map((r) => r.toResponse()),
            });
        }

        return { success: result.success };
    }

    @SubscribeMessage('toggleReady')
    handleToggleReady(
        @WsUser() user: AuthUser,
        @MessageBody() data: { roomId: string },
    ) {
        this.logger.log(
            `Toggling ready: ${data.roomId} by ${user.nickname} (${user.userId})`,
        );

        const success = this.roomService.toggleReady(data.roomId, user.userId);

        if (success) {
            const room = this.roomService.findRoom(data.roomId);
            if (room) {
                this.server.to(data.roomId).emit('readyStateChanged', {
                    playerId: user.userId,
                    room: room.toDetailResponse(),
                });
            }
        }

        return { success };
    }

    @SubscribeMessage('startGame')
    handleStartGame(
        @WsUser() user: AuthUser,
        @MessageBody() data: { roomId: string },
    ) {
        this.logger.log(
            `Starting game: ${data.roomId} by ${user.nickname} (${user.userId})`,
        );

        const result = this.roomService.startGame(data.roomId, user.userId);

        if (result.success) {
            const room = this.roomService.findRoom(data.roomId);
            if (room) {
                // GameService로 게임 상태 생성
                const players = Array.from(room.players.values()).map((p) => ({
                    id: p.id,
                    nickname: p.nickname,
                }));
                this.gameService.startGame(data.roomId, players);

                this.server.to(data.roomId).emit('gameStarted', {
                    room: room.toDetailResponse(),
                });

                this.server.emit('roomListUpdated', {
                    rooms: this.roomService
                        .findAllRooms()
                        .map((r) => r.toResponse()),
                });
            }
        }

        return result;
    }

    @SubscribeMessage('sendChatMessage')
    handleChatMessage(
        @WsUser() user: AuthUser,
        @MessageBody() data: { roomId: string; message: string },
    ) {
        this.logger.log(
            `Chat message in ${data.roomId} from ${user.nickname}: ${data.message}`,
        );

        this.server.to(data.roomId).emit('chatMessage', {
            playerId: user.userId,
            nickname: user.nickname,
            message: data.message,
            timestamp: new Date(),
        });

        return { success: true };
    }

    @SubscribeMessage('getRoomList')
    handleGetRoomList() {
        return {
            success: true,
            rooms: this.roomService.findAllRooms().map((r) => r.toResponse()),
        };
    }

    @SubscribeMessage('getRoomDetail')
    handleGetRoomDetail(@MessageBody() data: { roomId: string }) {
        const room = this.roomService.findRoom(data.roomId);

        if (!room) {
            return { success: false, message: '존재하지 않는 방입니다.' };
        }

        return {
            success: true,
            room: room.toDetailResponse(),
        };
    }
}
