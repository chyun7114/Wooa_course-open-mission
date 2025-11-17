import { Injectable } from '@nestjs/common';
import { RankingRepository } from './ranking.repository';
import { RankingListDto } from './dto/ranking-list.dto';

@Injectable()
export class RankingService {
    constructor(private readonly rankingRepository: RankingRepository) {}

    async upsertRanking(memberId: number, score: number) {
        return await this.rankingRepository.upsertRanking(memberId, score);
    }

    async findTopRankings(limit: number = 10): Promise<RankingListDto[]> {
        const rows = await this.rankingRepository.findTopRankings(limit);
        return rows.map((row) => new RankingListDto(row.nickname, row.score));
    }

    async findByMember(memberId: number) {
        return await this.rankingRepository.findByMember(memberId);
    }
}
