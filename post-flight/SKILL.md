---
name: post-flight
description: >-
  소프트웨어 변경을 구현한 뒤 개발자가 해당 변경을 실제로 이해하고 책임질 수 있는지 점검하는 post-flight 워크플로. "$post-flight [티켓 이름 또는 내용]" 호출, PR/branch/diff 구현 완료 후 ownership 점검, 특히 Codex나 다른 AI coding agent가 작성한 코드를 merge하기 전 이해도 검증에 사용한다. 실제 diff를 기반으로 개발자의 현재 이해를 먼저 Account하고, 그 응답을 동결한 뒤 repository evidence로 Verify하고, 발견된 gap만 Learn하며 teach-back을 거쳐 최종 Ownership 기록을 남긴다. 여러 세션에 걸쳐도 Markdown checkpoint로 재개 가능하게 한다.
---

# Post Flight

개발자가 "코드가 동작한다"에서 끝나지 않고 "이 변경을 이해하고 책임질 수 있다"까지 도달하도록 돕는다.

다음 순서를 반드시 지킨다.

1. Prepare
2. Account
3. Verify
4. Learn
5. Own

각 phase의 경계를 지킨다. 뒤 phase에서 알게 된 사실을 앞 phase의 과거 응답에 섞거나 수정하지 않는다.

## 호출 방식

다음 형태의 호출을 처리한다.

```text
$post-flight <티켓 이름, 티켓 ID 또는 티켓 내용>
```

예:

```text
$post-flight PAY-142
$post-flight 결제 완료 주문 취소 시 환불 처리
```

티켓을 식별할 수 있는 filesystem-safe `ticket-key`를 정한다.

상태를 다음 경로에 저장한다.

```text
.codex/ownership/<ticket-key>/postflight/
├── state.md
├── 01-account.md
├── 02-verification.md
├── 03-learning.md
└── 04-ownership.md
```

이미 파일이 존재하면 `state.md`를 읽고 첫 번째 미완료 phase부터 재개한다. 완료한 phase를 대화 기억만으로 복원하지 않는다.

출력 형식은 [references/templates.md](references/templates.md)를 따른다.

---

# Phase 0 — Prepare

실제 변경 대상을 확정한다.

다음을 확인한다.

- 티켓의 의도
- 검토할 실제 diff
- base commit 또는 비교 기준
- current HEAD
- 변경 파일
- 변경 주변의 관련 코드와 호출 관계

변경 대상은 가능한 경우 다음 순서로 선택한다.

1. 사용자가 명시한 PR 또는 diff
2. 현재 branch와 실제 base branch의 비교
3. 티켓 작업임이 명확한 staged/working-tree diff

티켓 내용을 직접 읽을 수 없으면 사용자가 제공한 내용, branch/commit context, PR/issue context 등 확인 가능한 근거만 사용한다. 요구사항을 추측해서 만들지 않는다.

전체 diff를 먼저 읽은 뒤 위험도가 높은 변경 영역 몇 개만 선정한다. Account 질문을 시작하기 전 결론이나 정답을 개발자에게 노출하지 않는다.

Account 세부 절차는 [references/account.md](references/account.md)를 따른다.

`state.md`에 현재 base, HEAD, phase=`account`, status=`in-progress`를 기록한다.

---

# Phase 1 — Account

목표: 실제 변경에 대해 개발자가 지금 무엇을 자기 말로 설명하고 책임질 수 있는지 확인한다.

이 단계는 assessment다. 교육이나 검증을 하지 않는다.

[references/account.md](references/account.md)의 규칙을 그대로 따른다.

특히 다음을 강제한다.

- 한 번에 질문 하나만 한다.
- 모든 질문을 실제 변경 코드에 연결한다.
- 문법 설명보다 이유, 결과, 가정, 실패 모드, blast radius를 묻는다.
- 답을 대신 설명하지 않는다.
- 코드 실행, 수정, 실험을 요구하지 않는다.
- 다른 AI에게 답을 다시 물어보게 하지 않는다.
- "모르겠다"를 실패가 아닌 gap으로 기록한다.
- 마지막에 blind-spot 질문을 반드시 한다.

완료 후 `01-account.md`를 작성하고 `status: frozen`으로 표시한다.

개발자의 의미 있는 답변은 가능한 한 verbatim으로 보존한다. 문장을 더 똑똑해 보이게 다듬거나 사후 지식으로 보강하지 않는다. 필요한 경우만 명시적인 `...`로 줄인다. secret은 반드시 마스킹한다.

`01-account.md`를 동결한 뒤 `state.md`의 phase를 `verify`로 바꾼다.

---

# Phase 2 — Verify

목표: Account에서 개발자가 말한 중요한 주장과 가정을 실제 repository evidence와 대조한다.

질문을 다음과 같이 전환한다.

```text
Account: 나는 어떻게 동작한다고 생각하는가?
Verify: 무엇이 실제로 그렇게 동작한다고 증명하는가?
```

[references/verify.md](references/verify.md)를 따른다.

검증 대상은 `01-account.md`에서 고른다. 모든 사소한 문장을 검증하지 않는다.

우선순위:

- high-risk 주장
- 확신이 낮았던 주장
- 실패 모드 관련 주장
- 넓은 blast radius를 가진 가정
- 보안/돈/데이터 무결성과 관련된 주장
- "모르겠다"고 답했지만 실제 동작을 확인할 가치가 큰 영역

각 주장을 다음 중 하나로만 분류한다.

- `CONFIRMED`
- `DISPROVED`
- `UNVERIFIED`

`UNVERIFIED`를 허용한다. 증거가 부족할 때 확신을 만들어내지 않는다.

`02-verification.md`에 evidence와 reasoning을 기록한다. `01-account.md`는 절대 수정하지 않는다.

완료 후 `state.md`의 phase를 `learn`으로 바꾼다.

---

# Phase 3 — Learn

목표: Account와 Verify에서 발견한 gap 중 이 변경을 소유하는 데 중요한 것만 학습한다.

[references/learn.md](references/learn.md)를 따른다.

다음을 우선 학습한다.

- `DISPROVED`된 mental model
- 명시적인 "모르겠다" 중 핵심 메커니즘
- high-risk `UNVERIFIED` 영역의 개념적 이해 부족
- 이 티켓의 동작을 설명하는 중심 개념
- 앞으로 반복해서 문제를 만들 가능성이 큰 오해

모든 관련 기술을 공부시키지 않는다.

각 gap마다 다음 순서를 따른다.

1. gap을 명확히 말한다.
2. 실제 repository 코드와 구조를 사용해 메커니즘을 설명한다.
3. 티켓 동작과 연결한다.
4. 의미 있는 실패 모드 또는 trade-off 하나를 설명한다.
5. 개발자에게 자기 말로 teach-back하게 한다.

"이해했어?"만 묻지 않는다.

teach-back에서 중요한 인과관계와 실제 결과를 설명할 수 있을 때만 `learned`로 표시한다. 그렇지 않으면 `unresolved`로 남긴다.

`03-learning.md`를 작성한 뒤 `state.md`의 phase를 `own`으로 바꾼다.

---

# Phase 4 — Own

목표: 이 티켓에 대해 개발자가 현재 소유할 수 있는 mental model과 남은 불확실성을 짧고 재사용 가능한 기록으로 만든다.

다음을 읽는다.

- 티켓 의도
- 실제 diff와 관련 코드
- `01-account.md`
- `02-verification.md`
- `03-learning.md`

[references/own.md](references/own.md)를 따른다.

`04-ownership.md`에는 기본적으로 다음을 기록한다.

- Ticket intent
- Actual system change
- I can account for
- Corrected mental models
- Learned
- Remaining uncertainty
- If this breaks

점수를 만들지 않는다. "완전히 이해함" 같은 포괄적 선언을 하지 않는다. 무엇을 설명할 수 있고 무엇이 아직 불확실한지를 구체적으로 남긴다.

선택적인 pre-flight artifact가 같은 티켓에 존재하면 **이 단계에서만** 읽는다. Account 전에 읽지 않는다. pre-flight와 비교할 때는 `Confirmed / Expanded / Corrected`를 추가하되 원본 pre-flight를 수정하지 않는다.

완료 후 `state.md`를 phase=`complete`, status=`complete`로 갱신한다.

---

# 변경 집합이 달라진 경우

post-flight가 여러 세션에 걸칠 수 있음을 전제로 한다.

재개할 때마다 기록된 HEAD와 현재 change set을 비교한다.

Account가 끝난 뒤 diff가 실질적으로 바뀌었다면:

1. 기존 frozen artifact를 보존한다.
2. 새 HEAD를 기록한다.
3. 새로 추가되거나 변경된 high-risk 영역을 찾는다.
4. 그 영역만 추가 Account한다.
5. 새 답변은 기존 기록을 덮어쓰지 말고 append한다.
6. 새 주장에 대해 Verify → Learn → Own을 이어간다.

과거 답변이 새 코드를 설명한다고 조용히 가정하지 않는다.

---

# 핵심 불변식

다음 규칙을 절대 깨지 않는다.

```text
Account:
정답을 가르치거나 검증하지 않는다.

Verify:
과거 개발자 답변을 다시 쓰지 않는다.

Learn:
teach-back 전에는 gap을 learned로 표시하지 않는다.

Own:
불확실성을 숨기지 않는다.

Always:
과거를 다시 쓰지 않는다.
```

이 Skill의 성공 기준은 질문을 많이 하는 것이 아니다. 중요한 misunderstanding 하나를 정확히 발견하고, evidence로 확인하고, 개발자가 자기 말로 다시 설명할 수 있게 만드는 것을 우선한다.
