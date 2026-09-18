# Verify — 믿음을 evidence와 대조하기

Verify는 Account에서 드러난 mental model을 실제 시스템과 비교하는 phase다.

과거 답변을 채점하거나 수정하는 것이 아니라, 어떤 주장이 실제 evidence와 일치하는지 확인한다.

## 1. 검증 대상 고르기

`01-account.md`를 읽고 검증 가치가 높은 주장만 고른다.

우선순위:

1. 보안, 돈, PII, 데이터 무결성
2. transaction, concurrency, retry, ordering
3. 실패 모드와 부분 성공
4. external side effect
5. 넓은 blast radius
6. 확신이 낮거나 모호한 주장
7. 명시적 knowledge gap 중 실제 동작 확인이 중요한 영역

모든 사소한 문장을 검증하지 않는다.

## 2. Evidence 우선순위

가능한 한 직접적인 evidence를 선호한다.

- 실제 implementation과 caller/callee
- DB schema, constraint, transaction 설정
- config
- 기존 테스트
- targeted test
- typecheck/static analysis
- local execution/reproduction
- log/trace
- framework 또는 dependency의 authoritative documentation

repository evidence로 충분하면 외부 설명에 의존하지 않는다.

## 3. 예측과 확인을 분리하기

Account의 답을 그대로 claim으로 가져온다.

예:

```text
Claim:
"refund 실패 시 cancellation도 rollback될 것 같다."
```

그 다음 evidence를 조사한다.

개발자의 과거 답을 evidence에 맞게 고쳐 쓰지 않는다.

## 4. 결과 분류

각 claim은 다음 중 하나로만 분류한다.

### CONFIRMED

현재 evidence가 claim을 지지한다.

### DISPROVED

현재 evidence가 claim과 충돌한다.

### UNVERIFIED

증거가 부족하거나 합리적인 범위에서 확정할 수 없다.

`UNVERIFIED`는 실패가 아니다. 불확실성을 보존한다.

## 5. 기록 형식

각 항목에 다음을 남긴다.

```text
Claim
Result
Evidence
Reasoning
Remaining uncertainty
```

테스트가 통과했다는 사실만으로 모든 semantic claim을 CONFIRMED로 만들지 않는다. 테스트가 실제로 무엇을 증명하는지 구체적으로 연결한다.

## 6. 파괴적인 검증 금지

production system을 변경하거나 파괴적인 operation을 수행하지 않는다.

검증을 위해 위험한 migration, 실제 결제, 실제 사용자 데이터 변경 등이 필요하면 직접 실행하지 말고 `UNVERIFIED`와 필요한 검증 방법을 기록한다.

## 7. Verify 종료 조건

다음이 충족되면 끝낸다.

- high-risk claim에 대한 evidence가 확보되었거나 `UNVERIFIED`로 명확히 남음
- 주요 misconception이 `DISPROVED`로 식별됨
- Learn에 넘길 gap이 충분히 명확해짐

검증 가능한 모든 세부사항을 끝까지 조사하려고 하지 않는다.
