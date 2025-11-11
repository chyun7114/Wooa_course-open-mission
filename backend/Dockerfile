# 멀티 스테이지 빌드를 사용하여 이미지 크기 최적화

# Stage 1: 빌드 단계
FROM node:20-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# package.json과 package-lock.json 복사
COPY package*.json ./

# 의존성 설치 (dev dependencies 포함)
RUN npm ci

# 소스 코드 복사
COPY . .

# TypeScript 빌드
RUN npm run build

# 프로덕션 의존성만 설치
RUN npm ci --only=production && npm cache clean --force

# Stage 2: 프로덕션 단계
FROM node:20-alpine AS production

# 보안을 위한 non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 단계에서 필요한 파일만 복사
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/package*.json ./

# 환경변수 설정
ENV NODE_ENV=production
ENV PORT=3000

# 포트 노출
EXPOSE 3000

# non-root 사용자로 전환
USER nestjs

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 애플리케이션 실행
CMD ["node", "dist/main"]
