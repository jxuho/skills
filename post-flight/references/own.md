# Own — durable mental model 만들기

Own은 점수를 매기는 phase가 아니다.

이 티켓에서 개발자가 현재 설명할 수 있는 것, 새로 배운 것, 아직 불확실한 것을 다음 티켓에서도 다시 읽을 수 있게 압축한다.

## 1. Ticket intent

사용자/시스템 관점에서 이 티켓이 무엇을 바꾸려 했는지 기록한다.

file-by-file 변경 목록으로 쓰지 않는다.

## 2. Actual system change

runtime/data flow 중심으로 설명한다.

예:

```text
cancel request
  -> authorization
  -> order state change
  -> outbox event
  -> refund worker
  -> payment provider
```

필요한 경우 sync/async boundary, transaction, persistence, external side effect를 표시한다.

## 3. I can account for

Account에서 설명했고 Verify evidence와 크게 충돌하지 않은 중요한 영역을 기록한다.

예:

- authorization boundary
- state transition
- duplicate request behavior
- async side effect

## 4. Corrected mental models

Account에서 가졌지만 Verify에서 `DISPROVED`된 뒤 Learn을 통해 교정된 생각만 기록한다.

형식 예:

```text
Before:
"refund와 cancellation이 같은 transaction이라고 생각했다."

Now:
"cancellation은 먼저 commit되고 refund는 async worker가 처리한다."
```

## 5. Learned

이번 티켓을 통해 새로 이해한 시스템 동작이나 재사용 가능한 개념을 기록한다.

너무 일반적인 정의보다 이 시스템에서 어떻게 적용되는지 중심으로 쓴다.

## 6. Remaining uncertainty

다음을 숨기지 않는다.

- `UNVERIFIED`
- `unresolved`
- repository evidence 부족
- 운영 환경에서만 확인 가능한 동작

필요하면 다음 조사 방법도 한 줄 기록한다.

## 7. If this breaks

짧은 debugging orientation을 남긴다.

- 첫 번째로 볼 코드/컴포넌트
- 볼 log/metric/DB state
- 예상되는 failure boundary

runbook 전체를 만들지 않는다. "어디부터 조사할지" 기억할 정도면 충분하다.

## 8. Optional pre-flight reconciliation

같은 티켓의 pre-flight가 있으면 이 단계에서만 비교한다.

다음으로 분류한다.

### Confirmed

구현 전 mental model이 실제 변경과 일치한 부분.

### Expanded

틀리지는 않았지만 실제 시스템이 더 넓거나 복잡했던 부분.

### Corrected

구현 전 mental model이 실제 evidence와 달랐던 부분.

pre-flight 원문은 수정하지 않는다.

## 9. 금지사항

- 숫자 점수
- 이해도 percentage
- "완전히 이해했다" 선언
- unresolved gap 삭제
- 과거 답변 재작성

최종 artifact는 짧고 다시 읽기 쉬워야 한다.
