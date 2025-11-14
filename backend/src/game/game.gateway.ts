import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    MessageBody,
    ConnectedSocket,
} from '@nestjs/websockets';
import { UseGuards, Logger, UseInterceptors } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { GameService } from './game.service';
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
export class GameGateway {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(GameGateway.name);

    constructor(private readonly gameService: GameService) {}

    // 게임 상태 업데이트 (점수, 레벨, 줄 제거 수)
    @SubscribeMessage('updateGameState')
    handleUpdateGameState(
        @WsUser() user: AuthUser,
        @MessageBody()
        data: {
            roomId: string;
            score: number;
            level: number;
            linesCleared: number;
            board?: number[][];
        },
    ) {
        this.logger.log(
            `📥 updateGameState from ${user.nickname}: board=${data.board ? `${data.board.length}x${data.board[0]?.length}` : 'null'}`,
        );

        const success = this.gameService.updatePlayerState(
            data.roomId,
            user.userId,
            data.score,
            data.level,
            data.linesCleared,
            data.board,
        );

        if (success) {
            // 방의 모든 플레이어에게 상태 업데이트 브로드캐스트
            this.server.to(data.roomId).emit('gameStateUpdated', {
                playerId: user.userId,
                nickname: user.nickname,
                score: data.score,
                level: data.level,
                linesCleared: data.linesCleared,
                board: data.board,
            });

            if (data.board) {
                this.logger.log(
                    `📤 Broadcasting board to room ${data.roomId}: ${data.board.length}x${data.board[0]?.length}`,
                );
            }
        }

        return { success };
    }

    // 공격 (줄 제거 시)
    @SubscribeMessage('attack')
    handleAttack(
        @WsUser() user: AuthUser,
        @MessageBody() data: { roomId: string; linesCleared: number },
    ) {
        const result = this.gameService.handleAttack(
            data.roomId,
            user.userId,
            data.linesCleared,
        );

        if (result) {
            // 공격 대상 플레이어들에게 공격 알림
            result.targetIds.forEach((targetId) => {
                const game = this.gameService.findGame(data.roomId);
                const target = game?.players.get(targetId);

                if (target) {
                    // 특정 플레이어의 소켓에만 전송
                    this.server.to(data.roomId).emit('attacked', {
                        targetId: targetId,
                        attackerId: user.userId,
                        attackerNickname: user.nickname,
                        attackLines: result.attackLines,
                    });
                }
            });

            this.logger.log(
                `Attack from ${user.nickname}: ${result.attackLines} lines to ${result.targetIds.length} players`,
            );
        }

        return { success: true };
    }

    // 게임 오버
    @SubscribeMessage('gameOver')
    handleGameOver(
        @WsUser() user: AuthUser,
        @MessageBody() data: { roomId: string },
    ) {
        const result = this.gameService.handleGameOver(
            data.roomId,
            user.userId,
        );

        // 모든 플레이어에게 게임 오버 알림
        this.server.to(data.roomId).emit('playerGameOver', {
            playerId: user.userId,
            nickname: user.nickname,
            rank: result.rank,
        });

        // 게임 종료 여부 확인
        if (result.shouldEndGame && result.finalRanking) {
            this.server.to(data.roomId).emit('gameEnded', {
                finalRanking: result.finalRanking,
            });

            this.logger.log(`Game ended for room ${data.roomId}`);
        }

        return {
            success: true,
            rank: result.rank,
            gameEnded: result.shouldEndGame,
        };
    }

    // 게임 포기
    @SubscribeMessage('forfeit')
    handleForfeit(
        @WsUser() user: AuthUser,
        @MessageBody() data: { roomId: string },
    ) {
        // 게임 오버와 동일하게 처리
        return this.handleGameOver(user, data);
    }
}
