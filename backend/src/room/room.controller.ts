import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { RoomService } from './room.service';
import { RoomResponseDto, RoomDetailResponseDto } from './dto';
import { CommonResponse } from '../common/response';

@ApiTags('Room')
@Controller('rooms')
export class RoomController {
    constructor(private readonly roomService: RoomService) {}

    @Get()
    @ApiOperation({ summary: '방 목록 조회' })
    @ApiResponse({
        status: 200,
        description: '방 목록 조회 성공',
        type: [RoomResponseDto],
    })
    findAllRooms(): CommonResponse<RoomResponseDto[]> {
        const rooms = this.roomService.findAllRooms();
        return CommonResponse.success(
            rooms.map((room) => room.toResponse()),
            '방 목록을 조회했습니다.',
        );
    }

    @Get(':roomId')
    @ApiOperation({ summary: '방 상세 정보 조회' })
    @ApiResponse({
        status: 200,
        description: '방 상세 정보 조회 성공',
        type: RoomDetailResponseDto,
    })
    @ApiResponse({ status: 404, description: '방을 찾을 수 없음' })
    findRoom(
        @Param('roomId') roomId: string,
    ): CommonResponse<RoomDetailResponseDto> {
        const room = this.roomService.findRoom(roomId);

        if (!room) {
            return CommonResponse.fail(404, '방을 찾을 수 없습니다.');
        }

        return CommonResponse.success(
            room.toDetailResponse(),
            '방 정보를 조회했습니다.',
        );
    }

    @Get('stats/summary')
    @ApiOperation({ summary: '통계 조회' })
    @ApiResponse({
        status: 200,
        description: '통계 조회 성공',
    })
    getStats() {
        return CommonResponse.success(
            {
                totalRooms: this.roomService.getRoomCount(),
                activePlayers: this.roomService.getActivePlayerCount(),
            },
            '통계를 조회했습니다.',
        );
    }
}
