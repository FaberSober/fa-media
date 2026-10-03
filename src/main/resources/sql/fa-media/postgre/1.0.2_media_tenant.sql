-- ------------------------- info -------------------------
-- @@ver: 1_000_002
-- @@info: 媒体视频表租户隔离
-- ------------------------- info -------------------------

ALTER TABLE "media_video"
    ADD COLUMN IF NOT EXISTS "tenant_id" varchar(32) DEFAULT NULL;
COMMENT ON COLUMN "media_video"."tenant_id" IS '租户ID';

-- 历史视频归属到创建者默认租户；若创建者没有租户关联，则回退到平台排序最前的启用租户。
UPDATE "media_video" AS v
SET "tenant_id" = COALESCE(
    (SELECT tu."tenant_id"
     FROM "tn_tenant_user" tu
     INNER JOIN "tn_tenant" t ON t."id" = tu."tenant_id"
     WHERE tu."user_id" = v."crt_user" AND tu."status" IS TRUE AND tu."deleted" IS FALSE
       AND t."status" IS TRUE AND t."deleted" IS FALSE
       AND (t."expire_time" IS NULL OR t."expire_time" > CURRENT_TIMESTAMP)
     ORDER BY tu."sort", tu."id" LIMIT 1),
    (SELECT t."id" FROM "tn_tenant" t
     WHERE t."status" IS TRUE AND t."deleted" IS FALSE
       AND (t."expire_time" IS NULL OR t."expire_time" > CURRENT_TIMESTAMP)
     ORDER BY t."sort", t."id" LIMIT 1)
)
WHERE v."tenant_id" IS NULL;

CREATE INDEX IF NOT EXISTS "idx_media_video_tenant_id" ON "media_video" ("tenant_id");
