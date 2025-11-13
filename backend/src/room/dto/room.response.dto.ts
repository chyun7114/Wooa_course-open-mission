import { ApiProperty } from '@nestjs/swagger';

export class RoomPlayerDto {
    @ApiProperty({ description: '플레이어 ID' })
    id: string;

    @ApiProperty({ description: '플레이어 닉네임' })
    nickname: string;

    @ApiProperty({ description: '방장 여부' })
    isHost: boolean;

    @ApiProperty({ description: '준비 상태' })
    isReady: boolean;
}

export class RoomResponseDto {
    @ApiProperty({ description: '방 ID' })
    id: string;

    @ApiProperty({ description: '방 제목' })
    title: string;

    @ApiProperty({ description: '현재 인원' })
    currentPlayers: number;

    @ApiProperty({ description: '최대 인원' })
    maxPlayers: number;

    @ApiProperty({ description: '비공개 방 여부' })
    isPrivate: boolean;

    @ApiProperty({ description: '게임 진행 중 여부' })
    isPlaying: boolean;

    @ApiProperty({ description: '방장 닉네임' })
    hostNickname: string;

    @ApiProperty({ description: '생성 시간' })
    createdAt: Date;
}

export class RoomDetailResponseDto extends RoomResponseDto {
    @ApiProperty({ description: '플레이어 목록', type: [RoomPlayerDto] })
    players: RoomPlayerDto[];
}
