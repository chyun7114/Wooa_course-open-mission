import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { GetUser } from 'src/common/decorators/get-user.decorator';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth.guard';
import { RankingService } from './ranking.service';
import { RankingListDto } from './dto/ranking-list.dto';

@Controller('ranking')
export class RankingController {
    constructor(private readonly rankingService: RankingService) {}

    @Post()
    @UseGuards(JwtAuthGuard)
    async upsertRanking(
        @GetUser('userId') userId: string,
        @Body('score') score: number,
    ) {
        const memberId = parseInt(userId, 10);
        return await this.rankingService.upsertRanking(memberId, score);
    }

    @Get('top')
    async getTopRankings() {
        return await this.rankingService.findTopRankings();
    }

    @Get('my')
    @UseGuards(JwtAuthGuard)
    async getMyRanking(@GetUser('userId') userId: string) {
        const memberId = parseInt(userId, 10);
        return await this.rankingService.findByMember(memberId);
    }
}
