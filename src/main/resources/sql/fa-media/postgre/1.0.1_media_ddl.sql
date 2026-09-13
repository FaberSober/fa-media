-- ------------------------- info -------------------------
-- @@ver: 1_000_001
-- @@info: add menu
-- ------------------------- info -------------------------

INSERT INTO "base_rbac_menu" ("id", "parent_id", "scope", "name", "sort", "level", "icon", "status", "link_type", "link_url", "crt_time", "crt_user", "crt_name", "crt_host", "upd_time", "upd_user", "upd_name", "upd_host", "deleted") VALUES (22020005, 10000000, 1, '媒体中心', 4, 1, 'mdi:multimedia', TRUE, 1, '/admin/media', '2026-01-07 14:11:24', '1', '超级管理员', '192.168.5.88', '2026-01-07 14:11:24', '1', '超级管理员', '127.0.0.1', FALSE);

INSERT INTO "base_rbac_menu" ("id", "parent_id", "scope", "name", "sort", "level", "icon", "status", "link_type", "link_url", "crt_time", "crt_user", "crt_name", "crt_host", "upd_time", "upd_user", "upd_name", "upd_host", "deleted") VALUES (22020006, 22020005, 1, '视频中心', 0, 1, 'mdi:message-video', TRUE, 1, '/admin/media/video/list', '2026-01-07 14:11:39', '1', '超级管理员', '192.168.5.88', '2026-01-07 14:11:39', '1', '超级管理员', '127.0.0.1', FALSE);

SELECT setval(
    pg_get_serial_sequence('base_rbac_menu', 'id'),
    COALESCE((SELECT MAX("id") FROM "base_rbac_menu"), 1),
    TRUE
);

