from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..schemas import AiChatRequest, AiChatResponse, AiFeedbackRequest, AiFeedbackResponse
from ..services.gemini import gemini_client
from ..services.mfds import mfds_client
from .auth import get_current_user_id
from ..db import get_db
from .. import models

router = APIRouter()


def _detect_intent(question: str) -> str:
    q = question.lower()
    if any(k in q for k in ["효능", "효과", "효과는", "효능은", "what does", "for what"]):
        return "efcy"
    if any(k in q for k in ["사용법", "복용법", "어떻게", "방법", "how to", "dosage", "복용", "dose"]):
        return "use"
    if any(k in q for k in ["경고", "주의사항 경고", "warning"]):
        return "atpnWarn"
    if any(k in q for k in ["주의사항", "주의", "caution"]):
        return "atpn"
    if any(k in q for k in ["상호작용", "함께", "같이", "interaction"]):
        return "intrc"
    if any(k in q for k in ["부작용", "이상반응", "side effect", "adverse"]):
        return "side"
    if any(k in q for k in ["보관", "보관법", "storage", "deposit"]):
        return "deposit"
    return "summary"


def _extract_by_intent(item: dict, intent: str) -> tuple[str, str]:
    name = item.get("itemName")
    mapping = {
        "efcy": "efcyQesitm",
        "use": "useMethodQesitm",
        "atpnWarn": "atpnWarnQesitm",
        "atpn": "atpnQesitm",
        "intrc": "intrcQesitm",
        "side": "seQesitm",
        "deposit": "depositMethodQesitm",
    }
    key = mapping.get(intent)
    if key and item.get(key):
        return name, item.get(key)
    lines = []
    for k in ["efcyQesitm","useMethodQesitm","atpnWarnQesitm","atpnQesitm","intrcQesitm","seQesitm","depositMethodQesitm"]:
        v = item.get(k)
        if v:
            label = {
                "efcyQesitm": "효능",
                "useMethodQesitm": "사용법",
                "atpnWarnQesitm": "경고",
                "atpnQesitm": "주의사항",
                "intrcQesitm": "상호작용",
                "seQesitm": "부작용",
                "depositMethodQesitm": "보관법",
            }[k]
            lines.append(f"{label}: {v}")
    return name, " | ".join(lines)


def _format_template(product_name: str | None, intent: str, content: str) -> str:
    # 단일 라인 템플릿, 개행/마크다운 금지
    intent_map = {
        "efcy": "효능",
        "use": "사용법",
        "atpnWarn": "경고",
        "atpn": "주의사항",
        "intrc": "상호작용",
        "side": "부작용",
        "deposit": "보관법",
        "summary": "요약",
    }
    name_part = f"약 이름: {product_name}" if product_name else "약 이름: 미상"
    intent_part = f"질문 의도: {intent_map.get(intent, intent)}"
    # 본문에서 줄바꿈 제거
    body = " ".join([s.strip() for s in content.splitlines() if s.strip()])
    body = body[:800]
    desc_part = f"핵심 정보: {body}" if body else "핵심 정보: 제공 불가"
    disclaimer = "안내: 개인 상태에 따라 다를 수 있으니 이상 시 복용 중단 및 상담 권장"
    return f"{name_part} | {intent_part} | {desc_part} | {disclaimer}"


@router.post("/chat", response_model=AiChatResponse)
async def chat(req: AiChatRequest, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    user = db.query(models.User).get(user_id)
    user_context = f"사용자정보: 나이={getattr(user,'age',None)}, 성별={getattr(user,'gender',None)}"

    question = req.message.strip()
    intent = _detect_intent(question)
    item_name = question

    data = await mfds_client.search(item_name=item_name, num_of_rows=3)
    body = data.get("body") or data.get("response", {}).get("body")
    items = (body or {}).get("items") or []

    if items:
        name, answer = _extract_by_intent(items[0], intent)
        reply = _format_template(name, intent, answer or "")
        return AiChatResponse(reply=reply)

    prompt = (
        "아래 사용자 문맥과 질문을 참고하여 자세하게게 답하세요."
        " 출력 형식: <제품명> | 핵심 정보: <내용 4줄 정도로 작성하며, 나이, 성별 정보 참고 바람> | 안내: 자세한 정보는 전문의와 상담 권장"
        " 금지: 마크다운, 별표, 줄바꿈, 목록"
        f" 사용자 문맥: {user_context}"
        f" 질문: {question}"
    )
    reply = gemini_client.chat(prompt)
    return AiChatResponse(reply=reply)


@router.post("/feedback", response_model=AiFeedbackResponse)
async def feedback(req: AiFeedbackRequest, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    user = db.query(models.User).get(user_id)
    user_context = f"사용자정보: 나이={getattr(user,'age',None)}, 성별={getattr(user,'gender',None)}"

    item_name = req.itemName or req.context or ""
    entp_name = req.entpName
    question = req.question or "이 약에 대해 알려줘"
    intent = _detect_intent(question)

    data = await mfds_client.search(item_name=item_name, entp_name=entp_name, num_of_rows=3)
    body = data.get("body") or data.get("response", {}).get("body")
    items = (body or {}).get("items") or []

    if items:
        name, answer = _extract_by_intent(items[0], intent)
        pretty = (answer or "").strip()
        header = f"[{name}] {intent} 안내"
        return AiFeedbackResponse(
            product_name=name,
            answer_type=intent,
            answer=f"{header}\n{pretty}",
            source="mfds",
        )

    prompt = f"다음 사용자 문맥을 참고하여 약 정보 질문에 답하세요. 사용자 문맥: {user_context} 질문: {question} 제품명: {item_name}"
    fallback = gemini_client.feedback(prompt)
    return AiFeedbackResponse(
        product_name=item_name or None,
        answer_type=intent,
        answer=fallback,
        source="gemini",
    )
