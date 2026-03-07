-- tb_appointment_treatment 테이블에 appointment_id 컬럼 추가
-- 예약 시술 테이블에 예약 ID FK를 추가하여 특정 예약의 시술 목록을 조회할 수 있도록 합니다.

ALTER TABLE tb_appointment_treatment
    ADD COLUMN IF NOT EXISTS appointment_id text NULL;

COMMENT ON COLUMN tb_appointment_treatment.appointment_id IS '예약 ID';

-- 기존 데이터에 대해 appointment_id를 설정할 수 없으므로,
-- 마이그레이션된 데이터는 별도로 매핑 작업이 필요합니다.

-- 인덱스 추가 (조회 성능 최적화)
CREATE INDEX IF NOT EXISTS idx_appointment_treatment_appointment_id
    ON tb_appointment_treatment (appointment_id)
    WHERE delete_yn = 'N';
