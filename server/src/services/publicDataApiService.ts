import qs from "querystring";

type DrugValidityItem = {
  ITEM_NO?: string; // 허가번호
  ETC_OTC_CODE_NAME?: string;
  CLASS_NO_NAME?: string;
  PERMIT_KIND_CODE_NAME?: string;
  ENTP_NAME?: string; // 업체명
  ITEM_NAME?: string; // 제품명
  ITEM_PERMIT_DATE?: string; // 허가일
  VALID_TERM_DATE?: string; // 품목유효기간 (원문)
  VALID_TERM_DATE_CUTLINE?: string; // 갱신신청기한 (원문)
  INDUTY_CODE_NAME?: string;
  INDUTY_CODE?: string;
  ITEM_SEQ?: string; // 품목기준코드
  BIZRNO?: string;
};

type DrugValidityResponse = {
  header?: { resultCode?: string; resultMsg?: string };
  body?: {
    numOfRows?: number;
    pageNo?: number;
    totalCount?: number;
    items?: { item?: DrugValidityItem[] | DrugValidityItem };
  };
};

const BASE_URL =
  "https://apis.data.go.kr/1471000/DrugPrdlstVldPrdInfoService01";
// 운영 환경에선 환경변수로 주입
const SERVICE_KEY =
  process.env.EAPIYAK_SERVICE_KEY ||
  process.env.PUBLIC_DATA_API_KEY_DECODED ||
  "CgA5Gg6+IBegRO7e6yDm+e9lqRF1q4js0MPufNUGfQrryUHcnpHe06e5OrepUHd/wwjReDw2+UST3NWFbX44Ew==";

function toArray<T>(maybeArr: T[] | T | undefined): T[] {
  if (!maybeArr) return [];
  return Array.isArray(maybeArr) ? maybeArr : [maybeArr];
}

function buildUrl(
  path: string,
  params: Record<string, string | number | undefined>
) {
  const q = qs.stringify(
    Object.entries(params).reduce<Record<string, string>>((acc, [k, v]) => {
      if (v !== undefined && v !== null && v !== "") acc[k] = String(v);
      return acc;
    }, {})
  );
  return `${BASE_URL}${path}?${q}`;
}

export type DrugValidity = {
  itemName: string;
  entpName?: string;
  itemNo?: string;
  itemSeq?: string;
  validTermText?: string; // 원문
  renewalDeadline?: string; // YYYY-MM-DD 변환 시도 실패 시 원문 유지 필요
};

export async function fetchDrugValidity(
  itemName: string,
  entpName?: string
): Promise<DrugValidity | null> {
  // 1차: 제품명으로 검색
  const primary = await callApi({ item_name: itemName });
  let best = pickBest(primary, itemName, entpName);

  // 2차: 안 나오면 제조사 포함 재검색
  if (!best && entpName) {
    const secondary = await callApi({
      item_name: itemName,
      entp_name: entpName,
    });
    best = pickBest(secondary, itemName, entpName);
  }

  if (!best) return null;
  return {
    itemName: best.ITEM_NAME || itemName,
    entpName: best.ENTP_NAME,
    itemNo: best.ITEM_NO,
    itemSeq: best.ITEM_SEQ,
    validTermText: best.VALID_TERM_DATE,
    renewalDeadline: best.VALID_TERM_DATE_CUTLINE,
  };
}

async function callApi(params: { item_name?: string; entp_name?: string }) {
  try {
    const workerUrl =
      process.env.CLOUDFLARE_WORKER_URL ||
      "https://take-your-medicine-api-proxy-production.how-about-this-api.workers.dev";

    const url = new URL(`${workerUrl}/drug-validity`);
    url.searchParams.set("item_name", params.item_name || "");
    url.searchParams.set("pageNo", "1");
    url.searchParams.set("numOfRows", "100");
    if (params.entp_name) {
      url.searchParams.set("entp_name", params.entp_name);
    }

    console.log(
      `🔍 유효기간 API 호출 (Cloudflare Worker): "${params.item_name}"`,
      `\nWorker URL: ${workerUrl}`,
      `\n요청 URL: ${url.toString().substring(0, 150)}...`
    );

    const res = await fetch(url.toString());
    if (!res.ok) {
      const errorText = await res.text();
      console.error(
        `❌ 유효기간 API 호출 실패: ${res.status} ${res.statusText}`,
        `\nWorker URL: ${workerUrl}`,
        `\n요청 URL: ${url.toString()}`,
        `\n응답: ${errorText.substring(0, 200)}`
      );
      return [] as DrugValidityItem[];
    }

    const responseText = await res.text();
    console.log(
      `📥 유효기간 API 응답 수신: ${responseText.substring(0, 200)}...`
    );

    let data: DrugValidityResponse;
    try {
      data = JSON.parse(responseText) as DrugValidityResponse;
    } catch (parseError) {
      console.error(
        `❌ 유효기간 API JSON 파싱 실패:`,
        parseError,
        `\nWorker URL: ${workerUrl}`,
        `\n요청 URL: ${url.toString()}`,
        `\n응답 본문 (처음 500자): ${responseText.substring(0, 500)}`
      );
      return [] as DrugValidityItem[];
    }

    const itemsRaw = data?.body?.items?.item;
    const items = toArray(itemsRaw);
    console.log(
      `✅ 유효기간 API: "${params.item_name}" 검색 결과 ${items.length}개`
    );
    return items;
  } catch (error) {
    console.error(`❌ 유효기간 API 오류:`, error);
    if (error instanceof Error) {
      console.error(`에러 메시지: ${error.message}`);
      console.error(`스택 트레이스: ${error.stack}`);
    }
    return [] as DrugValidityItem[];
  }
}

function normalize(s?: string) {
  return (s || "").replace(/\s+/g, "").toLowerCase();
}

function pickBest(
  list: DrugValidityItem[],
  itemName: string,
  entpName?: string
) {
  if (!list || list.length === 0) return null;
  const target = normalize(itemName);
  const entp = normalize(entpName);

  // 우선순위: (이름 완전일치 && 제조사 일치) > (이름 포함 && 제조사 일치) > 이름 완전일치 > 첫번째
  const exactBoth = list.find(
    (i) =>
      normalize(i.ITEM_NAME) === target &&
      (!!entp ? normalize(i.ENTP_NAME) === entp : true)
  );
  if (exactBoth) return exactBoth;

  const containBoth = list.find(
    (i) =>
      normalize(i.ITEM_NAME).includes(target) &&
      (!!entp ? normalize(i.ENTP_NAME) === entp : true)
  );
  if (containBoth) return containBoth;

  const exactName = list.find((i) => normalize(i.ITEM_NAME) === target);
  if (exactName) return exactName;

  return list[0];
}

// e약은요(개요정보) API - 낱알이미지 조회
const OVERVIEW_BASE = "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService";
const EAPIYAK_SERVICE_KEY =
  process.env.EAPIYAK_SERVICE_KEY ||
  "dJfT/j5TTe7mvR8DIXbP9SoyhvH+Fx7dS27bsViReXQiQtQPPp6ng7o1jHITVXdW3PRS/20m48MQgaBT9nFecw==";
export async function fetchDrugOverviewImage(
  itemName: string,
  entpName?: string
): Promise<string | null> {
  try {
    const url = `${OVERVIEW_BASE}/getDrbEasyDrugList?${qs.stringify({
      serviceKey: EAPIYAK_SERVICE_KEY,
      type: "json",
      itemName,
      ...(entpName ? { entpName } : {}),
      pageNo: 1,
      numOfRows: 30,
    })}`;

    console.log(
      `🔍 e약은요 API 호출: "${itemName}" (URL: ${url.substring(0, 100)}...)`
    );

    const res = await fetch(url);
    if (!res.ok) {
      console.error(
        `❌ e약은요 API 호출 실패: ${res.status} ${res.statusText} (${itemName})`
      );
      return null;
    }

    // 응답 본문을 먼저 텍스트로 확인
    const responseText = await res.text();
    console.log(
      `📥 e약은요 API 응답 수신 (${itemName}): ${responseText.substring(
        0,
        200
      )}...`
    );

    let data: any;
    try {
      data = JSON.parse(responseText);
    } catch (parseError) {
      console.error(`❌ e약은요 API JSON 파싱 실패 (${itemName}):`, parseError);
      console.error(
        `응답 본문 (처음 500자): ${responseText.substring(0, 500)}`
      );
      return null;
    }

    // totalCount가 0이면 검색 결과 없음
    const totalCount = data?.body?.totalCount;
    if (totalCount === 0 || totalCount === "0") {
      console.log(
        `ℹ️ e약은요 API: "${itemName}" 검색 결과 없음 (totalCount: ${totalCount})`
      );
      return null;
    }

    // 응답 구조 확인: 여러 가능한 구조 처리
    let itemsRaw: any = null;

    // 1. body.items가 배열인 경우 (직접 배열) - JSON 응답
    if (Array.isArray(data?.body?.items)) {
      itemsRaw = data.body.items;
      console.log(
        `✅ e약은요 API: "${itemName}" JSON 응답 (배열 형태), 항목 수: ${itemsRaw.length}`
      );
    }
    // 2. body.items.item이 있는 경우 (객체 또는 배열)
    else if (data?.body?.items?.item) {
      itemsRaw = data.body.items.item;
      console.log(
        `✅ e약은요 API: "${itemName}" JSON 응답 (item 필드), 항목 수: ${
          Array.isArray(itemsRaw) ? itemsRaw.length : 1
        }`
      );
    }
    // 3. body.items가 객체이고 item 필드가 없는 경우 (단일 객체)
    else if (
      data?.body?.items &&
      typeof data.body.items === "object" &&
      !Array.isArray(data.body.items)
    ) {
      // items 객체 자체가 item인 경우 (단일 항목)
      if (data.body.items.itemName) {
        itemsRaw = [data.body.items];
        console.log(`✅ e약은요 API: "${itemName}" JSON 응답 (단일 객체)`);
      } else {
        itemsRaw = null;
      }
    }

    if (!itemsRaw) {
      console.error(
        `❌ e약은요 API 응답에 items가 없습니다: "${itemName}"`,
        `\n응답 구조:`,
        JSON.stringify(data, null, 2).substring(0, 500)
      );
      return null;
    }

    // 배열로 정규화 (단일 객체인 경우 배열로 변환)
    const items = Array.isArray(itemsRaw) ? itemsRaw : [itemsRaw];
    if (items.length === 0) {
      console.error(
        `❌ e약은요 API: "${itemName}" 검색 결과 없음 (items 배열이 비어있음)`
      );
      return null;
    }

    // 우선순위: 이름 완전일치 + 제조사 일치 → 이름 완전일치 → 첫 항목
    const norm = (s?: string) => (s || "").replace(/\s+/g, "").toLowerCase();
    const tName = norm(itemName);
    const tEntp = norm(entpName);

    let cand = items.find(
      (i: any) =>
        norm(i.itemName) === tName && (!tEntp || norm(i.entpName) === tEntp)
    );
    if (!cand) {
      cand = items.find((i: any) => norm(i.itemName) === tName) || items[0];
    }

    if (!cand) {
      console.error(
        `❌ e약은요 API: "${itemName}" 매칭 실패 (항목 수: ${items.length})`
      );
      return null;
    }

    // itemImage 필드 추출
    const img = cand.itemImage?.toString() || null;
    if (!img || img.trim() === "") {
      console.error(
        `❌ e약은요 API: "${itemName}" 이미지 URL 없음`,
        `\n선택된 항목:`,
        JSON.stringify(
          { itemName: cand.itemName, entpName: cand.entpName },
          null,
          2
        )
      );
      return null;
    }

    const imgUrl = img.trim();
    if (!/^https?:\/\//i.test(imgUrl)) {
      console.error(
        `❌ e약은요 API: "${itemName}" 잘못된 이미지 URL 형식: ${imgUrl}`
      );
      return null;
    }

    console.log(
      `✅ e약은요 이미지 찾음: "${itemName}" → ${imgUrl.substring(0, 80)}...`
    );
    return imgUrl;
  } catch (error) {
    console.error(`❌ e약은요 API 오류 (${itemName}):`, error);
    if (error instanceof Error) {
      console.error(`에러 메시지: ${error.message}`);
      console.error(`스택 트레이스: ${error.stack}`);
    }
    return null;
  }
}
