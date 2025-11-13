import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    MessageBody,
    ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { RoomService } from './room.service';

interface ClientData {
    userId: string;
    nickname: string;
}

@WebSocketGateway({
    cors: {
        origin: '*', // 프로덕션에서는 특정 도메인으로 제한해야 함
    },
    namespace: '/game',
})
export class RoomGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(RoomGateway.name);
    private clientData: Map<string, ClientData> = new Map();

    constructor(private readonly roomService: RoomService) {}

    handleConnection(client: Socket) {
        this.logger.log(`Client connected: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected: ${client.id}`);

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

        this.clientData.delete(client.id);
    }

    @SubscribeMessage('register')
    handleRegister(
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { userId: string; nickname: string },
    ) {
        this.clientData.set(client.id, {
            userId: data.userId,
            nickname: data.nickname,
        });
        this.logger.log(`Client registered: ${data.nickname} (${client.id})`);

        return { success: true };
    }

    @SubscribeMessage('createRoom')
    handleCreateRoom(
        @ConnectedSocket() client: Socket,
        @MessageBody()
        data: { title: string; maxPlayers: number; password?: string },
    ) {
        const clientInfo = this.clientData.get(client.id);
        if (!clientInfo) {
            return {
                success: false,
                message: '사용자 정보를 찾을 수 없습니다.',
            };
        }

        const room = this.roomService.createRoom(
            data.title,
            data.maxPlayers,
            clientInfo.userId,
            clientInfo.nickname,
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
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { roomId: string; password?: string },
    ) {
        const clientInfo = this.clientData.get(client.id);
        if (!clientInfo) {
            return {
                success: false,
                message: '사용자 정보를 찾을 수 없습니다.',
            };
        }

        const result = this.roomService.joinRoom(
            data.roomId,
            clientInfo.userId,
            clientInfo.nickname,
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
                id: clientInfo.userId,
                nickname: clientInfo.nickname,
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
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { roomId: string },
    ) {
        const clientInfo = this.clientData.get(client.id);
        if (!clientInfo) {
            return {
                success: false,
                message: '사용자 정보를 찾을 수 없습니다.',
            };
        }

        const result = this.roomService.leaveRoom(
            data.roomId,
            clientInfo.userId,
        );

        if (result.success) {
            client.leave(data.roomId);

            if (!result.roomDeleted) {
                // 방이 삭제되지 않았으면 다른 플레이어들에게 알림
                const room = this.roomService.findRoom(data.roomId);
                if (room) {
                    this.server.to(data.roomId).emit('playerLeft', {
                        playerId: clientInfo.userId,
                        nickname: clientInfo.nickname,
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
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { roomId: string },
    ) {
        const clientInfo = this.clientData.get(client.id);
        if (!clientInfo) {
            return {
                success: false,
                message: '사용자 정보를 찾을 수 없습니다.',
            };
        }

        const success = this.roomService.toggleReady(
            data.roomId,
            clientInfo.userId,
        );

        if (success) {
            const room = this.roomService.findRoom(data.roomId);
            if (room) {
                // 방의 모든 플레이어에게 준비 상태 변경 알림
                this.server.to(data.roomId).emit('readyStateChanged', {
                    playerId: clientInfo.userId,
                    room: room.toDetailResponse(),
                });
            }
        }

        return { success };
    }

    @SubscribeMessage('startGame')
    handleStartGame(
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { roomId: string },
    ) {
        const clientInfo = this.clientData.get(client.id);
        if (!clientInfo) {
            return {
                success: false,
                message: '사용자 정보를 찾을 수 없습니다.',
            };
        }

        const result = this.roomService.startGame(
            data.roomId,
            clientInfo.userId,
        );

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
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { roomId: string; message: string },
    ) {
        const clientInfo = this.clientData.get(client.id);
        if (!clientInfo) {
            return { success: false };
        }

        // 방의 모든 플레이어에게 채팅 메시지 전송
        this.server.to(data.roomId).emit('chatMessage', {
            playerId: clientInfo.userId,
            nickname: clientInfo.nickname,
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
