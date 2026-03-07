-- ================================================================
-- tb_offer_designer 에 uid (디자이너 UID) 컬럼 추가
-- 기존 migration_id 에 'offerId_designerUid' 형태로 저장된 값에서
-- 디자이너 UID를 추출하여 uid 컬럼에 저장
-- ================================================================

-- 1) 컬럼 추가
ALTER TABLE tb_offer_designer
    ADD COLUMN IF NOT EXISTS uid text NULL;

COMMENT ON COLUMN tb_offer_designer.uid IS '디자이너 사용자 UID';

-- 2) 기존 migration_id 에서 designerUid 추출하여 업데이트
-- migration_id 형태: 'offerId_designerUid'
-- 첫 번째 '_' 이후의 문자열이 designer UID
UPDATE tb_offer_designer
SET uid = SUBSTRING(migration_id FROM POSITION('_' IN migration_id) + 1)
WHERE uid IS NULL
  AND migration_id IS NOT NULL
  AND POSITION('_' IN migration_id) > 0;

-- 3) 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_offer_designer_uid
    ON tb_offer_designer (uid);

CREATE INDEX IF NOT EXISTS idx_offer_designer_offer_id
    ON tb_offer_designer (offer_id);
