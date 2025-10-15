from typing import Optional

import google.generativeai as genai

from ..config import settings


class GeminiClient:
    def __init__(self):
        if not settings.gemini_api_key:
            self.enabled = False
            return
        genai.configure(api_key=settings.gemini_api_key)
        self.enabled = True
        self.model = genai.GenerativeModel("gemini-2.0-flash")

    def chat(self, message: str) -> str:
        if not self.enabled:
            return "Gemini API key not configured."
        resp = self.model.generate_content(message)
        return resp.text or ""

    def feedback(self, context: str) -> str:
        if not self.enabled:
            return "Gemini API key not configured."
        prompt = f"다음 복약/건강 정보를 바탕으로 간단한 피드백을 주세요:\n{context}"
        resp = self.model.generate_content(prompt)
        return resp.text or ""


gemini_client = GeminiClient()
