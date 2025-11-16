# 📘 Flutter + NestJS Vibe 코딩 룰셋

본 문서는 Flutter·NestJS 기반 프로젝트의 일관성과 유지보수성을 높이기 위한
컴포넌트 기반 설계 원칙과 SOLID 원칙 중심의 코딩 규칙을 정의한다.

---

# 0. 공통 원칙

## 0.1 SOLID 원칙

### S — Single Responsibility Principle (단일 책임)
- 하나의 클래스는 하나의 책임만 가진다.
- 비즈니스 로직, UI 로직, 데이터 접근을 분리한다.
- 파일 300줄 이상은 SRP 위반 가능성 검토.

### O — Open/Closed Principle (개방·폐쇄)
- 확장은 쉽게, 변경은 최소화.
- 인터페이스 기반 설계, DI 적극 활용.

### L — Liskov Substitution Principle (리스코프 치환)
- 상위 타입을 하위 타입으로 안전하게 대체 가능해야 한다.
- Repository, Service, ViewModel 등은 interface/abstract 기반 구성.

### I — Interface Segregation Principle (인터페이스 분리)
- 사용하지 않는 메서드가 정의된 인터페이스 의존 금지.
- public API 최소화.

### D — Dependency Inversion Principle (의존 역전)
- 상위 모듈은 하위 구현에 의존하면 안 된다.
- Flutter: ViewModel → Repository → DataSource 구조
- Nest: Controller → Service → Repository 구조

---

# 1. Flutter 코딩 규칙

## 1.1 UI / 로직 분리

### Presentational vs Container 구조
- **Presentational Widget**: UI만 담당, Stateless 중심.
- **Container Widget(ViewModel)**: 상태 관리 및 액션 처리 전담.

디렉토리 예:
```

lib/
├─ presentation/
│   ├─ screens/
│   ├─ widgets/
│   └─ viewmodels/
└─ data/
├─ repositories/
└─ datasources/

```

## 1.2 Layered Architecture

```

lib/
├── data/
│    ├── models/
│    ├── dto/
│    ├── repositories/
│    └── datasources/
├── domain/
│    ├── entities/
│    └── usecases/
├── presentation/
│    ├── viewmodels/
│    ├── screens/
│    └── widgets/
└── core/
├── constants/
├── error/
├── utils/
└── config/

```

## 1.3 위젯/코드 스타일
- `const` 최대한 활용.
- Build 메서드는 100줄 이하 유지. UI는 private widget 함수로 분리.
- 공용 컴포넌트는 `presentation/widgets/common/` 내부 저장.
- 한 파일에 클래스는 2개 이상 넣지 않는다.
- 상수는 `core/constants`에 통합.

---

# 2. NestJS 코딩 규칙

## 2.1 모듈 구조 (Feature-Based Module)

```

src/
├── auth/
├── users/
├── jobs/
├── todo/
└── common/

```

- 하나의 기능(Feature)은 하나의 모듈(Module)로 관리
- 모듈 내부 구조 예:
```

/controller
/service
/repository
/dto
/entities

```

## 2.2 Layered Rule
- **Controller**: 요청/응답 처리, 비즈니스 로직 포함 금지
- **Service**: 도메인 로직의 중심
- **Repository**: DB 접근에 집중
- **DTO**: Request/Response 타입 명시
- **Entity**: 구조체 성격 유지

## 2.3 코드 스타일
- Controller 메서드 100줄 이하면 유지
- Service는 기능 단위로 private 메서드 분리
- 상수는 `/constants/`로 관리
- 예외 처리는 Custom Exception + Global Filter로 일원화
- Swagger Decorator는 Custom Decorator로 공통화

---

# 3. 공통 규칙 (Flutter & NestJS)

## 3.1 Feature 기반 컴포넌트화
- 공통 규칙: 기능 단위로 디렉토리 및 책임을 완전히 격리한다.
- Feature 예: `auth`, `job`, `todo`, `user`, `chat`

Flutter와 NestJS 모두 Feature 중심 구조를 유지한다.

## 3.2 DTO 규칙
- Flutter ↔ NestJS 간 DTO는 명시적 타입 사용
- 서버 필드명 변경 시 클라이언트 즉시 반영
- Client Entity 재사용 금지 (각 레이어 독립 유지)

## 3.3 에러 처리 통합 규칙
- **Flutter**: ViewModel → error state → UI에서 SnackBar/Dialog 처리
- **NestJS**: HttpException → ExceptionFilter로 통일

## 3.4 테스트 규칙
- Flutter: ViewModel 단위 테스트 권장
- NestJS: Service 단위 테스트 최우선, Repository는 mock 처리

---

# 4. 핵심 정리 (One-liner)
> 기능 단위로 완전히 분리된 컴포넌트 구조를 유지하며,  
> Flutter·NestJS 모두 UI/로직/도메인/데이터 계층을 분리하고  
> SOLID 원칙을 통한 확장성과 유지보수성을 보장한다.

```
