import { Module } from '@nestjs/common';
import { RankingService } from './ranking.service';
import { RankingController } from './ranking.controller';
import { RankingRepository } from './ranking.repository';

@Module({
    controllers: [RankingController],
    providers: [RankingService, RankingRepository],
})
export class RankingModule {}
