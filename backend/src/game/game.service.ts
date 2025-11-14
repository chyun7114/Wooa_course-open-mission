import { Injectable, Logger } from '@nestjs/common';
import { GameState } from './entity';

@Injectable()
export class GameService {
    private readonly logger = new Logger(GameService.name);
    private games: Map<string, GameState> = new Map();

    // 게임 시작
    startGame(
        roomId: string,
        players: { id: string; nickname: string }[],
    ): GameState {
        const game = new GameState(roomId, players);
        this.games.set(roomId, game);

        this.logger.log(
            `Game started for room ${roomId} with ${players.length} players`,
        );

        return game;
    }

    // 게임 찾기
    findGame(roomId: string): GameState | undefined {
        return this.games.get(roomId);
    }

    // 플레이어 상태 업데이트
    updatePlayerState(
        roomId: string,
        playerId: string,
        score: number,
        level: number,
        linesCleared: number,
        board?: number[][],
    ): boolean {
        const game = this.games.get(roomId);
        if (!game) {
            return false;
        }

        return game.updatePlayerState(playerId, score, level, linesCleared, board);
    }

    // 공격 처리 (줄 제거 시)
    handleAttack(
        roomId: string,
        attackerId: string,
        linesCleared: number,
    ): { targetIds: string[]; attackLines: number } | null {
        const game = this.games.get(roomId);
        if (!game) {
            return null;
        }

        // 공격 라인 계산 (1줄 제거 = 0라인, 2줄 = 1라인, 3줄 = 2라인, 4줄(테트리스) = 4라인)
        let attackLines = 0;
        if (linesCleared === 2) attackLines = 1;
        else if (linesCleared === 3) attackLines = 2;
        else if (linesCleared >= 4) attackLines = 4;

        if (attackLines === 0) {
            return null;
        }

        // 살아있는 다른 플레이어들에게 공격
        const targets = game
            .getAlivePlayers()
            .filter((p) => p.id !== attackerId)
            .map((p) => p.id);

        this.logger.log(
            `Player ${attackerId} attacking ${targets.length} players with ${attackLines} lines`,
        );

        return {
            targetIds: targets,
            attackLines,
        };
    }

    // 플레이어 게임 오버 처리
    handleGameOver(
        roomId: string,
        playerId: string,
    ): { rank: number; shouldEndGame: boolean; finalRanking?: any[] } {
        const game = this.games.get(roomId);
        if (!game) {
            return { rank: -1, shouldEndGame: false };
        }

        const rank = game.setPlayerGameOver(playerId);
        const shouldEndGame = game.shouldEndGame();

        this.logger.log(
            `Player ${playerId} game over with rank ${rank}. Should end game: ${shouldEndGame}`,
        );

        let finalRanking;
        if (shouldEndGame) {
            game.endGame();
            finalRanking = game.getFinalRanking();
            this.logger.log(`Game ended for room ${roomId}`);
        }

        return { rank, shouldEndGame, finalRanking };
    }

    // 게임 종료
    endGame(roomId: string): void {
        const game = this.games.get(roomId);
        if (game) {
            game.endGame();
            this.games.delete(roomId);
            this.logger.log(`Game deleted for room ${roomId}`);
        }
    }

    // 게임 삭제 (방이 삭제될 때)
    deleteGame(roomId: string): void {
        this.games.delete(roomId);
        this.logger.log(`Game force deleted for room ${roomId}`);
    }
}
