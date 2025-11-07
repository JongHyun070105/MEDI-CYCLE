import { query } from "../database/db.js";
import { fetchDrugValidity, fetchDrugOverviewImage } from "./publicDataApiService.js";

function parseDate(s?: string) {
  if (!s) return null as string | null;
  const normalized = s.replace(/\./g, "-").replace(/\s/g, "");
  const m = normalized.match(/(\d{4})[-/](\d{2})[-/](\d{2})/);
  if (!m) return null;
  return `${m[1]}-${m[2]}-${m[3]}`;
}

export async function updateValidityForMedication(medId: number) {
  const medRes = await query(
    `SELECT id, drug_name, manufacturer FROM medications WHERE id = $1`,
    [medId]
  );
  if (medRes.rows.length === 0) return;
  const med = medRes.rows[0];
  const validity = await fetchDrugValidity(med.drug_name, med.manufacturer || undefined);
  if (!validity) return;

  const expiryDate = parseDate(validity.validTermText || undefined);
  const renewalDate = parseDate(validity.renewalDeadline || undefined);

  await query(
    `UPDATE medications
     SET expiry_date = COALESCE($2::date, expiry_date),
         valid_term_text = $3,
         renewal_deadline = COALESCE($4::date, renewal_deadline),
         api_item_seq = COALESCE($5, api_item_seq),
         api_item_no = COALESCE($6, api_item_no),
         api_entp_name = COALESCE($7, api_entp_name),
         api_last_checked = NOW()
     WHERE id = $1`,
    [
      med.id,
      expiryDate,
      validity.validTermText || null,
      renewalDate,
      validity.itemSeq || null,
      validity.itemNo || null,
      validity.entpName || null,
    ]
  );
}

export async function updateValidityForUser(userId: number) {
  const list = await query(
    `SELECT id FROM medications
     WHERE user_id = $1
       AND (api_last_checked IS NULL OR api_last_checked < NOW() - INTERVAL '7 days')`,
    [userId]
  );
  for (const row of list.rows) {
    try {
      await updateValidityForMedication(row.id);
    } catch (_) {}
  }
}

export async function updateValidityForAllUsers() {
  const users = await query(
    `SELECT DISTINCT user_id FROM medications`
  );
  for (const u of users.rows) {
    try {
      await updateValidityForUser(u.user_id);
    } catch (_) {}
  }
}

export function startDailyValidityUpdater() {
  // 24시간 간격으로 갱신 (서버 기동 시점 기준)
  const dayMs = 24 * 60 * 60 * 1000;
  setInterval(() => {
    updateValidityForAllUsers().catch(() => {});
  }, dayMs);
}


// 이미지가 없는 약에 대해 e약은요 개요정보에서 낱알이미지를 보정 저장
export async function updateMissingMedicationImages() {
  const meds = await query(
    `SELECT id, drug_name, manufacturer FROM medications WHERE item_image_url IS NULL`
  );
  for (const row of meds.rows) {
    try {
      const url = await fetchDrugOverviewImage(row.drug_name, row.manufacturer || undefined);
      if (url) {
        await query(
          `UPDATE medications SET item_image_url = $2 WHERE id = $1`,
          [row.id, url]
        );
      }
    } catch (_) {}
  }
}
