package com.faber.api.media.video.biz;

import java.math.BigDecimal;
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
import com.faber.core.web.biz.BaseBiz;

import cn.hutool.core.util.ObjUtil;
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
        mediaVideo.setOriginSizeMb(BigDecimal.valueOf(videoMetaInfo.getFileSize() / 1024));
        mediaVideo.setCodecVideo(videoMetaInfo.getVideoCodec());
        mediaVideo.setCodecAudio(videoMetaInfo.getAudioCodec());
        mediaVideo.setFormat(fileOrigin.getExt().toLowerCase());

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

        Map<String, Object> holdMap = BaseContextHandler.getHoldMap();
        executor.execute(() -> {
            // 线程中执行
            BaseContextHandler.setHoldMap(holdMap);
        });
    }

}