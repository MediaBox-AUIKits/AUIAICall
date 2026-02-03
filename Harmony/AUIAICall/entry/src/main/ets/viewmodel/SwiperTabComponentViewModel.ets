import { SwiperTabComponentModel } from "../model/SwiperTabComponentModel";

class SwiperTabComponentViewModel {
  static getSwiperTabData(): Array<SwiperTabComponentModel> {
    let model: SwiperTabComponentModel[] = [
      new SwiperTabComponentModel(0, $r('app.string.audio_call'), '[.01_07]', $r('app.media.bg_entrance_voice_agent'), $r('app.string.audio_call_des')),
      new SwiperTabComponentModel(1, $r('app.string.digital_man_call'), '[.02_07]', $r('app.media.bg_entrance_avatar_agent'), $r('app.string.digital_man_call_des')),
      new SwiperTabComponentModel(2, $r('app.string.visual_understanding'), '[.03_07]', $r('app.media.bg_entrance_vision_agent'), $r('app.string.visual_understanding_des')),
      new SwiperTabComponentModel(3, $r('app.string.video_call'), '[.04_07]', $r('app.media.bg_entrance_video_agent'), $r('app.string.video_call_des')),
      // new SwiperTabComponentModel(4, $r('app.string.message_talk'), '[.05_08]',$r('app.media.bg_entrance_chatbot_agent'), $r('app.string.message_talk_des')),
      new SwiperTabComponentModel(4, $r('app.string.AI_phone_call'), '[.05_07]', $r('app.media.bg_entrance_pstn_out'), $r('app.string.AI_phone_call_des')),
      new SwiperTabComponentModel(5, $r('app.string.AI_phone_import'), '[.06_07]', $r('app.media.bg_entrance_pstn_in'), $r('app.string.AI_phone_import_des')),
      new SwiperTabComponentModel(6, $r('app.string.custom_agent'), '[.07_07]', $r('app.media.bg_entrance_custom_agent'), $r('app.string.custom_agent_des')),
    ];
    return model;
  }
}

export { SwiperTabComponentViewModel }