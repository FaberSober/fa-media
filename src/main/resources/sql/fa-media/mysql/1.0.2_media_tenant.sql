-- ------------------------- info -------------------------
-- @@ver: 1_000_002
-- @@info: 媒体视频表租户隔离
-- ------------------------- info -------------------------

-- media_video 历史表字段为 utf8mb4_unicode_ci，tn_tenant_user 为 utf8mb4_general_ci，
-- 回填 UPDATE 跨表比较需显式 COLLATE，否则报 Illegal mix of collations。
-- ADD COLUMN 用预处理语句做幂等：脚本失败重跑时列已存在，直接跳过加列。

SET @sql := IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'media_video' AND COLUMN_NAME = 'tenant_id') = 0,
    'ALTER TABLE `media_video` ADD COLUMN `tenant_id` varchar(32) DEFAULT NULL COMMENT ''租户ID'' AFTER `audit_status`',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 历史视频归属到创建者默认租户；若创建者没有租户关联，则回退到平台排序最前的启用租户。
UPDATE `media_video` AS v
SET `tenant_id` = COALESCE(
    (SELECT tu.`tenant_id`
     FROM `tn_tenant_user` tu
     INNER JOIN `tn_tenant` t ON t.`id` = tu.`tenant_id`
     WHERE tu.`user_id` = v.`crt_user` COLLATE utf8mb4_general_ci AND tu.`status` = 1 AND tu.`deleted` = 0
       AND t.`status` = 1 AND t.`deleted` = 0
       AND (t.`expire_time` IS NULL OR t.`expire_time` > CURRENT_TIMESTAMP)
     ORDER BY tu.`sort`, tu.`id` LIMIT 1),
    (SELECT t.`id` FROM `tn_tenant` t
     WHERE t.`status` = 1 AND t.`deleted` = 0
       AND (t.`expire_time` IS NULL OR t.`expire_time` > CURRENT_TIMESTAMP)
     ORDER BY t.`sort`, t.`id` LIMIT 1)
)
WHERE v.`tenant_id` IS NULL;

CREATE INDEX `idx_media_video_tenant_id` ON `media_video` (`tenant_id`);
