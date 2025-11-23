# 🎮 테트리스 멀티플레이 게임

Flutter + NestJS를 활용하여 싱글/멀티플레이를 지원하는 웹 테트리스 게임입니다.

## 🌐 플레이하기

**GitHub Pages 배포**: https://chyun7114.github.io/Wooa_course-open-mission/

## 🚀 실행 방법

### 프론트엔드 (Flutter Web)

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### 백엔드 (NestJS)

```bash
cd backend
npm install
npm run start:dev
```

**환경 변수 설정** (`.env` 파일 생성)

```env
DATABASE_URL=postgresql://user:password@localhost:5432/tetris
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=1h
```

**데이터베이스 마이그레이션**

```bash
npm run db:push
```

## 🛠 기술 스택

### Frontend

- **Flutter** - 크로스 플랫폼 UI 프레임워크
- **Provider** - 상태 관리
- **Dio** - HTTP 클라이언트
- **socket_io_client** - WebSocket 통신

### Backend

- **NestJS** - Node.js 프레임워크
- **PostgreSQL** - 관계형 데이터베이스
- **Drizzle ORM** - 타입 안전 ORM
- **Socket.IO** - 실시간 통신
- **JWT** - 인증/인가
- **bcrypt** - 비밀번호 암호화

### DevOps

- **GitHub Pages** - 프론트엔드 배포
- **Docker** - 컨테이너화
- **GitHub Actions** - CI/CD

## 📁 프로젝트 구조

```
Wooa_course-open-mission/
├── frontend/                 # Flutter 프론트엔드
│   ├── lib/
│   │   ├── core/            # 핵심 기능 (모델, 서비스, 네트워크)
│   │   │   ├── models/      # 데이터 모델 (Board, Tetromino, User 등)
│   │   │   ├── services/    # API 서비스
│   │   │   ├── network/     # WebSocket, HTTP 클라이언트
│   │   │   └── constants/   # 상수 정의
│   │   ├── providers/       # 상태 관리 (GameProvider, RoomProvider 등)
│   │   ├── screens/         # 화면 UI
│   │   │   ├── auth/        # 로그인/회원가입
│   │   │   ├── game/        # 게임 화면 (싱글/멀티)
│   │   │   └── room/        # 방 목록/대기실
│   │   └── widgets/         # 재사용 가능한 위젯
│   │       ├── game/        # 게임 관련 위젯 (보드, 블록 등)
│   │       ├── multiplayer/ # 멀티플레이 전용 위젯
│   │       └── room/        # 방 관련 위젯
│   └── test/                # 테스트 코드
│
├── backend/                 # NestJS 백엔드
│   ├── src/
│   │   ├── common/          # 공통 모듈
│   │   │   ├── config/      # 설정 (DB, Swagger)
│   │   │   ├── db/          # 데이터베이스 연결
│   │   │   ├── decorators/  # 커스텀 데코레이터
│   │   │   ├── guards/      # 인증 가드
│   │   │   ├── interceptors/# 인터셉터 (로깅, 응답 변환)
│   │   │   └── strategies/  # Passport 전략
│   │   ├── member/          # 회원 관리
│   │   │   ├── dto/         # 요청/응답 DTO
│   │   │   ├── entity/      # DB 엔티티
│   │   │   └── infrastructure/ # 리포지토리
│   │   ├── ranking/         # 랭킹 시스템
│   │   ├── room/            # 방 관리
│   │   └── game/            # 게임 로직 (WebSocket Gateway)
│   ├── drizzle/             # DB 마이그레이션
│   └── test/                # E2E 테스트
│
└── docs/                    # 배포된 웹 앱 (GitHub Pages)
```

## ✨ 주요 기능

### 싱글 플레이

- 클래식 테트리스 게임 플레이
- 레벨 시스템 및 점수 계산
- 고스트 블록 표시
- Hold 기능
- 실시간 랭킹 시스템

### 멀티 플레이

- 최대 8명 동시 플레이
- 실시간 게임 상태 동기화
- 라인 클리어 공격 시스템
- 방 생성/검색/입장
- 채팅 기능
- 최종 순위 표시

### 기능 구현 상세

**Front-end (Flutter)**

- [x] 보드 모델 구현
- [x] 테트로미노 블록 정의 및 스폰/랜덤 생성
- [x] 충돌 검사
- [x] 중력 + 고정 로직
- [x] 줄 삭제 + 점수 갱신 로직
- [x] 렌더링(그리드 UI) + 키 입력(좌/우/하/회전)
- [x] 게임 루프 제작 + 게임 오버 처리
- [x] 다음 블록 큐
- [x] hold 기능
- [x] 레벨/속도, 일시정지
- [x] 고스트 블럭 추가(떨어지는 위치가 보인다)

**Back-end (NestJS)**

**유저 시스템**

- [x] 회원가입/로그인 API (JWT 인증)
- [x] 유저 프로필 조회/수정
- [x] 비밀번호 암호화 (bcrypt)
- [x] 토큰 갱신(refresh token)

**랭킹 시스템**

- [x] 싱글 플레이 게임 결과 저장 API
- [x] 전체 랭킹 조회 (페이지네이션)
- [x] 개인 최고 기록 조회
- [x] 일간/주간/전체 랭킹 분리
- [x] 랭킹 캐싱 (Redis 옵션)

**멀티플레이 시스템**

- [x] WebSocket 연결 관리 (Gateway)
- [x] 방 생성/입장/퇴장
- [x] 방 목록 조회 및 검색
- [x] 게임 시작/종료 신호 처리
- [x] 실시간 게임 상태 동기화 (블록 위치, 보드 상태)

**인프라 & 부가기능**

- [x] 데이터베이스 설계 및 마이그레이션 (TypeORM/Prisma)
- [x] API 문서화 (Swagger)
- [x] 에러 핸들링 및 로깅
- [x] 환경 변수 관리 (.env)
- [x] CORS 설정
- [x] 배포 (Docker, GitHub Pages)

## 📝 개발 컨벤션

### Git Workflow

```
main (프로덕션)
├── develop (개발 통합)
│   ├── feature/frontend/{feature-name}
│   ├── feature/backend/{feature-name}
│   └── hotfix/{issue-name}
```

### 커밋 컨벤션

```
{type}({scope}): {description}
```

**Type**

- `feat`: 새로운 기능
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅
- `refactor`: 리팩토링
- `test`: 테스트 코드
- `chore`: 빌드/설정 변경

**예시**

```bash
feat(game): Add multiplayer game synchronization
fix(ranking): Fix null nickname error in ranking display
docs(readme): Update project structure documentation
```

## 🎯 향후 개선 계획

- [ ] 사운드 효과 및 BGM 추가
- [ ] 모바일 앱 지원 (Android/iOS)
- [ ] 커스텀 게임 설정 (속도, 블록 종류 등)
- [ ] 멀티플레이 공격 기능 추가

## 👥 기여자

- [chyun7114](https://github.com/chyun7114)

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.
