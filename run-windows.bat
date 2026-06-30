@echo off
REM 더블클릭하면 로컬 서버를 띄우고 브라우저로 빌더를 엽니다. (Python 필요)
cd /d "%~dp0"
set PORT=8000
start "" "http://localhost:%PORT%/index.html"
echo 서버 실행 중 - 이 창을 닫으면 서버가 종료됩니다. (http://localhost:%PORT%/index.html)
python -m http.server %PORT%
