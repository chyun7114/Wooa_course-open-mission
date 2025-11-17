import { Injectable } from '@nestjs/common';
import { RankingRepository } from './ranking.repository';

@Injectable()
export class RankingService {
    constructor(private readonly rankingRepository: RankingRepository) {}

    async upsertRanking(memberId: number, score: number) {
        return await this.rankingRepository.upsertRanking(memberId, score);
    }

    async findTopRankings(limit: number = 10) {
        return await this.rankingRepository.findTopRankings(limit);
    }

    async findByMember(memberId: number) {
        return await this.rankingRepository.findByMember(memberId);
    }
}
