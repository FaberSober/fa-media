CREATE TABLE `media_video` (
    `id`                    VARCHAR(32)      NOT NULL COMMENT '视频记录唯一ID',
    
    -- 业务关联字段（可选，根据实际业务使用）
    `business_id`           VARCHAR(64)      DEFAULT NULL COMMENT '关联业务ID（如文章ID、动态ID、课程ID等）',
    `business_type`         VARCHAR(32)      DEFAULT NULL COMMENT '业务类型（如 post、moment、course 等）',
    
    -- 原始视频信息
    `origin_file_id`        VARCHAR(32)      NOT NULL COMMENT '原视频文件ID -> base_file_save.id',
    `origin_filename`       VARCHAR(255)     NOT NULL COMMENT '原始视频文件名（冗余存储，便于查询展示）',
    `origin_width`          INT UNSIGNED     NOT NULL DEFAULT 0 COMMENT '原始视频宽度（像素）',
    `origin_height`         INT UNSIGNED     NOT NULL DEFAULT 0 COMMENT '原始视频高度（像素）',
    `origin_bitrate`        INT UNSIGNED     NOT NULL DEFAULT 0 COMMENT '原始视频码率（kbps）',
    `origin_duration`       INT UNSIGNED     NOT NULL DEFAULT 0 COMMENT '原始视频时长（秒）',
    `origin_size_mb`         DECIMAL(12,2)    NOT NULL DEFAULT 0.00 COMMENT '原始视频大小（MB）',
    
    -- 720p 转码视频
    `trans_720p_file_id`    VARCHAR(32)      DEFAULT NULL COMMENT '720p转码视频文件ID -> base_file_save.id',
    `trans_720p_size_mb`     DECIMAL(12,2)    DEFAULT 0.00 COMMENT '720p视频大小（MB）',
    
    -- 封面图
    `cover_file_id`         VARCHAR(32)      DEFAULT NULL COMMENT '封面图文件ID -> base_file_save.id',
    
    -- 预览视频（常用于短视频GIF或短mp4预览）
    `preview_file_id`       VARCHAR(32)      DEFAULT NULL COMMENT '预览视频文件ID -> base_file_save.id',
    `preview_duration`      SMALLINT UNSIGNED DEFAULT NULL COMMENT '预览视频时长（秒）',
    
    -- 可选扩展字段
    `format`                VARCHAR(16)      DEFAULT NULL COMMENT '视频容器格式（如 mp4、mov、webm）',
    `codec_video`           VARCHAR(32)      DEFAULT NULL COMMENT '视频编码（如 h264、h265、vp9）',
    `codec_audio`           VARCHAR(32)      DEFAULT NULL COMMENT '音频编码（如 aac、mp3）',
    `fps`                   DECIMAL(4,2)     DEFAULT NULL COMMENT '帧率',
    
    -- 状态字段
    `status`                TINYINT          NOT NULL DEFAULT 1 COMMENT '视频状态：0=转码中,1=正常,-1=转码失败,-2=违规',
    `audit_status`          TINYINT          NOT NULL DEFAULT 0 COMMENT '审核状态：0=待审核,1=通过,2=拒绝',
    
    -- 审计字段（完全与 base_file_save 对齐）
    `crt_time`              TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `crt_user`              VARCHAR(32)      NOT NULL COMMENT '创建用户ID',
    `crt_name`              VARCHAR(255)     NOT NULL COMMENT '创建用户',
    `crt_host`              VARCHAR(255)     DEFAULT NULL COMMENT '创建IP',
    `upd_time`              TIMESTAMP        NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `upd_user`              VARCHAR(32)      DEFAULT NULL COMMENT '更新用户ID',
    `upd_name`              VARCHAR(255)     DEFAULT NULL COMMENT '更新用户',
    `upd_host`              VARCHAR(255)     DEFAULT NULL COMMENT '更新IP',
    `deleted`               TINYINT(1)       NOT NULL DEFAULT '0' COMMENT '是否删除 0=正常 1=删除',
    
    PRIMARY KEY (`id`),
    KEY `idx_business` (`business_id`, `business_type`),
    KEY `idx_origin_file` (`origin_file_id`),
    KEY `idx_720p_file` (`trans_720p_file_id`),
    KEY `idx_cover_file` (`cover_file_id`),
    KEY `idx_preview_file` (`preview_file_id`),
    KEY `idx_status` (`status`, `audit_status`),
    KEY `idx_crt_time` (`crt_time`),
    KEY `idx_deleted` (`deleted`)

) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci 
  COMMENT='媒体-视频信息表';