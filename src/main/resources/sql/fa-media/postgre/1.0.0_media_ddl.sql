-- ------------------------- info -------------------------
-- @@ver: 1_000_000
-- @@info: 初始化fa-media模块
-- ------------------------- info -------------------------

-- ----------------------------
-- Table structure for media_video
-- ----------------------------
CREATE TABLE IF NOT EXISTS "media_video" (
  "id" varchar(32) NOT NULL,
  "business_id" varchar(64) NULL DEFAULT NULL,
  "business_type" varchar(32) NULL DEFAULT NULL,
  "origin_file_id" varchar(32) NOT NULL,
  "origin_filename" varchar(255) NOT NULL,
  "origin_width" integer NOT NULL DEFAULT 0,
  "origin_height" integer NOT NULL DEFAULT 0,
  "origin_bitrate" integer NOT NULL DEFAULT 0,
  "origin_duration" integer NOT NULL DEFAULT 0,
  "origin_size_mb" decimal(12, 2) NOT NULL DEFAULT 0.00,
  "trans720p_file_id" varchar(32) NULL DEFAULT NULL,
  "trans720p_size_mb" decimal(12, 2) NULL DEFAULT 0.00,
  "trans720p_progress" smallint NOT NULL DEFAULT 0,
  "trans720p_status" smallint NOT NULL DEFAULT 0,
  "trans720p_message" varchar(255) NULL DEFAULT NULL,
  "trans720p_start_time" timestamp NULL DEFAULT NULL,
  "trans720p_end_time" timestamp NULL DEFAULT NULL,
  "cover_file_id" varchar(32) NULL DEFAULT NULL,
  "preview_file_id" varchar(32) NULL DEFAULT NULL,
  "preview_duration" smallint NULL DEFAULT NULL,
  "format" varchar(16) NULL DEFAULT NULL,
  "codec_video" varchar(32) NULL DEFAULT NULL,
  "codec_audio" varchar(32) NULL DEFAULT NULL,
  "fps" decimal(4, 2) NULL DEFAULT NULL,
  "status" smallint NOT NULL DEFAULT 1,
  "audit_status" smallint NOT NULL DEFAULT 0,
  "crt_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "crt_user" varchar(32) NOT NULL,
  "crt_name" varchar(255) NOT NULL,
  "crt_host" varchar(255) NULL DEFAULT NULL,
  "upd_time" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "upd_user" varchar(32) NULL DEFAULT NULL,
  "upd_name" varchar(255) NULL DEFAULT NULL,
  "upd_host" varchar(255) NULL DEFAULT NULL,
  "deleted" boolean NOT NULL DEFAULT FALSE,
  PRIMARY KEY ("id")
);
COMMENT ON TABLE "media_video" IS '媒体-视频信息表';
COMMENT ON COLUMN "media_video"."id" IS '视频记录唯一ID';
COMMENT ON COLUMN "media_video"."business_id" IS '关联业务ID（如文章ID、动态ID、课程ID等）';
COMMENT ON COLUMN "media_video"."business_type" IS '业务类型（如 post、moment、course 等）';
COMMENT ON COLUMN "media_video"."origin_file_id" IS '原视频文件ID -> base_file_save.id';
COMMENT ON COLUMN "media_video"."origin_filename" IS '原始视频文件名（冗余存储，便于查询展示）';
COMMENT ON COLUMN "media_video"."origin_width" IS '原始视频宽度（像素）';
COMMENT ON COLUMN "media_video"."origin_height" IS '原始视频高度（像素）';
COMMENT ON COLUMN "media_video"."origin_bitrate" IS '原始视频码率（kbps）';
COMMENT ON COLUMN "media_video"."origin_duration" IS '原始视频时长（秒）';
COMMENT ON COLUMN "media_video"."origin_size_mb" IS '原始视频大小（MB）';
COMMENT ON COLUMN "media_video"."trans720p_file_id" IS '720p转码视频文件ID -> base_file_save.id';
COMMENT ON COLUMN "media_video"."trans720p_size_mb" IS '720p视频大小（MB）';
COMMENT ON COLUMN "media_video"."trans720p_progress" IS '720p转码进度百分比（0-100，0表示未开始，100表示完成）';
COMMENT ON COLUMN "media_video"."trans720p_status" IS '720p转码详细状态：0=未开始,1=转码中,2=成功,3=失败,4=已取消';
COMMENT ON COLUMN "media_video"."trans720p_message" IS '720p转码失败或警告的详细信息（如错误日志）';
COMMENT ON COLUMN "media_video"."trans720p_start_time" IS '720p转码开始时间';
COMMENT ON COLUMN "media_video"."trans720p_end_time" IS '720p转码结束时间';
COMMENT ON COLUMN "media_video"."cover_file_id" IS '封面图文件ID -> base_file_save.id';
COMMENT ON COLUMN "media_video"."preview_file_id" IS '预览视频文件ID -> base_file_save.id';
COMMENT ON COLUMN "media_video"."preview_duration" IS '预览视频时长（秒）';
COMMENT ON COLUMN "media_video"."format" IS '视频容器格式（如 mp4、mov、webm）';
COMMENT ON COLUMN "media_video"."codec_video" IS '视频编码（如 h264、h265、vp9）';
COMMENT ON COLUMN "media_video"."codec_audio" IS '音频编码（如 aac、mp3）';
COMMENT ON COLUMN "media_video"."fps" IS '帧率';
COMMENT ON COLUMN "media_video"."status" IS '视频状态：0=转码中,1=正常,-1=转码失败,-2=违规';
COMMENT ON COLUMN "media_video"."audit_status" IS '审核状态：0=待审核,1=通过,2=拒绝';
COMMENT ON COLUMN "media_video"."crt_time" IS '创建时间';
COMMENT ON COLUMN "media_video"."crt_user" IS '创建用户ID';
COMMENT ON COLUMN "media_video"."crt_name" IS '创建用户';
COMMENT ON COLUMN "media_video"."crt_host" IS '创建IP';
COMMENT ON COLUMN "media_video"."upd_time" IS '更新时间';
COMMENT ON COLUMN "media_video"."upd_user" IS '更新用户ID';
COMMENT ON COLUMN "media_video"."upd_name" IS '更新用户';
COMMENT ON COLUMN "media_video"."upd_host" IS '更新IP';
COMMENT ON COLUMN "media_video"."deleted" IS '是否删除 0=正常 1=删除';
CREATE INDEX "idx_business" ON "media_video" ("business_id", "business_type");
CREATE INDEX "idx_origin_file" ON "media_video" ("origin_file_id");
CREATE INDEX "idx_720p_file" ON "media_video" ("trans720p_file_id");
CREATE INDEX "idx_cover_file" ON "media_video" ("cover_file_id");
CREATE INDEX "idx_preview_file" ON "media_video" ("preview_file_id");
CREATE INDEX "idx_status" ON "media_video" ("status", "audit_status");
CREATE INDEX "idx_crt_time" ON "media_video" ("crt_time");
CREATE INDEX "idx_deleted" ON "media_video" ("deleted");
DROP TRIGGER IF EXISTS "media_video__upd_time" ON "media_video";
CREATE TRIGGER "media_video__upd_time" BEFORE UPDATE ON "media_video" FOR EACH ROW EXECUTE FUNCTION fa_base_set_upd_time();

