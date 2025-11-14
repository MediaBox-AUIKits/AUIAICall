import {
  AICallAgentState,
  AICallAgentType,
  AICallState,
  AICallSubtitleData,
  AICallVoiceprintResult,
  LatencyStat,
} from 'aliyun-auikit-aicall';
import { create } from 'zustand';

type SubtitleItem = {
  data: AICallSubtitleData;
  source: 'agent' | 'user';
  voiceprintResult?: AICallVoiceprintResult;
};

interface CallStore {
  agentType: AICallAgentType | undefined;

  callState: AICallState;
  callErrorMessage?: string;
  agentState: AICallAgentState;

  isSpeaking: boolean;

  currentSubtitle?: SubtitleItem;
  subtitleList: SubtitleItem[];
  updateSubtitle: (subtitle: SubtitleItem) => void;

  enablePushToTalk: boolean;
  updatingPushToTalk: boolean;
  pushingToTalk: boolean;

  enableVoiceInterrupt: boolean;
  updatingVoiceInterrupt: boolean;

  enableVoiceprint: boolean;
  updatingVoiceprint: boolean;
  voiceprintId?: string;

  voiceId: string;
  updatingVoiceId: boolean;

  microphoneMuted: boolean;
  cameraMuted: boolean;

  agentVoiceIdList: string[];
  voiceAvatarUrl: string;
  latencyStats: LatencyStat[];

  reset: (reserveAgentType?: boolean) => void;
  addLatencyRecord: (stats: LatencyStat) => void;
}

const initialCallState: Omit<CallStore, 'updateSubtitle' | 'reset' | 'addLatencyRecord'> = {
  callState: AICallState.None,
  agentType: undefined,
  agentState: AICallAgentState.Listening,
  isSpeaking: false,
  currentSubtitle: undefined,
  subtitleList: [],
  enablePushToTalk: false,
  updatingPushToTalk: false,
  pushingToTalk: false,
  enableVoiceInterrupt: true,
  updatingVoiceInterrupt: false,
  enableVoiceprint: false,
  updatingVoiceprint: false,
  voiceId: '',
  updatingVoiceId: false,
  microphoneMuted: false,
  cameraMuted: false,
  agentVoiceIdList: [],
  voiceAvatarUrl: '',
  latencyStats: [],
};

const useCallStore = create<CallStore>((set) => ({
  ...initialCallState,
  updateSubtitle: (subtitle) =>
    set((state: CallStore) => {
      const newState: Partial<CallStore> = {};

      // Agent 未识别到主讲人，跳过
      // Agent did not recognize the speaker, skip
      if (
        subtitle.source === 'user' &&
        (subtitle.voiceprintResult === AICallVoiceprintResult.UndetectedSpeaker ||
          subtitle.voiceprintResult === AICallVoiceprintResult.UndetectedSpeakerWithAIVad)
      ) {
        return state;
      }

      const existSubtitleIndex = state.subtitleList.findIndex(
        (item) => item.data.sentenceId === subtitle.data.sentenceId && item.source === subtitle.source
      );

      // subtitle 已经存在
      // subtitle has been exist
      if (existSubtitleIndex > -1) {
        const existSubtitle = state.subtitleList[existSubtitleIndex];
        if (subtitle.source === 'agent') {
          subtitle.data.text = existSubtitle.data.text + subtitle.data.text;
        }

        state.subtitleList.splice(existSubtitleIndex, 1, subtitle);
        newState.subtitleList = [...state.subtitleList];
      } else if (subtitle.data.text) {
        newState.subtitleList = [...state.subtitleList, subtitle];
      }
      newState.currentSubtitle = subtitle;

      return newState;
    }),
  addLatencyRecord: (stats: LatencyStat) =>
    set((state: CallStore) => {
      return {
        latencyStats: [stats, ...state.latencyStats],
      };
    }),
  reset: (reserveAgentType = false) => {
    set((state: CallStore) => ({
      ...initialCallState,
      agentType: reserveAgentType ? state.agentType : undefined,
    }));
  },
}));

export default useCallStore;
