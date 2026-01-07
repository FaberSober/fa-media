package com.faber.api.media.video.biz;

import java.io.File;
import java.math.BigDecimal;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.Executor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.faber.api.base.admin.biz.FileSaveBiz;
import com.faber.api.base.admin.entity.FileSave;
import com.faber.api.media.video.entity.MediaVideo;
import com.faber.api.media.video.mapper.MediaVideoMapper;
import com.faber.api.media.video.utils.FaMediaUtils;
import com.faber.api.media.video.vo.meta.VideoMetaInfo;
import com.faber.core.context.BaseContextHandler;
import com.faber.core.exception.NoDataException;
import com.faber.core.utils.FaFileUtils;
import com.faber.core.web.biz.BaseBiz;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.ObjUtil;
import cn.hutool.core.util.StrUtil;
import jakarta.annotation.Resource;

/**
 * 媒体-视频信息表
 *
 * @author xu.pengfei
 * @email 1508075252@qq.com
 * @date 2026-01-07 13:58:32
 */
@Service
public class MediaVideoBiz extends BaseBiz<MediaVideoMapper,MediaVideo> {

    @Resource FileSaveBiz fileSaveBiz;
    @Autowired Executor executor;

    public MediaVideo create(String originFileId) {
        FileSave fileOrigin = fileSaveBiz.getById(originFileId);
        if (fileOrigin == null) throw new NoDataException();

        VideoMetaInfo videoMetaInfo = FaMediaUtils.getVideoMeta(fileOrigin.getUrl());
        if (!ObjUtil.equal(fileOrigin.getSize(), videoMetaInfo.getFileSize())) {
            fileSaveBiz.lambdaUpdate()
                .set(FileSave::getSize, videoMetaInfo.getFileSize())
                .eq(FileSave::getId, fileOrigin.getId())
                .update();
        }

        MediaVideo mediaVideo = new MediaVideo();
        mediaVideo.setOriginFilename(fileOrigin.getOriginalFilename());
        mediaVideo.setOriginFileId(originFileId);
        mediaVideo.setOriginWidth(videoMetaInfo.getWidth());
        mediaVideo.setOriginHeight(videoMetaInfo.getHeight());
        mediaVideo.setOriginDuration(videoMetaInfo.getDuration().intValue());
        mediaVideo.setOriginBitrate(videoMetaInfo.getSampleRate());
        mediaVideo.setFps(BigDecimal.valueOf(Double.valueOf(videoMetaInfo.getFrameRate())));
        mediaVideo.setOriginSizeMb(BigDecimal.valueOf(videoMetaInfo.getFileSize() / 1024.0 / 1024.0));
        mediaVideo.setCodecVideo(videoMetaInfo.getVideoCodec());
        mediaVideo.setCodecAudio(videoMetaInfo.getAudioCodec());
        mediaVideo.setFormat(fileOrigin.getExt().toLowerCase());

        mediaVideo.setTrans720pProgress(0);
        mediaVideo.setTrans720pStatus(0); // 0-未开始
        mediaVideo.setStatus(1);
        mediaVideo.setAuditStatus(0);

        this.save(mediaVideo);

        return mediaVideo;
    }

    public void startCompressVideo(String id) {
        MediaVideo mediaVideo = this.getById(id);
        if (mediaVideo == null) {
            throw new NoDataException();
        }
        FileSave fileOrigin = fileSaveBiz.getById(mediaVideo.getOriginFileId());
        if (fileOrigin == null) throw new NoDataException();

        Map<String, Object> holdMap = BaseContextHandler.getHoldMap();
        executor.execute(() -> {
            // 线程中执行
            try {
                BaseContextHandler.setHoldMap(holdMap);

                this.lambdaUpdate()
                    .set(MediaVideo::getTrans720pStartTime, new Date())
                    .set(MediaVideo::getTrans720pProgress, 0)
                    .set(MediaVideo::getTrans720pStatus, 1) // 1-进行中
                    .eq(MediaVideo::getId, mediaVideo.getId())
                    .update();

                // 创建压缩后的视频存储路径
                String dirPath = FaFileUtils.getAbsolutePath() + "/media/compress/" + mediaVideo.getId() + "/";
                FileUtil.mkdir(dirPath);
                String filename = mediaVideo.getOriginFilename().substring(0, mediaVideo.getOriginFilename().lastIndexOf("."));
                String outputFilePath = dirPath + filename + "_720p.mp4";
                FaMediaUtils.compressVideo720(fileOrigin.getUrl(), outputFilePath, progress -> {
                    // 进度处理逻辑
                    try {
                        double progressPercent = (double) progress.getTimeMillis() / (mediaVideo.getOriginDuration() * 1000) * 100;
                        log.debug(StrUtil.format("视频压缩进度（ID：{}）：{}/{} ms ({}%)", id, progress.getTimeMillis(), mediaVideo.getOriginDuration() * 1000, progressPercent));
                        this.lambdaUpdate()
                            .set(MediaVideo::getTrans720pProgress, (int) progressPercent)
                            .eq(MediaVideo::getId, mediaVideo.getId())
                            .update();
                    } catch (Exception e) {
                        log.error(StrUtil.format("视频压缩进度处理失败（ID：{}）：{}", id, e.getMessage()), e);
                    }
                });

                // 保存压缩后的视频文件记录
                FileSave fileSave = fileSaveBiz.upload(new File(outputFilePath));

                this.lambdaUpdate()
                    .set(MediaVideo::getTrans720pFileId, fileSave.getId())
                    .set(MediaVideo::getTrans720pSizeMb, BigDecimal.valueOf(fileSave.getSize() / 1024.0 / 1024.0))
                    .set(MediaVideo::getTrans720pEndTime, new Date())
                    .set(MediaVideo::getTrans720pProgress, 100)
                    .set(MediaVideo::getTrans720pStatus, 2) // 2-成功
                    .eq(MediaVideo::getId, mediaVideo.getId())
                    .update();
            } catch (Exception e) {
                log.error(StrUtil.format("视频压缩任务启动失败，ID：{}，错误信息：{}", id, e.getMessage()), e);
                this.lambdaUpdate()
                    .set(MediaVideo::getTrans720pMessage, e.getMessage())
                    .set(MediaVideo::getTrans720pStatus, 3) // 3-失败
                    .eq(MediaVideo::getId, mediaVideo.getId())
                    .update();
            }
        });
    }

}