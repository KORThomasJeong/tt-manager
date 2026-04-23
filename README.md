# 🖥️ tt-manager

> 키보드 중심의 경량 tmux 세션 관리 TUI 스크립트입니다.  
> 세션 목록 조회·생성·접속·종료·이름 변경을 단일 Bash 스크립트로 처리합니다.

---

## 🚀 빠른 설치

```bash
curl -fsSL https://raw.githubusercontent.com/KORThomasJeong/tt-manager/main/install.sh | bash
```

> `~/.local/bin/tt`에 설치됩니다. tmux가 없으면 설치 안내를 표시합니다.

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| **세션 목록** | 실행 중인 tmux 세션 이름과 윈도우 수를 박스 UI로 표시 |
| **자동 attach / switch** | tmux 외부면 `attach-session`, 내부면 `switch-client` 자동 선택 |
| **세션 생성** | 이름 중복 시 attach 여부 확인, tmux 내부 생성 시 즉시 전환 |
| **세션 종료** | 삭제 전 확인 프롬프트로 실수 방지 |
| **이름 변경** | 중복 이름 체크 후 변경 |
| **마우스 자동 활성화** | `~/.tmux.conf`에 `set -g mouse on` 자동 추가 |

---

## 🖥️ 화면 구성

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
```

세션 번호를 누르면 액션 메뉴로 진입합니다.

```
  Session: dev
  a) attach   k) kill   r) rename   b) back
```

---

## ⌨️ 키 조작

### 메인 화면

| 키 | 동작 |
|----|------|
| `1`~`9` | 세션 선택 |
| `n` | 새 세션 만들기 |
| `q` | 종료 |

### 세션 액션 메뉴

| 키 | 동작 |
|----|------|
| `a` | 세션 attach (접속) |
| `k` | 세션 kill (종료) |
| `r` | 세션 rename (이름 변경) |
| `b` | 뒤로 가기 |

---

## 📦 수동 설치

```bash
# 클론 후 설치
git clone https://github.com/KORThomasJeong/tt-manager.git
cd tt-manager
chmod +x tt.sh

# 전역 설치 (선택)
sudo ln -s "$(pwd)/tt.sh" /usr/local/bin/tt

# 또는 alias 추가 (~/.bashrc / ~/.zshrc)
alias tt='/path/to/tt.sh'
```

---

## 🔧 요구사항

- bash 4.0+
- tmux
