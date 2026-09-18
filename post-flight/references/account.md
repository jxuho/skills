# Account — 개발자의 이해를 리뷰하기

Account는 코드 리뷰가 아니라 **개발자의 이해에 대한 reverse review**다.

코드가 맞는지 다시 평가하는 것보다, 개발자가 자신이 배포하려는 변경을 어디까지 설명하고 책임질 수 있는지 확인한다.

## 1. 실제 diff에서 시작하기

추상적인 질문으로 시작하지 않는다. 반드시 실제 PR, branch, diff 또는 staged work를 읽는다.

질문마다 구체적인 코드 영역을 anchor로 사용한다.

가능하면 다음을 함께 제공한다.

- file path
- 현재 line 또는 line range
- 짧은 verbatim snippet

line number는 바뀔 수 있으므로 snippet을 주 anchor로 사용한다. line number를 제시하기 직전에 현재 파일을 다시 확인한다.

snippet에 API key, token, password, cookie, connection string, private key 등 credential이 있으면 값을 마스킹한다. 답변과 checkpoint에도 secret을 그대로 복제하지 않는다.

## 2. 모든 변경을 묻지 말고 위험한 곳을 고르기

이해하지 못했을 때 비용이 큰 영역을 우선한다.

우선순위:

1. auth, permission, money, PII, secret
2. migration, schema, irreversible production state
3. transaction, data integrity
4. concurrency, cache, retry, ordering, timing
5. 외부 side effect와 distributed workflow
6. signature/interface/return/error contract 변경
7. 새 dependency 또는 abstraction
8. 기존 코드에 크게 덧붙여진 additive block
9. error handling과 unhappy path
10. 필요 이상으로 추가된 defensive/boilerplate logic
11. 기존 코드나 표준 기능 대신 새로 만든 custom implementation

rename, formatting, 단순 log 변경 등 낮은 위험의 변경은 건너뛴다.

선정한 영역과 선정 이유를 내부적으로 명확히 한다.

## 3. 한 번에 질문 하나만 하기

질문 하나를 하고 답을 기다린다.

질문 목록을 한꺼번에 던지지 않는다. 이전 답변이 다음 질문을 결정하게 한다.

좋은 질문은 코드를 그대로 읽어서 답할 수 없어야 한다.

다음을 주로 묻는다.

- rationale: 왜 이렇게 했는가?
- consequence: 이 선택으로 어떤 일이 생기는가?
- assumption: 무엇이 참이라고 가정하는가?
- failure: 어디서 어떻게 실패하는가?
- blast radius: 누가 영향을 받는가?
- alternative: 왜 다른 방법이 아닌가?
- operation: 장애가 나면 어디서 알 수 있는가?

## 4. 질문 패턴

### Blast radius

> 이 반환 동작이 바뀌었는데, 기존 호출자 중 이전 동작을 전제로 하는 곳은 어디까지 있을 것 같아?

### 선택하지 않은 길

> 여기서 이 abstraction을 쓴 이유가 뭐라고 생각해? 더 단순한 방법과 비교하면 어떤 trade-off가 있어?

### Additive bloat

> 기존 함수를 바꾸는 대신 wrapper를 추가했어. 기존 로직 중 반드시 유지해야 하는 것은 무엇이고, 이 구조가 중복 동작을 만들 가능성은 없어?

### 삭제 사고실험

> 이 guard/try-catch가 없다고 가정하면 사용자가 어떤 차이를 보게 될 것 같아?

코드를 실제로 삭제하라고 시키지 않는다. 사고실험으로만 묻는다.

### 숨은 가정

> 이 로직은 입력이 이미 정렬되어 있다고 가정하는 것처럼 보여. 그 보장은 어디에서 생기고, 깨지면 어떤 일이 생길까?

### 도달 가능한 실패

> 어떤 종류의 실제 입력이나 운영 상황이 이 코드를 실패하게 만들 수 있을까? 실제 사용자 요청에서 도달 가능한 상황일까?

### Contract 변경

> 이 signature/return/error shape를 사용하는 쪽은 누구고, 이 diff 바깥의 caller도 영향을 받을까?

### 중복/재시도

> 이 이벤트나 요청이 같은 내용으로 두 번 처리되면 state가 어떻게 될 것 같아?

### 부분 성공

> 앞 단계는 성공했는데 다음 단계에서 실패하면 시스템에는 어떤 상태가 남을까?

### 운영 관점

> 이게 production에서 깨졌다면 어디부터 조사할 것 같아? 어떤 log, metric, DB state가 첫 단서가 될까?

## 5. Quiz로 만들지 않기

정답 하나를 맞히는 시험으로 만들지 않는다.

정확한 입력값, 키 입력, 숫자 등을 맞히게 하는 gotcha 질문보다 개발자가 이유와 결과를 자기 말로 설명하게 한다.

틀린 답을 바로 교정하지 않는다. Account의 목적은 현재 mental model을 드러내는 것이다.

## 6. 답이 얕으면 한두 번 더 파고들기

다음 응답은 충분한 이해로 간주하지 않는다.

- 코드를 그대로 읽은 설명
- "Codex가 그렇게 만들었다"
- "테스트가 통과한다"
- 이유 없는 추측
- 모호한 hedge

한두 번 follow-up한다.

예:

> 그렇다면 왜 이 위치에서 하는 게 중요하다고 생각해?

> 그 보장은 코드 어디에서 생긴다고 생각해?

> 실패했을 때 앞 단계의 state는 어떻게 된다고 생각해?

Account를 끝없이 이어가지 않는다. 중요한 이해 여부가 드러났으면 다음 영역으로 간다.

## 7. 실행하거나 수정하게 하지 않기

Account에서는 개발자에게 다음을 요구하지 않는다.

- 코드 수정
- 테스트 실행
- debugger 실행
- reproduction 작성
- 임시 logging 추가

이 phase에서는 말로 예측하고 설명하게 한다.

실제 확인은 Verify에서 한다.

## 8. Anti-gaming

개발자는 자기 말로 답한다.

Account 질문의 답을 얻기 위해 다른 AI에게 다시 질문하도록 유도하지 않는다. 답하기 위해 AI의 설명이 필요하다면 그 자체를 knowledge gap으로 기록한다.

AI가 개발자의 답을 대신 작성하거나 답변을 더 그럴듯하게 다듬지 않는다.

## 9. "모르겠다"를 정상적인 결과로 다루기

"모르겠다"를 실패나 감점으로 취급하지 않는다.

다음을 기록한다.

- 어느 영역을 모르는가
- 왜 이 gap이 중요한가
- 무엇을 확인하면 gap을 닫을 수 있는가

개발자가 안전하게 모른다고 말할 수 있게 한다.

## 10. Blind-spot 질문으로 끝내기

Account 마지막에는 반드시 다음 취지의 질문을 한다.

> 이번 변경에서 네가 가장 덜 이해하는 부분은 어디야? 그 부분이 잘못됐다면 review, CI, production 중 어디에서 발견될 것 같아? 아니면 쉽게 발견되지 않을 수도 있을까?

답변을 바탕으로 **모름의 위험도**도 기록한다. 복잡도뿐 아니라 잘못됐을 때 발견 가능성도 고려한다.

## 11. 동결하기

`01-account.md`에는 개발자의 중요한 답을 가능한 한 verbatim으로 저장한다.

다음을 하지 않는다.

- paraphrase
- 문법/표현 다듬기
- 더 정확한 답으로 보강
- Verify 후 과거 답 수정

길이가 과도하면 명시적으로 `...`를 사용해 일부만 줄인다.

secret은 마스킹한다.

각 영역을 다음 중 하나로 기록한다.

- `accounted-for`
- `needs-verification`
- `knowledge-gap`

완료 후 `status: frozen`으로 표시한다.
