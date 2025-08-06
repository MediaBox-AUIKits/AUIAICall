// 标记最新状态下是否需要对应轨道
let needAudio = false;
let needVideo = false;
// 标记是否正在获取轨道中
let gettingAudio = false;
let gettingVideo = false;
// 存放已获取的轨道
let audioTrack: MediaStreamTrack | null = null;
let videoTrack: MediaStreamTrack | null = null;

export function getDeviceStream(audio: boolean, video: boolean) {
  needAudio = audio;
  needVideo = video;

  // 决定是否要调用 getUserMedia 获取对应轨道
  let shouldGetAudio = false;
  let shouldGetVideo = false;
  if (needAudio && !gettingAudio && !audioTrack) {
    shouldGetAudio = true;
  }
  if (needVideo && !gettingVideo && !videoTrack) {
    shouldGetVideo = true;
  }

  // 如果最新状态下不需要对应的轨道而当前有，则销毁
  if (!needAudio && audioTrack) {
    audioTrack.stop();
    audioTrack = null;
  }
  if (!needVideo && videoTrack) {
    videoTrack.stop();
    videoTrack = null;
  }

  if (!shouldGetAudio && !shouldGetVideo) return;

  gettingAudio = shouldGetAudio;
  gettingVideo = shouldGetVideo;

  navigator.mediaDevices?.getUserMedia({ audio: shouldGetAudio, video: shouldGetVideo }).then((stream) => {
    // 拿到流后检查轨道在最新状态下是否还需要，如果不需要则销毁
    if (shouldGetAudio) {
      gettingAudio = false;
      const at = stream.getAudioTracks()[0];
      if (needAudio && !audioTrack) {
        audioTrack = at;
      } else {
        at.stop();
      }
    }
    if (shouldGetVideo) {
      gettingVideo = false;
      const vt = stream.getVideoTracks()[0];
      if (needVideo && !videoTrack) {
        videoTrack = vt;
      } else {
        vt.stop();
      }
    }
  });
}
