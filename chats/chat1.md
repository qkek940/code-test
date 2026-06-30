# MSDS 양식 프롬프트 빌더

_Started 2026-06-30 02:06 UTC_

---

## User

# Claude Design 빌드 프롬프트 — MSDS 양식 프롬프트 빌더 대시보드

아래 명세대로 **단일 HTML 파일**(인라인 CSS·JS 포함, 외부 라이브러리 없음)로 인터랙티브 대시보드를 만들어줘. 이 대시보드의 목적은 사용자가 입력한 값과 첨부한 MSDS 문서를 바탕으로, MSDS를 "작업공정별 관리요령" 또는 "물질경고표지" 양식으로 변환하는 **Claude용 프롬프트를 생성·복사**하게 하는 것이다.

---

## 1. 디자인 토큰 (그대로 사용)

색상 변수:
- `--ink:#16181d` (기본 텍스트)
- `--ink-soft:#4a4f5a` (보조 텍스트)
- `--line:#d6d3c9` (테두리)
- `--line-strong:#2b2d33` (강조 테두리·버튼)
- `--paper:#f6f4ec` (페이지 배경)
- `--card:#ffffff` (카드 배경)
- `--hazard:#c8102e` (위험 빨강 — GHS 마름모, 강조)
- `--hazard-bg:#fbe9ec` (선택된 칩 배경)
- `--accent:#1d4ed8` (입력 포커스, 채워진 값)
- `--ok:#15803d` (복사 완료)

폰트:
- 본문 `--sans`: `-apple-system, BlinkMacSystemFont, 'Malgun Gothic', 'Apple SD Gothic Neo', 'Segoe UI', sans-serif`
- 코드/프롬프트 `--mono`: `'SFMono-Regular', ui-monospace, 'Menlo', 'Consolas', monospace`

전반 스타일: 산업안전 도구다운 절제된 느낌. border-radius는 작게(2~5px), 그림자 거의 없음, 종이 질감의 따뜻한 배경(`--paper`)에 흰 카드. 강조색은 GHS 빨강 하나만 절제해서 사용.

---

## 2. 레이아웃

최대 폭 1280px 중앙 정렬, 좌우 패딩 24px.

**헤더(상단):** 왼쪽에 45도 회전한 빨간 테두리 마름모 안에 느낌표(GHS 감탄부호 모티프) + 제목 "MSDS 양식 프롬프트 빌더"와 회색 모노 부제. 오른쪽에 모노 폰트 버전 태그(선택한 양식에 따라 `FORM v2.0 · 산안법 §114` 또는 `§110`로 바뀜). 아래에 굵은 구분선(`--line-strong` 2px).

**양식 선택 토글:** 헤더 아래에 알약형 세그먼트 컨트롤. 버튼 2개 — "작업공정별 관리요령" / "물질경고표지". 각 버튼 앞에 작은 마름모 아이콘. 선택된 버튼은 `--line-strong` 배경에 흰 글씨, 마름모 불투명도 1. 선택에 따라 입력 항목·미리보기·프롬프트가 모두 전환된다.

**2열 그리드(좌우):** 좌측 입력 패널, 우측 미리보기 패널. 각 패널은 흰 카드 + `--line` 테두리, 상단에 번호 배지(①②)가 붙은 헤더 바. 920px 이하에서 1열로 스택.

**하단:** 전체 폭으로 "생성된 프롬프트" 영역 + 복사 버튼 + 다크 코드블록 + 사용법 노트.

---

## 3. 좌측 입력 패널 (번호 ①)

맨 위부터 순서대로:

**(a) MSDS 문서 업로드** — 점선 테두리 드롭존. "파일을 끌어다 놓거나 클릭해서 선택", 지원 형식 표기 `.pdf · .xlsx · .xls · .docx · .doc · .pptx · .ppt`. 클릭/드래그&드롭 모두 지원, 다중 파일 허용. 업로드된 파일은 목록으로 표시하되 각 항목에 **확장자 색상 태그**(pdf=빨강 #b3261e, xls=초록 #15803d, doc=파랑 #1d4ed8, ppt=주황 #c2410c), 파일명, × 삭제 버튼. 지원하지 않는 확장자·중복 파일은 자동 제외. 목록 아래 안내문: "업로드한 파일은 프롬프트에 **파일명으로 기록**됩니다. 실제 내용 추출은 이 프롬프트와 **같은 파일을 Claude Design 대화창에 함께 첨부**해야 이뤄집니다." (브라우저에서 파일 내용을 파싱하지 말 것 — 파일명만 사용.)

**(b) 공통 입력**
- 물질명 (필수, 빨간 * 표시)
- 제품명 (선택, 직접 입력 — 안내: "물질명 옆에 괄호로 표기. 비우면 괄호 생략")
- 함유량 (※ **경고표지 모드에서만 표시**)
- CAS No. (주성분)
- 신호어 (드롭다운: 위험 / 경고)
- GHS 그림문자 (체크 가능한 칩 9종: 인화성, 산화성, 폭발성, 고압가스, 부식성, 급성독성, 감탄부호, 건강유해성, 환경유해성). 각 칩 앞에 빨간 마름모. 선택 시 `--hazard-bg` 배경 + 빨간 테두리. 안내: "비워두면 H분류 기준으로 자동 선택됩니다."

**(c) 양식별 전용 입력 — 선택한 양식에 맞는 것만 보이게**
- 경고표지 모드: `유해·위험 문구(H문구)` textarea, `예방조치 문구(P문구·대표 항목)` textarea
- 관리요령 모드: `유해성·위험성(2항)`, `취급상의 주의사항(7항)`, `적절한 보호구(8항)`, `응급조치요령(4항)`, `사고 시 대처방법(6항·누출)` textarea 5개

**(d) 공통 입력 (맨 아래)**
- 공급자 정보 (1항) textarea

입력란은 포커스 시 `--accent` 테두리 + 옅은 파란 글로우. 모든 입력은 변경 즉시 미리보기와 프롬프트에 반영(이벤트 리스너).

---

## 4. 우측 미리보기 패널 (번호 ②)

회색 받침(`#e9e6dd`) 위에 흰 A4 세로 비율 양식 시트를 올려 실제 출력물을 축소 모사. 선택한 양식 하나만 표시(전환 시 다른 시트는 숨김).

**관리요령 시트:** 최상단 가운데 정렬 법적 문구 "( 산업안전보건법 제114조에 따른 작업공정별 관리요령 )" → 검은 테두리 이름 박스(슬라이드 **정중앙**, 박스 안 텍스트도 가운데 정렬, 물질명+(제품명)/CAS 2줄) → 좌측 항목명·우측 내용의 2열 표(경고구분[신호어+그림문자 마름모], 유해성·위험성, 취급상의 주의사항, 적절한 보호구, 응급조치요령, 사고 시 대처방법, 공급자 정보) → 하단 "※ 기타 자세한 내용은 물질안전보건자료(MSDS) 참조".

**경고표지 시트:** 최상단 박스형 법적 문구 "[ 산업안전보건법 제110조 및 화학물질관리법 제16조에 의한 분류 ]" → 물질명+(제품명) 크게 가운데 정렬 → "( CAS No. : … , 함유량 : … )" → GHS 그림문자 마름모 가운데 나열 → 신호어 우측 크게 → 2행 표(유해·위험 문구 / 예방조치 문구) → 하단 공급자 정보.

**중요:** 물질명+(제품명)은 두 양식 모두 **항상 가운데 정렬**. 입력이 없는 항목은 빨간 이탤릭 플레이스홀더(예: "MSDS에서 추출", "물질명 (제품명)")로 표시. 그림문자를 선택하지 않으면 "자동선택" / "H분류 기준 자동선택" 표시.

---

## 5. 하단 — 생성되는 프롬프트

다크 코드블록(`#1c1e24` 배경, 모노 폰트, 줄바꿈 보존). 입력값에 따라 실시간 생성. **채워진 값은 파란색(`--accent` 계열 #7fb4ff), MSDS에서 추출할 빈 항목은 회색 이탤릭(#6b7280)** 으로 시각적 구분(화면 표시용 색상일 뿐, 복사 시에는 순수 텍스트만 나가야 함 — `innerText` 사용).

우상단 "프롬프트 복사" 버튼: 클릭 시 클립보드 복사 후 1.6초간 "복사됨 ✓"으로 바뀌고 배경이 `--ok` 초록으로.

### 생성할 프롬프트 본문 (관리요령 모드)

```
당신은 MSDS(물질안전보건자료) PDF를 입력받아 "작업공정별 관리요령" 양식을
이미지(JPG)로 생성하는 도구입니다. 업로드된 MSDS PDF는 항상 최신본으로 간주합니다.

첨부 MSDS 문서: [업로드한 파일명 / 없으면 "이 프롬프트와 함께 MSDS 파일을 첨부하세요"]
   └ 위 파일을 이 대화에 함께 첨부했는지 확인하고, 그 내용을 기준으로 작성한다.

[양식 — 세로형 A4, 1페이지, 검은 테두리 표]

1. 최상단(가운데 정렬): ( 산업안전보건법 제114조에 따른 작업공정별 관리요령 )
2. 이름 박스: 슬라이드 정중앙에 배치한다.
   - 박스의 좌우 여백이 동일해야 하며, 박스 안 텍스트도 가운데 정렬한다.
   - 물질명(과 제품명)은 어떤 경우에도 가운데 정렬을 유지한다.
   1행 물질명(제품명): [물질명 (제품명) / 제품명 없으면 괄호 생략]
   2행 CAS No. : [주성분 CAS]
3. 좌측 항목명 / 우측 내용의 2열 표 (순서·매핑 고정):
   ● 경고 구분 — 신호어 : [위험|경고] / 그림문자: [선택값 또는 H분류 자동선택]
     └ 신호어 텍스트와 그림문자가 겹치지 않도록 그림문자는 같은 행 오른쪽 빈 공간에 나열.
   ● 유해성·위험성(2항) ● 취급상의 주의사항(7항) ● 적절한 보호구(8항)
   ● 응급조치요령(4항·눈/피부/흡입/먹었을 때) ● 사고 시 대처방법(6항·누출) ● 공급자 정보(1항)
4. 최하단: ※ 기타 자세한 내용은 물질안전보건자료(MSDS) 참조

[규칙]
- GHS 표준 그림문자(빨간 마름모·흰 바탕·검은 심볼)를 H분류에 맞춰 사용.
- H/P 코드는 코드와 옆 설명 문구를 함께 대조하고 표준 코드와 한 번 더 확인해 OCR 오류를 잡는다.
  표준에 없는 코드는 사용자에게 알린다.
- 값이 주어진 항목은 그대로 쓰고, [대괄호] 항목만 MSDS에서 추출한다.
- MSDS에 없는 내용은 임의로 채우지 않는다. 빈 항목은 "해당 자료 없음" 또는 "MSDS 참조"로 둔다.
- 결과는 이미지(JPG)로 출력하고, 사람이 검토·승인할 항목(P문구 선정, 법조문 표기)을 함께 안내한다.
```

### 생성할 프롬프트 본문 (경고표지 모드)

```
당신은 MSDS(물질안전보건자료) PDF를 입력받아 "물질경고표지(GHS)" 양식을
이미지(JPG)로 생성하는 도구입니다. 업로드된 MSDS PDF는 항상 최신본으로 간주합니다.

첨부 MSDS 문서: [업로드한 파일명 / 없으면 안내문]
   └ 위 파일을 이 대화에 함께 첨부했는지 확인하고, 그 내용을 기준으로 작성한다.

[양식 — 세로형 A4, 1페이지, 검은 테두리]

1. 최상단(가운데 정렬, 박스): [ 산업안전보건법 제110조 및 화학물질관리법 제16조에 의한 분류 ]
2. 물질명 영역: 슬라이드 정중앙, 가운데 정렬로 크게 표기.
   - 물질명(과 제품명)은 어떤 경우에도 가운데 정렬을 유지한다.
   물질명(제품명): [물질명 (제품명) / 제품명 없으면 괄호 생략]
   ( CAS No. : [주성분 CAS] , 함유량 : [함유량] )
3. GHS 그림문자(가운데 정렬로 나열): [선택값 또는 H분류 자동선택]
4. 신호어(우측, 큰 글씨): [위험|경고]
5. 2행 표: ● 유해·위험 문구(H문구) ● 예방조치 문구(P문구)
6. 최하단: ※ 공급자 정보 [회사명·주소·연락처·긴급연락처]

[규칙]
- GHS 표준 그림문자를 H분류에 맞춰 자동 선택·배치.
- P문구가 많으면 대표 항목만 표지에 넣고 "※ 이외 예방조치 문구는 MSDS를 참조하시오"로 마무리.
- 값이 주어진 항목은 그대로 쓰고, [대괄호] 항목만 MSDS에서 추출.
- MSDS에 없는 내용은 임의로 채우지 않는다.
- 결과는 이미지(JPG)로 출력하고, 사람이 검토·승인할 항목을 함께 안내한다.
```

(각 양식에서 사용자가 채운 입력값은 위 [대괄호] 자리에 그대로 들어가고, 비운 항목만 "MSDS …항에서 추출" 형태의 회색 안내로 남는다.)

---

## 6. 하단 사용법 노트

"상단에서 양식을 고르고 입력란을 채운 뒤 **프롬프트 복사**를 눌러 Claude Design 대화창에 붙여 넣고, MSDS 파일을 함께 첨부하세요. 값을 비운 항목은 'MSDS에서 추출'하라는 지시로 대체되며, 없는 내용은 임의로 채우지 않습니다."

---

## 7. 품질 기준

- 반응형(모바일 1열), 키보드 포커스 가시성, 과한 애니메이션 없음.
- 외부 폰트/라이브러리/이미지 없이 순수 HTML+CSS+JS 단일 파일.
- localStorage 등 브라우저 저장소 사용 금지(메모리 상태만).
- 양식 전환 시 한 번에 한 양식만 보이고, 입력·미리보기·프롬프트·버전태그가 모두 동기화될 것.

## Assistant

I'll build this as a single Design Component. The spec is fully detailed, so I'll go straight to building.

_[tool: update_todos]_

_[tool: dc_write]_

_[tool: show_html]_

_[tool: show_html]_

The layout renders correctly. The toggle button text is wrapping awkwardly — let me prevent that and check the rest.

_[tool: str_replace_edit]_

_[tool: multi_screenshot]_

Prompt generation and chips work great. Let me confirm the preview sheet renders.

_[tool: save_screenshot]_

_[tool: save_screenshot]_

The preview sheet renders exactly to spec — centered name box, signal word + GHS diamonds, red-italic extraction placeholders for empty fields. Everything is wired and synchronized. Cleaning up the temp screenshot and handing off.

_[tool: delete_file]_

_[tool: update_todos]_

MSDS 양식 프롬프트 빌더 대시보드를 완성했습니다.

_[tool: ready_for_verification]_

명세대로 완성했습니다. 주요 동작:

- **양식 토글** — 작업공정별 관리요령 / 물질경고표지 전환 시 입력 항목·미리보기·프롬프트·버전태그(§114/§110)가 모두 동기화됩니다.
- **파일 업로드** — 드래그&드롭/클릭, 확장자 색상 태그, 미지원·중복 자동 제외. 파일명만 사용(내용 파싱 없음).
- **실시간 미리보기** — A4 시트로 출력물 모사, 물질명(제품명) 항상 가운데 정렬, 빈 항목은 빨간 이탤릭 플레이스홀더.
- **프롬프트** — 채운 값은 파란색, 추출 대상은 회색 이탤릭으로 구분되며 복사 시엔 순수 텍스트만 나갑니다.

localStorage 미사용, 외부 라이브러리/폰트 없음입니다.

## User

파일 업로드 및 정보 입력 후 업로드한 파일을 읽어와서 데이터를 추출하는 작업을 시작할 수 있도록 우측 상단에 버튼 필요.

## Assistant

우측 상단에 "데이터 추출 시작" 기본 액션 버튼을 추가하겠습니다. 파일 업로드 + 물질명 입력이 완료되면 활성화되고, 클릭 시 프롬프트를 복사한 뒤 추출 진행 절차 안내를 띄우는 흐름으로 구성합니다.

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

Now the header button and the confirmation banner in the template.

_[tool: dc_html_str_replace]_

_[tool: save_screenshot]_

_[tool: eval_js]_

_[tool: grep]_

The file is correct — the preview just needs a reload to pick up the structural change.

_[tool: show_html]_

The button now shows in the top-right, disabled (grayed) since no file/물질명 yet. Let me verify the active state and banner by populating, then hand off.

_[tool: save_screenshot]_

Works as intended. Cleaning up and handing off.

_[tool: delete_file]_

우측 상단에 **"데이터 추출 시작 →"** 버튼을 추가했습니다.

- MSDS 파일 업로드 + 물질명 입력이 모두 완료되면 빨간색으로 활성화됩니다(미충족 시 회색·비활성, 호버 시 안내 문구).
- 클릭하면 프롬프트가 복사되고, 헤더 아래에 초록 안내 배너가 떠 추출 진행 절차(① 대화창 열기 → ② 붙여넣기 → ③ 파일 N개 첨부 → ④ 전송)와 첨부 대상 파일명을 보여줍니다. × 로 닫을 수 있습니다.

브라우저에서 파일 내용을 직접 파싱할 수는 없어, 실제 추출은 복사된 프롬프트와 파일을 Claude Design 대화창에 함께 넣을 때 수행되는 기존 흐름을 그대로 따릅니다. 버튼은 그 작업을 한 번에 시작하는 진입점 역할을 합니다.

## User

일부 수정.
물질명은 필수 항목에서 제외. MSDS에서 추출하는 것으로.
제품명은 그대로 선택. 미입력시 괄호를 포함해서 아무것도 출력하지 않고, 입력하면 입력한 내용을 괄호와 함께 출력.

## Assistant

세 가지를 수정하겠습니다: 물질명 필수 해제(미입력 시 MSDS 추출), 제품명 미입력 시 괄호까지 생략, 입력 시 괄호와 함께 출력.

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

Now the template: substance spans, the 물질명 label, and the header hint.

_[tool: dc_html_str_replace]_

_[tool: dc_html_str_replace]_

_[tool: dc_html_str_replace]_

_[tool: dc_html_str_replace]_

The structural span change needs a reload to render. Let me reload and verify the empty-name + product-only behavior.

_[tool: show_html]_

_[tool: save_screenshot]_

Correct — empty 물질명 shows the red italic "MSDS에서 추출" placeholder, and the product renders as "(신너 A)" in black only when entered. Cleaning up.

_[tool: delete_file]_

세 가지 모두 반영했습니다.

- **물질명**: 필수 해제. 비우면 미리보기·프롬프트 모두 "MSDS에서 추출"로 표시되고, 추출 시작 버튼도 파일만 있으면 활성화됩니다.
- **제품명**: 선택 유지. 미입력 시 괄호까지 전부 생략, 입력 시 `(입력값)` 형태로 괄호와 함께 출력됩니다.

## User

'데이터 추출 시작'의 버튼 기능 수정 필요. 해당 버튼을 누르면 유첨된 MSDS 파일을 읽어 빈 칸의 내용을 채워야 한다.

## Assistant

_[tool: read_skill_prompt]_

