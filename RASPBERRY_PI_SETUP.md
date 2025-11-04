# 라즈베리파이 약상자 연결 가이드

이 문서는 라즈베리파이를 사용한 약상자 시스템을 설정하고 Flutter 앱과 연결하는 방법을 설명합니다.

## 목차
1. [필수 요구사항](#필수-요구사항)
2. [라즈베리파이 서버 설정](#라즈베리파이-서버-설정)
3. [카메라 스크립트 설정](#카메라-스크립트-설정)
4. [앱 연결 설정](#앱-연결-설정)
5. [실행 방법](#실행-방법)
6. [문제 해결](#문제-해결)

---

## 필수 요구사항

- 라즈베리파이 (카메라 모듈 연결)
- Python 3.13 이상
- 가상환경 (venv)
- 같은 핫스팟/와이파이 네트워크

---

## 라즈베리파이 서버 설정

### 1. 디렉토리 생성 및 파일 생성

```bash
# 서버 디렉토리 생성
mkdir -p ~/pillbox
cd ~/pillbox
```

### 2. 서버 파일 생성

```bash
cat > ~/pillbox/pillbox_server.py <<'PY'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from fastapi import FastAPI, WebSocket, Body
from datetime import datetime, timezone
import asyncio
import collections

app = FastAPI()

# 로그 버퍼 (최대 200개)
ring = collections.deque(maxlen=200)

# 현재 상태
state = {
    "hasMedication": False,
    "battery": None,
    "lastSeen": None
}

def now():
    return datetime.now(timezone.utc).isoformat()

@app.get("/health")
def health():
    return {"ok": True, "ts": now()}

@app.get("/status")
def status():
    return {
        "hasMedication": state["hasMedication"],
        "battery": state["battery"],
        "lastSeen": state["lastSeen"]
    }

@app.get("/logs")
def logs(limit: int = 100):
    return list(ring)[-limit:]

@app.post("/sensor")
def sensor(payload: dict = Body(...)):
    state["hasMedication"] = bool(payload.get("hasMedication", state["hasMedication"]))
    if "battery" in payload and payload["battery"] is not None:
        state["battery"] = int(payload["battery"])
    state["lastSeen"] = now()
    ring.append({
        "ts": state["lastSeen"],
        "hasMedication": state["hasMedication"],
        "note": payload.get("note", "sensor")
    })
    return {"ok": True, "ts": state["lastSeen"]}

@app.websocket("/stream")
async def stream(ws: WebSocket):
    await ws.accept()
    await ws.send_json({"type": "snapshot", "data": status()})
    try:
        while True:
            await asyncio.sleep(30)
            state["lastSeen"] = now()
            await ws.send_json({"type": "status", "data": status()})
    except Exception:
        pass
PY

chmod +x ~/pillbox/pillbox_server.py
```

### 3. 가상환경 설정 및 의존성 설치

```bash
# 가상환경 생성 (시스템 패키지 포함)
python3 -m venv --system-site-packages ~/yak-venv

# 가상환경 활성화
source ~/yak-venv/bin/activate

# pip 업그레이드
python -m pip install --upgrade pip

# 필요한 패키지 설치
python -m pip install fastapi uvicorn[standard]
```

### 4. 서버 실행

```bash
# 가상환경 활성화
source ~/yak-venv/bin/activate

# 서버 디렉토리로 이동
cd ~/pillbox

# 서버 실행 (백그라운드)
nohup python -m uvicorn pillbox_server:app --host 0.0.0.0 --port 8080 > ~/pillbox/uvicorn.log 2>&1 &

# 로그 확인
tail -f ~/pillbox/uvicorn.log
```

### 5. 서버 확인

```bash
# 헬스체크
curl http://127.0.0.1:8080/health

# 상태 확인
curl http://127.0.0.1:8080/status

# 로그 확인
curl "http://127.0.0.1:8080/logs?limit=5"
```

---

## 카메라 스크립트 설정

### 1. 카메라 스크립트 파일 생성

```bash
# 카메라 스크립트 디렉토리 확인
# 예: /home/pty07/Desktop/yak/run_pi_camera.py
# 또는 원하는 위치에 생성

cat > /home/pty07/Desktop/yak/run_pi_camera.py <<'PY'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
import os
import sys
import time
from typing import Optional, Set
import cv2
import numpy as np
import requests

try:
    from picamera2 import Picamera2
    USE_OPENCV_CAMERA = False
except Exception:
    USE_OPENCV_CAMERA = True

from ultralytics import YOLO

# ===================== Config =====================
MODEL_PATH: str = "/home/pty07/Desktop/yak/model/pills.onnx"
IMGSZ: int = 640
CONF_THRES: float = 0.5
NEEDED_STREAK: int = 3
PREVIEW_W: int = 640
PREVIEW_H: int = 480
SHOW_PREVIEW: bool = False  # 헤드리스 환경에서는 False

# 허용 클래스(비우면 전체 허용)
ALLOWED_CLASSES: Set[str] = set()

# 로컬 수신 서버(FastAPI) 주소
PILBOX_API: str = "http://127.0.0.1:8080"
PUSH_PERIOD_SEC: int = 30
REQUEST_TIMEOUT_SEC: int = 3
OPENCV_DEVICE_INDEX: int = 0  # /dev/video0
# ===================================================

def to_bgr3(img: np.ndarray) -> np.ndarray:
    if img.ndim == 3 and img.shape[2] == 4:
        return cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
    return img

def push_status(has_medication: bool, note: str = "camera", battery: Optional[int] = None) -> None:
    try:
        r = requests.post(
            f"{PILBOX_API}/sensor",
            json={"hasMedication": bool(has_medication), "battery": battery, "note": note},
            timeout=REQUEST_TIMEOUT_SEC,
        )
        print(f"[PUSH] hasMedication={has_medication} status={r.status_code}")
    except Exception as e:
        print(f"[PUSH][ERR] {e}")

def load_model(path: str) -> YOLO:
    if not os.path.exists(path):
        print(f"[ERROR] Model not found: {path}")
        sys.exit(1)
    print(f"[INFO] Loading model: {path}")
    return YOLO(path)

def init_camera(width: int, height: int):
    if USE_OPENCV_CAMERA:
        cap = cv2.VideoCapture(OPENCV_DEVICE_INDEX)
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
        if not cap.isOpened():
            print(f"[ERROR] OpenCV camera open failed (index={OPENCV_DEVICE_INDEX})")
            sys.exit(1)
        return cap
    cam = Picamera2()
    cam.configure(cam.create_preview_configuration(main={"size": (width, height)}))
    cam.start()
    time.sleep(0.3)
    return cam

def capture_frame(cam):
    if USE_OPENCV_CAMERA:
        ret, frame = cam.read()
        return frame if ret else None
    return cam.capture_array()

def release_camera(cam):
    try:
        if USE_OPENCV_CAMERA:
            cam.release()
        else:
            cam.stop()
    except Exception:
        pass

def predict_has_medication(model: YOLO, frame_bgr: np.ndarray) -> tuple[bool, Optional[tuple[int,int,int,int]], str]:
    if frame_bgr is None:
        return False, None, ""
    frame_in = cv2.resize(frame_bgr, (IMGSZ, IMGSZ), interpolation=cv2.INTER_LINEAR)
    results_list = model.predict([frame_in]*8, imgsz=IMGSZ, conf=CONF_THRES, verbose=False)
    results = results_list[0]
    detected, box_xyxy, chosen_label = False, None, ""
    if hasattr(results, "boxes") and results.boxes is not None:
        names = getattr(results, "names", {}) or {}
        for box in results.boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            name = names.get(cls, str(cls))
            allow = (not ALLOWED_CLASSES) or (name in ALLOWED_CLASSES)
            if allow and conf >= CONF_THRES:
                detected = True
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                box_xyxy = (x1, y1, x2, y2)
                chosen_label = f"{name} {conf:.2f}"
                break
    return detected, box_xyxy, chosen_label

def main() -> None:
    global OPENCV_DEVICE_INDEX
    try:
        OPENCV_DEVICE_INDEX = int(os.getenv("OPENCV_DEVICE_INDEX", OPENCV_DEVICE_INDEX))
    except Exception:
        pass

    model = load_model(MODEL_PATH)
    cam = init_camera(PREVIEW_W, PREVIEW_H)
    print(f"[INFO] Pill detection started. Press Ctrl+C to quit. (OpenCV={USE_OPENCV_CAMERA})")

    last_push_ts: float = 0.0
    last_state: Optional[bool] = None
    streak: int = 0

    try:
        while True:
            frame = capture_frame(cam)
            frame = to_bgr3(frame)

            try:
                detected, box_xyxy, label = predict_has_medication(model, frame)
            except Exception as e:
                print(f"[PREDICT][ERR] {e}")
                detected, box_xyxy, label = False, None, ""

            streak = streak + 1 if detected else 0
            has_medication: bool = (streak >= NEEDED_STREAK)

            now_ts = time.time()
            if (last_state is None) or (last_state != has_medication) or ((now_ts - last_push_ts) >= PUSH_PERIOD_SEC):
                push_status(has_medication, note="camera")
                last_push_ts = now_ts
                last_state = has_medication

            if SHOW_PREVIEW and frame is not None:
                cv2.imshow("Pill Detection (ONNX)", frame)
                if cv2.waitKey(1) & 0xFF == 27:
                    break

    except KeyboardInterrupt:
        print("\n[INFO] Stopped by user.")
    finally:
        release_camera(cam)
        cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
PY

chmod +x /home/pty07/Desktop/yak/run_pi_camera.py
```

### 2. 카메라 스크립트 의존성 설치

```bash
# 가상환경 활성화
source ~/yak-venv/bin/activate

# 필요한 패키지 설치
python -m pip install ultralytics onnxruntime opencv-python-headless requests

# ONNX 패키지 (자동 설치되지만 필요시)
python -m pip install onnx
```

### 3. 카메라 스크립트 실행

```bash
# 가상환경 활성화
source ~/yak-venv/bin/activate

# 헤드리스 환경에서 실행 (백그라운드)
OPENCV_DEVICE_INDEX=0 QT_QPA_PLATFORM=offscreen \
nohup python /home/pty07/Desktop/yak/run_pi_camera.py > ~/yak-camera.log 2>&1 &

# 로그 확인
tail -f ~/yak-camera.log
```

---

## 앱 연결 설정

### 1. 라즈베리파이 IP 주소 확인

```bash
# 라즈베리파이에서 실행
hostname -I | awk '{print $1}'
# 또는
ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1
```

예: `10.90.81.189`

### 2. 앱 코드 설정

앱의 `lib/shared/services/rpi_pillbox_service.dart` 파일에서 IP 주소를 설정합니다:

```dart
// 라즈베리파이 IP 주소 (같은 핫스팟에서 사용)
static const String _defaultRpiIp = '10.90.81.189';  // 여기에 실제 IP 입력
static const int _defaultPort = 8080;
```

### 3. 앱 실행

앱을 실행하면 자동으로 라즈베리파이 서버에 연결됩니다.

---

## 실행 방법

### 서버와 카메라 스크립트를 백그라운드로 실행

```bash
# 1. 서버 실행
source ~/yak-venv/bin/activate
cd ~/pillbox
nohup python -m uvicorn pillbox_server:app --host 0.0.0.0 --port 8080 > ~/pillbox/uvicorn.log 2>&1 &

# 2. 카메라 스크립트 실행
source ~/yak-venv/bin/activate
OPENCV_DEVICE_INDEX=0 QT_QPA_PLATFORM=offscreen \
nohup python /home/pty07/Desktop/yak/run_pi_camera.py > ~/yak-camera.log 2>&1 &

# 3. 상태 확인
curl http://127.0.0.1:8080/status
curl "http://127.0.0.1:8080/logs?limit=5"
```

### 프로세스 종료

```bash
# 서버 중지
pkill -f "uvicorn.*pillbox_server"

# 카메라 스크립트 중지
pkill -f "/home/pty07/Desktop/yak/run_pi_camera.py"
```

---

## 문제 해결

### 서버가 시작되지 않는 경우

1. 포트가 이미 사용 중인지 확인:
   ```bash
   ss -ltnp | grep :8080
   ```

2. 가상환경이 활성화되었는지 확인:
   ```bash
   which python  # ~/yak-venv/bin/python 이어야 함
   ```

3. 의존성이 설치되었는지 확인:
   ```bash
   source ~/yak-venv/bin/activate
   python -c "import fastapi, uvicorn; print('OK')"
   ```

### 카메라 스크립트가 실행되지 않는 경우

1. 카메라 권한 확인:
   ```bash
   id  # video, render 그룹 포함 여부 확인
   sudo usermod -aG video,render $USER
   sudo reboot  # 재부팅 필요
   ```

2. 카메라 디바이스 확인:
   ```bash
   v4l2-ctl --list-devices
   ```

3. 모델 파일 경로 확인:
   ```bash
   ls -lh /home/pty07/Desktop/yak/model/pills.onnx
   ```

### 앱에서 연결이 안 되는 경우

1. 같은 네트워크에 연결되어 있는지 확인
2. 라즈베리파이 IP 주소가 올바른지 확인
3. 방화벽이 포트 8080을 차단하지 않는지 확인:
   ```bash
   sudo ufw status
   ```

4. 서버가 실행 중인지 확인:
   ```bash
   curl http://127.0.0.1:8080/health
   ```

---

## 자동 시작 설정 (선택사항)

### systemd 서비스로 등록

```bash
# 서버 서비스 파일 생성
sudo nano /etc/systemd/system/pillbox-server.service
```

```ini
[Unit]
Description=Pillbox Server
After=network.target

[Service]
Type=simple
User=pty07
WorkingDirectory=/home/pty07/pillbox
Environment="PATH=/home/pty07/yak-venv/bin"
ExecStart=/home/pty07/yak-venv/bin/python -m uvicorn pillbox_server:app --host 0.0.0.0 --port 8080
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# 카메라 스크립트 서비스 파일 생성
sudo nano /etc/systemd/system/pillbox-camera.service
```

```ini
[Unit]
Description=Pillbox Camera Script
After=network.target

[Service]
Type=simple
User=pty07
WorkingDirectory=/home/pty07/Desktop/yak
Environment="PATH=/home/pty07/yak-venv/bin"
Environment="OPENCV_DEVICE_INDEX=0"
Environment="QT_QPA_PLATFORM=offscreen"
ExecStart=/home/pty07/yak-venv/bin/python /home/pty07/Desktop/yak/run_pi_camera.py
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# 서비스 활성화
sudo systemctl daemon-reload
sudo systemctl enable pillbox-server
sudo systemctl enable pillbox-camera
sudo systemctl start pillbox-server
sudo systemctl start pillbox-camera

# 상태 확인
sudo systemctl status pillbox-server
sudo systemctl status pillbox-camera
```

---

## 참고사항

- **같은 네트워크 필요**: 앱과 라즈베리파이는 같은 핫스팟/와이파이에 연결되어 있어야 합니다.
- **IP 주소 변경**: 라즈베리파이 IP가 변경되면 앱 코드의 `_defaultRpiIp` 값을 업데이트해야 합니다.
- **로그 확인**: 문제 발생 시 로그 파일을 확인하세요:
  - 서버 로그: `~/pillbox/uvicorn.log`
  - 카메라 로그: `~/yak-camera.log`

---

## 요약

1. **서버 설정**: `~/pillbox/pillbox_server.py` 생성 및 실행
2. **카메라 스크립트**: `run_pi_camera.py` 생성 및 실행
3. **앱 설정**: `rpi_pillbox_service.dart`에서 IP 주소 설정
4. **같은 네트워크**: 앱과 라즈베리파이를 같은 핫스팟에 연결
5. **실행**: 서버와 카메라 스크립트를 백그라운드로 실행

모든 설정이 완료되면 앱에서 약상자 상태를 실시간으로 확인할 수 있습니다!

