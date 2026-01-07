package com.faber.api.media.video.rest;

import com.faber.core.annotation.FaLogBiz;
import com.faber.core.web.rest.BaseController;
import com.faber.api.media.video.biz.MediaVideoBiz;
import com.faber.api.media.video.entity.MediaVideo;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 媒体-视频信息表
 *
 * @author xu.pengfei
 * @email 1508075252@qq.com
 * @date 2026-01-07 13:58:32
 */
@FaLogBiz("媒体-视频信息表")
@RestController
@RequestMapping("/api/media/video/mediaVideo")
public class MediaVideoController extends BaseController<MediaVideoBiz, MediaVideo, String> {

}