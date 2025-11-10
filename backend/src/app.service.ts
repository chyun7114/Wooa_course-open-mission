import { Injectable, Inject } from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';

@Injectable()
export class AppService {
  constructor(@Inject(CACHE_MANAGER) private cacheManager: Cache) {}

  async getHello(): Promise<string> {
    // Redis 캐시 예제
    const cachedValue = await this.cacheManager.get<string>('hello');
    
    if (cachedValue) {
      return `Cached: ${cachedValue}`;
    }

    const value = 'Hello World!';
    await this.cacheManager.set('hello', value, 60000); // 60초 TTL
    
    return value;
  }
}
