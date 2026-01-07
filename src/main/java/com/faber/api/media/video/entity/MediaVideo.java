package com.faber.api.media.video.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.faber.core.annotation.FaModalName;
import com.faber.core.annotation.SqlEquals;
import com.faber.core.bean.BaseDelEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.Date;
import java.math.BigDecimal;

/**
 * 媒体-视频信息表
 *
 * @author xu.pengfei
 * @email 1508075252@qq.com
 * @date 2026-01-07 13:58:32
 */
@FaModalName(name = "媒体-视频信息表")
@TableName("media_video")
@Data
@EqualsAndHashCode(callSuper = true)
public class MediaVideo extends BaseDelEntity {

    @ColumnWidth(8)
    @ExcelProperty("视频记录唯一ID")
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @SqlEquals
    @ExcelProperty("关联业务ID（如文章ID、动态ID、课程ID等）")
    private String businessId;

    @SqlEquals
    @ExcelProperty("业务类型（如 post、moment、course 等）")
    private String businessType;

    @SqlEquals
    @ExcelProperty("原视频文件ID -> base_file_save.id")
    private String originFileId;

    @ExcelProperty("原始视频文件名（冗余存储，便于查询展示）")
    private String originFilename;

    @ExcelProperty("原始视频宽度（像素）")
    private Integer originWidth;

    @ExcelProperty("原始视频高度（像素）")
    private Integer originHeight;

    @ExcelProperty("原始视频码率（kbps）")
    private Integer originBitrate;

    @ExcelProperty("原始视频时长（秒）")
    private Integer originDuration;

    @ExcelProperty("原始视频大小（MB）")
    private BigDecimal originSizeMb;

    @SqlEquals
    @ExcelProperty("720p转码视频文件ID -> base_file_save.id")
    private String trans720pFileId;

    @ExcelProperty("720p视频大小（MB）")
    private BigDecimal trans720pSizeMb;

    @SqlEquals
    @ExcelProperty("封面图文件ID -> base_file_save.id")
    private String coverFileId;

    @SqlEquals
    @ExcelProperty("预览视频文件ID -> base_file_save.id")
    private String previewFileId;

    @ExcelProperty("预览视频时长（秒）")
    private Integer previewDuration;

    @ExcelProperty("视频容器格式（如 mp4、mov、webm）")
    private String format;

    @ExcelProperty("视频编码（如 h264、h265、vp9）")
    private String codecVideo;

    @ExcelProperty("音频编码（如 aac、mp3）")
    private String codecAudio;

    @ExcelProperty("帧率")
    private BigDecimal fps;

    @SqlEquals
    @ExcelProperty("视频状态：0=转码中,1=正常,-1=转码失败,-2=违规")
    private Integer status;

    @SqlEquals
    @ExcelProperty("审核状态：0=待审核,1=通过,2=拒绝")
    private Integer auditStatus;

}
