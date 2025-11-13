import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    MessageBody,
    ConnectedSocket,
} from '@nestjs/websockets';
import { UseGuards, Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { RoomService } from './room.service';
import { WsJwtGuard } from '../common/guards/ws-jwt.guard';
import { WsUser } from '../common/decorators/ws-user.decorator';
import { AuthUser } from '../common/decorators/get-user.decorator';

@WebSocketGateway({
    cors: {
        origin: '*', // 프로덕션에서는 특정 도메인으로 제한해야 함
    },
    namespace: '/game',
})
@UseGuards(WsJwtGuard)
export class RoomGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(RoomGateway.name);

    constructor(private readonly roomService: RoomService) {}

    handleConnection(client: Socket) {
        this.logger.log(`Client connected: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected: ${client.id}`);

        // JWT에서 추출한 userId 사용
        const user = client.data?.user as AuthUser;
        if (!user) {
            return;
        }

        // 연결이 끊긴 클라이언트가 속한 방에서 제거
        const room = this.roomService.findRoomBySocketId(client.id);
        if (room) {
            const player = room.getPlayerBySocketId(client.id);
            if (player) {
                const result = this.roomService.leaveRoom(room.id, player.id);

                if (!result.roomDeleted) {
                    // 방이 삭제되지 않았으면 다른 플레이어들에게 알림
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

        // 방 생성자를 해당 방 소켓 룸에 추가
        client.join(room.id);

        // 모든 클라이언트에게 방 목록 업데이트 알림
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

        // 플레이어를 해당 방 소켓 룸에 추가
        client.join(data.roomId);

        // 해당 방의 다른 플레이어들에게 새 플레이어 입장 알림
        client.to(data.roomId).emit('playerJoined', {
            player: {
                id: user.userId,
                nickname: user.nickname,
                isHost: false,
                isReady: false,
            },
            room: result.room.toDetailResponse(),
        });

        // 모든 클라이언트에게 방 목록 업데이트 알림
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

            if (!result.roomDeleted) {
                // 방이 삭제되지 않았으면 다른 플레이어들에게 알림
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

            // 모든 클라이언트에게 방 목록 업데이트 알림
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
                // 방의 모든 플레이어에게 준비 상태 변경 알림
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
                // 방의 모든 플레이어에게 게임 시작 알림
                this.server.to(data.roomId).emit('gameStarted', {
                    room: room.toDetailResponse(),
                });

                // 모든 클라이언트에게 방 목록 업데이트 알림 (게임 중인 방은 목록에서 제거됨)
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

        // 방의 모든 플레이어에게 채팅 메시지 전송
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
