#!/bin/bash
# 로컬 서버를 띄우고 브라우저로 빌더를 엽니다. (Python 3 필요)
cd "$(dirname "$0")"
PORT=8000
python3 -m http.server $PORT >/dev/null 2>&1 &
SRV=$!
sleep 1
xdg-open "http://localhost:$PORT/index.html" 2>/dev/null
echo "서버 실행 중 — Ctrl+C 로 종료. (http://localhost:$PORT/index.html)"
trap "kill $SRV 2>/dev/null" EXIT
wait $SRV
