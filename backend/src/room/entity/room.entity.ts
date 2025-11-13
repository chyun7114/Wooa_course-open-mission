export interface Player {
    id: string;
    nickname: string;
    isHost: boolean;
    isReady: boolean;
    socketId: string;
}

export class Room {
    id: string;
    title: string;
    maxPlayers: number;
    password?: string;
    isPrivate: boolean;
    isPlaying: boolean;
    hostId: string;
    players: Map<string, Player>;
    createdAt: Date;

    constructor(
        id: string,
        title: string,
        maxPlayers: number,
        hostId: string,
        hostNickname: string,
        hostSocketId: string,
        password?: string,
    ) {
        this.id = id;
        this.title = title;
        this.maxPlayers = maxPlayers;
        this.password = password;
        this.isPrivate = !!password;
        this.isPlaying = false;
        this.hostId = hostId;
        this.players = new Map();
        this.createdAt = new Date();

        // 방장을 첫 번째 플레이어로 추가
        this.players.set(hostId, {
            id: hostId,
            nickname: hostNickname,
            isHost: true,
            isReady: true, // 방장은 자동으로 준비 상태
            socketId: hostSocketId,
        });
    }

    addPlayer(playerId: string, nickname: string, socketId: string): boolean {
        if (this.players.size >= this.maxPlayers) {
            return false;
        }

        if (this.players.has(playerId)) {
            return false;
        }

        this.players.set(playerId, {
            id: playerId,
            nickname,
            isHost: false,
            isReady: false,
            socketId,
        });

        return true;
    }

    removePlayer(playerId: string): boolean {
        const removed = this.players.delete(playerId);

        // 방장이 나갔다면 다음 플레이어를 방장으로 임명
        if (removed && playerId === this.hostId && this.players.size > 0) {
            const nextHost = Array.from(this.players.values())[0];
            nextHost.isHost = true;
            nextHost.isReady = true;
            this.hostId = nextHost.id;
        }

        return removed;
    }

    toggleReady(playerId: string): boolean {
        const player = this.players.get(playerId);
        if (!player || player.isHost) {
            return false;
        }

        player.isReady = !player.isReady;
        return true;
    }

    canStartGame(): boolean {
        if (this.players.size < 2) {
            return false;
        }

        // 방장을 제외한 모든 플레이어가 준비 상태인지 확인
        return Array.from(this.players.values())
            .filter((p) => !p.isHost)
            .every((p) => p.isReady);
    }

    startGame(): boolean {
        if (!this.canStartGame()) {
            return false;
        }

        this.isPlaying = true;
        return true;
    }

    endGame(): void {
        this.isPlaying = false;
        // 모든 플레이어의 준비 상태를 초기화 (방장 제외)
        this.players.forEach((player) => {
            if (!player.isHost) {
                player.isReady = false;
            }
        });
    }

    getPlayerBySocketId(socketId: string): Player | undefined {
        return Array.from(this.players.values()).find(
            (p) => p.socketId === socketId,
        );
    }

    updatePlayerSocketId(playerId: string, newSocketId: string): boolean {
        const player = this.players.get(playerId);
        if (!player) {
            return false;
        }

        player.socketId = newSocketId;
        return true;
    }

    isEmpty(): boolean {
        return this.players.size === 0;
    }

    isFull(): boolean {
        return this.players.size >= this.maxPlayers;
    }

    getCurrentPlayers(): number {
        return this.players.size;
    }

    getHostNickname(): string {
        const host = this.players.get(this.hostId);
        return host?.nickname || 'Unknown';
    }

    toResponse() {
        return {
            id: this.id,
            title: this.title,
            currentPlayers: this.getCurrentPlayers(),
            maxPlayers: this.maxPlayers,
            isPrivate: this.isPrivate,
            isPlaying: this.isPlaying,
            hostNickname: this.getHostNickname(),
            createdAt: this.createdAt,
        };
    }

    toDetailResponse() {
        return {
            ...this.toResponse(),
            players: Array.from(this.players.values()).map((p) => ({
                id: p.id,
                nickname: p.nickname,
                isHost: p.isHost,
                isReady: p.isReady,
            })),
        };
    }
}
