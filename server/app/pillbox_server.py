#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import asyncio
import collections
from datetime import datetime, timezone
from typing import Any, Deque, Dict, Optional

from fastapi import Body, FastAPI, HTTPException, WebSocket

try:
    import RPi.GPIO as GPIO  # type: ignore
    HAS_GPIO: bool = True
except Exception:
    HAS_GPIO = False


# ================= Servo/GPIO Config =================
SERVO_GPIO_PIN: int = 18  # PWM capable, confirmed
SERVO_PWM_FREQ_HZ: int = 50  # standard 50Hz

# Duty cycle presets for 50Hz: 0.5ms ≈ 2.5%, 1.5ms ≈ 7.5%
DC_0_DEG: float = 2.5
DC_90_DEG: float = 7.5

# Optional fine calibration offset (percent points)
CALIBRATION_OFFSET: float = 0.0


class ServoController:
    def __init__(self, gpio_pin: int, freq_hz: int) -> None:
        self.gpio_pin: int = gpio_pin
        self.freq_hz: int = freq_hz
        self._pwm = None
        self._initialized: bool = False
        if HAS_GPIO:
            GPIO.setmode(GPIO.BCM)
            GPIO.setup(self.gpio_pin, GPIO.OUT)
            self._pwm = GPIO.PWM(self.gpio_pin, self.freq_hz)
            self._pwm.start(0.0)
            self._initialized = True

    def _set_duty_cycle(self, duty: float) -> None:
        if not HAS_GPIO or not self._initialized or self._pwm is None:
            # Dev environment fallback: do nothing
            return
        duty_with_offset: float = max(0.0, min(100.0, duty + CALIBRATION_OFFSET))
        self._pwm.ChangeDutyCycle(duty_with_offset)

    def move_to_0(self) -> None:
        self._set_duty_cycle(DC_0_DEG)

    def move_to_90(self) -> None:
        self._set_duty_cycle(DC_90_DEG)

    def cleanup(self) -> None:
        try:
            if HAS_GPIO and self._initialized and self._pwm is not None:
                self._pwm.ChangeDutyCycle(0.0)
                self._pwm.stop()
                GPIO.cleanup()
        except Exception:
            pass


# ================= App & State =================
app = FastAPI()
ring: Deque[Dict[str, Any]] = collections.deque(maxlen=200)

servo = ServoController(SERVO_GPIO_PIN, SERVO_PWM_FREQ_HZ)

state: Dict[str, Any] = {
    "hasMedication": True,
    "battery": 87,
    "lastSeen": None,
    "isLocked": True,          # start locked by default
    "forcedByExpiry": False,   # app can force lock due to expired meds
}


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


@app.get("/health")
def health() -> Dict[str, Any]:
    return {"ok": True, "ts": now_iso()}


@app.get("/status")
def get_status() -> Dict[str, Any]:
    return {
        "hasMedication": bool(state.get("hasMedication", False)),
        "battery": int(state.get("battery", 0)) if state.get("battery") is not None else None,
        "lastSeen": state.get("lastSeen"),
        "isLocked": bool(state.get("isLocked", False)),
        "forcedByExpiry": bool(state.get("forcedByExpiry", False)),
    }


@app.get("/logs")
def get_logs(limit: int = 100) -> list[Dict[str, Any]]:
    return list(ring)[-limit:]


@app.post("/sensor")
def sensor(payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    state["hasMedication"] = bool(payload.get("hasMedication", state["hasMedication"]))
    if "battery" in payload and payload["battery"] is not None:
        state["battery"] = int(payload["battery"])
    state["lastSeen"] = now_iso()
    ring.append({
        "ts": state["lastSeen"],
        "hasMedication": state["hasMedication"],
        "note": payload.get("note", "sensor"),
    })
    return {"ok": True, "ts": state["lastSeen"]}


# =============== Lock/Unlock APIs ===============

@app.post("/lock")
def lock_box() -> Dict[str, Any]:
    try:
        servo.move_to_90()
        state["isLocked"] = True
        state["lastSeen"] = now_iso()
        ring.append({"ts": state["lastSeen"], "action": "lock", "note": "servo"})
        return {"ok": True, "isLocked": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lock failed: {e}")


@app.post("/unlock")
def unlock_box() -> Dict[str, Any]:
    if bool(state.get("forcedByExpiry", False)):
        # 423 Locked when forced by expiry
        raise HTTPException(status_code=423, detail="Locked due to expired medication")
    try:
        servo.move_to_0()
        state["isLocked"] = False
        state["lastSeen"] = now_iso()
        ring.append({"ts": state["lastSeen"], "action": "unlock", "note": "servo"})
        return {"ok": True, "isLocked": False}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unlock failed: {e}")


@app.get("/lock-status")
def lock_status() -> Dict[str, Any]:
    return {
        "isLocked": bool(state.get("isLocked", False)),
        "forcedByExpiry": bool(state.get("forcedByExpiry", False)),
    }


@app.post("/expiry/force-lock")
def expiry_force_lock(payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    force: bool = bool(payload.get("force", False))
    state["forcedByExpiry"] = force
    if force:
        # Force lock immediately
        servo.move_to_90()
        state["isLocked"] = True
        state["lastSeen"] = now_iso()
        ring.append({"ts": state["lastSeen"], "action": "force-lock", "note": "expiry"})
    else:
        ring.append({"ts": now_iso(), "action": "force-unlock-allowed", "note": "expiry"})
    return {
        "ok": True,
        "isLocked": bool(state.get("isLocked", False)),
        "forcedByExpiry": bool(state.get("forcedByExpiry", False)),
    }


# =============== WebSocket Stream ===============

@app.websocket("/stream")
async def stream(ws: WebSocket) -> None:
    await ws.accept()
    await ws.send_json({"type": "snapshot", "data": get_status()})
    try:
        while True:
            await asyncio.sleep(5)
            state["lastSeen"] = now_iso()
            await ws.send_json({"type": "status", "data": get_status()})
    except Exception:
        pass


# =============== Graceful shutdown ===============

@app.on_event("shutdown")
def on_shutdown() -> None:
    try:
        servo.cleanup()
    except Exception:
        pass


