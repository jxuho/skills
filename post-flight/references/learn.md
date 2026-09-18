# Learn — 발견한 gap만 닫기

Learn은 일반적인 강의가 아니다.

Account와 Verify에서 실제로 드러난 gap 중 이 변경을 소유하는 데 중요한 것만 학습한다.

## 1. 학습 대상 선정

우선순위:

1. `DISPROVED`된 mental model
2. high-risk 영역의 `knowledge-gap`
3. 이 티켓의 핵심 메커니즘을 이해하는 데 필요한 개념
4. 장애 대응이나 이후 수정에 필요한 시스템 지식
5. 앞으로 반복해서 잘못 판단하게 만들 가능성이 큰 오해

낮은 위험의 trivia, library 내부 구현, 이번 변경과 무관한 이론은 기본적으로 제외한다.

## 2. Repository-specific하게 설명하기

가능한 한 추상적인 교과서 설명보다 실제 repository를 사용한다.

예:

```text
OrderService.cancel()
  -> order state update
  -> outbox write
  -> async worker
  -> payment provider
```

그 위에서 transaction, eventual consistency, idempotency 같은 개념을 설명한다.

## 3. 각 gap 학습 루프

다음 순서를 지킨다.

### Gap

무엇을 잘못 알았거나 몰랐는지 짧게 명시한다.

### Mechanism

실제 코드 흐름과 시스템 경계를 설명한다.

### Consequence

그 구조 때문에 성공/실패 시 어떤 상태가 남는지 설명한다.

### Failure / trade-off

의미 있는 실패 모드 또는 trade-off 하나를 연결한다.

### Teach-back

개발자에게 설명을 보지 않고 자기 말로 다시 설명하게 한다.

## 4. Teach-back 질문

다음 형태를 우선한다.

- 요청부터 최종 side effect까지 흐름을 네 말로 설명해봐.
- 왜 transaction boundary가 여기에서 끝나는지 설명해봐.
- 앞 단계는 성공하고 다음 단계가 실패하면 어떤 상태가 남아?
- 같은 이벤트가 두 번 들어와도 안전해야 하는 이유는 뭐야?
- production에서 이게 실패하면 어디부터 확인할 거야?

"이해했어?"로 끝내지 않는다.

## 5. 학습 상태

다음 중 하나로 기록한다.

### learned

개발자가 핵심 인과관계와 실제 결과를 자기 말로 설명할 수 있다.

### unresolved

설명 후에도 핵심 관계를 설명하지 못하거나 evidence 자체가 부족하다.

`unresolved`를 억지로 닫지 않는다.

## 6. 반복 횟수 제한

teach-back이 부족하면 빠진 부분만 다시 설명하고 한 번 더 시도한다.

같은 주제를 무한 반복하지 않는다. 여전히 부족하면 `unresolved`로 남기고 무엇을 더 조사해야 하는지 기록한다.
