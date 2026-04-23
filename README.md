# tt — tmux session manager

키보드 기반의 경량 tmux 세션 관리 TUI 스크립트.

## 요구사항

- bash 4.0+
- tmux

## 설치

```bash
git clone https://github.com/yourname/tt-manager.git
cd tt-manager
chmod +x tt.sh
```

전역에서 사용하려면:

```bash
sudo ln -s "$(pwd)/tt.sh" /usr/local/bin/tt
```

또는 `~/.bashrc` / `~/.zshrc`에 alias 추가:

```bash
alias tt='/path/to/tt.sh'
```

## 실행

```bash
./tt.sh
# 또는
tt
```

## 화면 구성

```
╔══════════════════════════════════╗
║  tmux sessions                   ║
╠══════════════════════════════════╣
║  1) dev            (2 windows)   ║
║  2) server         (1 window)    ║
║  3) logs           (3 windows)   ║
╠══════════════════════════════════╣
║  n) new session                  ║
║  q) quit                         ║
╚══════════════════════════════════╝

Select:
```

## 키 조작

### 메인 화면

| 키 | 동작 |
|----|------|
| `1`~`9` | 해당 번호의 세션 선택 |
| `n` | 새 세션 만들기 |
| `q` | 종료 |

### 세션 액션 메뉴

| 키 | 동작 |
|----|------|
| `a` | 세션에 attach (접속) |
| `k` | 세션 종료 (kill) |
| `r` | 세션 이름 변경 (rename) |
| `b` | 뒤로 가기 |

## 기능

- **세션 목록 표시** — 이름, 윈도우 수 함께 표시
- **attach / switch** — tmux 외부면 attach, 내부면 switch-client
- **세션 생성** — 이미 존재하는 이름 입력 시 attach 여부 확인
- **세션 종료** — 삭제 전 확인 프롬프트
- **세션 이름 변경** — 중복 이름 체크
- **마우스 자동 활성화** — `~/.tmux.conf`에 `set -g mouse on` 자동 추가

## 동작 방식

tmux 내부(`$TMUX` 환경변수 존재)에서 실행 시:
- 새 세션 생성 → `new-session -d` + `switch-client`
- 세션 선택 → `switch-client`

tmux 외부에서 실행 시:
- 새 세션 생성 → `new-session` (바로 진입)
- 세션 선택 → `attach-session`

## 파일 구조

```
tt-manager/
└── tt.sh        # 메인 스크립트
```
