import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { GetUser } from 'src/common/decorators/get-user.decorator';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth.guard';
import { RankingService } from './ranking.service';

@Controller('ranking')
export class RankingController {
    constructor(private readonly rankingService: RankingService) {}

    @Post()
    @UseGuards(JwtAuthGuard)
    async upsertRanking(
        @GetUser('id') memberId: number,
        @Body('score') score: number,
    ) {
        return await this.rankingService.upsertRanking(memberId, score);
    }

    @Get('top')
    async getTopRankings() {
        return await this.rankingService.findTopRankings();
    }

    @Get('my')
    @UseGuards(JwtAuthGuard)
    async getMyRanking(@GetUser('id') memberId: number) {
        return await this.rankingService.findByMember(memberId);
    }
}
