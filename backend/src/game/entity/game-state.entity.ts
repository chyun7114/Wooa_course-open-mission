export interface PlayerGameState {
    id: string;
    nickname: string;
    isAlive: boolean;
    rank?: number; // 게임 오버 순위
    score: number;
    level: number;
    linesCleared: number;
    board?: number[][]; // 테트리스 보드 데이터 (20x10)
    gameOverAt?: Date;
}

export class GameState {
    roomId: string;
    players: Map<string, PlayerGameState>;
    isPlaying: boolean;
    startedAt: Date;
    endedAt?: Date;
    private nextRank: number = 1;

    constructor(roomId: string, playerIds: { id: string; nickname: string }[]) {
        this.roomId = roomId;
        this.isPlaying = true;
        this.startedAt = new Date();
        this.players = new Map();

        playerIds.forEach((player) => {
            this.players.set(player.id, {
                id: player.id,
                nickname: player.nickname,
                isAlive: true,
                score: 0,
                level: 1,
                linesCleared: 0,
            });
        });
    }

    // 플레이어 게임 오버 처리
    setPlayerGameOver(playerId: string): number {
        const player = this.players.get(playerId);
        if (!player || !player.isAlive) {
            return -1;
        }

        const alivePlayers = this.getAlivePlayers();
        const rank = alivePlayers.length; // 현재 살아있는 인원 = 등수

        player.isAlive = false;
        player.rank = rank;
        player.gameOverAt = new Date();

        return rank;
    }

    // 플레이어 상태 업데이트
    updatePlayerState(
        playerId: string,
        score: number,
        level: number,
        linesCleared: number,
    ): boolean {
        const player = this.players.get(playerId);
        if (!player || !player.isAlive) {
            return false;
        }

        player.score = score;
        player.level = level;
        player.linesCleared = linesCleared;

        return true;
    }

    // 살아있는 플레이어 목록
    getAlivePlayers(): PlayerGameState[] {
        return Array.from(this.players.values()).filter((p) => p.isAlive);
    }

    // 게임 종료 여부 확인 (1명만 남았는지)
    shouldEndGame(): boolean {
        return this.getAlivePlayers().length <= 1;
    }

    // 게임 종료 처리
    endGame(): void {
        this.isPlaying = false;
        this.endedAt = new Date();

        // 마지막 생존자에게 1등 부여
        const lastPlayer = this.getAlivePlayers()[0];
        if (lastPlayer) {
            lastPlayer.rank = 1;
        }
    }

    // 최종 순위 (rank 오름차순 정렬)
    getFinalRanking(): PlayerGameState[] {
        return Array.from(this.players.values()).sort(
            (a, b) => (a.rank || 999) - (b.rank || 999),
        );
    }

    // 응답용 데이터
    toResponse() {
        return {
            roomId: this.roomId,
            isPlaying: this.isPlaying,
            startedAt: this.startedAt,
            endedAt: this.endedAt,
            players: Array.from(this.players.values()),
            alivePlayers: this.getAlivePlayers().length,
        };
    }
}
