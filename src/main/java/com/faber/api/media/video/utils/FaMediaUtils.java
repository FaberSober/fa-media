package com.faber.api.media.video.utils;

import com.faber.api.media.video.vo.meta.VideoMetaInfo;
import com.github.kokorin.jaffree.StreamType;
import com.github.kokorin.jaffree.ffprobe.FFprobe;
import com.github.kokorin.jaffree.ffprobe.FFprobeResult;
import com.github.kokorin.jaffree.ffprobe.Format;
import com.github.kokorin.jaffree.ffprobe.Stream;

/**
 * 视频、音频工具类
 */
public class FaMediaUtils {
    
    /**
     * 获取远程视频详细元数据
     * @param videoUrl 视频URL（需带签名参数）
     * @return VideoMetaInfo 实体
     */
    public static VideoMetaInfo getVideoMeta(String videoUrl) {
        VideoMetaInfo info = new VideoMetaInfo();
        
        try {
            FFprobeResult result = FFprobe.atPath()
                    .setInput(videoUrl)
                    // 建议增加网络读取超时限制（单位微秒，此处为5秒）
                    .addArgument("-rw_timeout").addArgument("5000000")
                    .setShowStreams(true)
                    .setShowFormat(true)
                    .execute();

            // 1. 获取全局格式信息 (时长和文件大小)
            Format format = result.getFormat();
            if (format != null) {
                info.setDuration(format.getDuration() != null ? format.getDuration().doubleValue() : 0.0);
                info.setFileSize(format.getSize()); 
            }

            // 2. 遍历流信息
            for (Stream stream : result.getStreams()) {
                if (StreamType.VIDEO.equals(stream.getCodecType())) {
                    info.setWidth(stream.getWidth());
                    info.setHeight(stream.getHeight());
                    info.setVideoCodec(stream.getCodecName());
                    // getRFrameRate() 返回的是 Rational (如 "24/1")
                    info.setFrameRate(stream.getRFrameRate() != null ? stream.getRFrameRate().toString() : "");
                } else if (StreamType.AUDIO.equals(stream.getCodecType())) {
                    info.setAudioCodec(stream.getCodecName());
                    info.setSampleRate(stream.getSampleRate());
                }
            }
        } catch (Exception e) {
            // 这里可以根据实际业务需求抛出自定义异常或打日志
            System.err.println("解析视频元数据失败: " + e.getMessage());
            return null;
        }

        return info;
    }

    public static void compressVideo(String videoUrl, String outputFilePath) {
        
    }
    
}
