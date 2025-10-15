import httpx
import xmltodict
from typing import Any, Dict, List, Optional
from urllib.parse import unquote

from ..config import settings


BASE_URL = "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList"


class MfdsClient:
    def __init__(self, service_key: Optional[str]):
        # 키가 % 로 인코딩되어 들어온 경우 한 번 디코딩
        if service_key and "%" in service_key:
            try:
                service_key = unquote(service_key)
            except Exception:
                pass
        self.service_key = service_key

    async def search(self, *, item_name: Optional[str] = None, entp_name: Optional[str] = None, page_no: int = 1, num_of_rows: int = 3, response_type: str = "xml") -> Dict[str, Any]:
        if not self.service_key:
            return {"error": "MFDS service key not configured"}

        params = {
            "serviceKey": self.service_key,
            "pageNo": page_no,
            "numOfRows": num_of_rows,
            "type": response_type,
        }
        if item_name:
            params["itemName"] = item_name
        if entp_name:
            params["entpName"] = entp_name

        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(BASE_URL, params=params)
            resp.raise_for_status()
            # 시도 1: JSON 파싱
            try:
                return resp.json()
            except Exception:
                pass
            # 시도 2: XML 파싱 후 JSON과 유사 구조로 변환
            try:
                parsed = xmltodict.parse(resp.text)
                response = parsed.get("response", parsed)
                body = response.get("body", {})
                items = body.get("items", {})
                if isinstance(items, dict):
                    item_list = items.get("item") or []
                    if isinstance(item_list, dict):
                        item_list = [item_list]
                elif isinstance(items, list):
                    item_list = items
                else:
                    item_list = []
                return {"response": {"body": {"items": item_list}}}
            except Exception:
                return {"error": "Unable to parse MFDS response"}

    async def search_with_raw(self, *, item_name: Optional[str] = None, entp_name: Optional[str] = None, page_no: int = 1, num_of_rows: int = 3, response_type: str = "xml") -> Dict[str, Any]:
        if not self.service_key:
            return {"error": "MFDS service key not configured"}
        params = {
            "serviceKey": self.service_key,
            "pageNo": page_no,
            "numOfRows": num_of_rows,
            "type": response_type,
        }
        if item_name:
            params["itemName"] = item_name
        if entp_name:
            params["entpName"] = entp_name
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(BASE_URL, params=params)
            result: Dict[str, Any] = {
                "status_code": resp.status_code,
                "content_type": resp.headers.get("content-type"),
                "url": str(resp.request.url),
                "raw": resp.text,
            }
            try:
                result["parsed"] = resp.json()
                return result
            except Exception:
                pass
            try:
                parsed = xmltodict.parse(resp.text)
                result["parsed"] = parsed
                return result
            except Exception:
                result["parsed"] = None
                return result

    @staticmethod
    def build_feedback_from_response(json_data: Dict[str, Any]) -> str:
        try:
            body = json_data.get("body") or json_data.get("response", {}).get("body")
            if not body:
                return "관련 의약품 정보를 찾지 못했습니다."
            items = body.get("items") or []
            if not items:
                return "관련 의약품 정보를 찾지 못했습니다."
            lines: List[str] = []
            for it in items[:3]:
                name = it.get("itemName")
                efcy = it.get("efcyQesitm")
                use = it.get("useMethodQesitm")
                warn = it.get("atpnWarnQesitm")
                atpn = it.get("atpnQesitm")
                intrc = it.get("intrcQesitm")
                side = it.get("seQesitm")
                depo = it.get("depositMethodQesitm")
                lines.append(f"제품명: {name}\n- 효능: {efcy}\n- 사용법: {use}\n- 경고: {warn}\n- 주의사항: {atpn}\n- 상호작용: {intrc}\n- 부작용: {side}\n- 보관법: {depo}")
            return "\n\n".join(lines)
        except Exception:
            return "의약품 정보를 해석하는 중 오류가 발생했습니다."


mfds_client = MfdsClient(settings.mfds_service_key)
