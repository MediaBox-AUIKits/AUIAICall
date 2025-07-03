import { create } from 'zustand';

import {
  AICallAgentState,
  AICallAgentType,
  AICallState,
  AICallSubtitleData,
  AICallVoiceprintResult,
} from 'aliyun-auikit-aicall';

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

  voiceId: string;
  updatingVoiceId: boolean;

  microphoneMuted: boolean;
  cameraMuted: boolean;

  agentVoiceIdList: string[];
  voiceAvatarUrl: string;

  reset: (reserveAgentType?: boolean) => void;
}

const initialCallState: Omit<CallStore, 'updateSubtitle' | 'reset'> = {
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
  voiceId: '',
  updatingVoiceId: false,
  microphoneMuted: false,
  cameraMuted: false,
  agentVoiceIdList: [],
  voiceAvatarUrl: '',
};

const useCallStore = create<CallStore>((set) => ({
  ...initialCallState,
  updateSubtitle: (subtitle) =>
    set((state: CallStore) => {
      const newState: Partial<CallStore> = {};

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
  reset: (reserveAgentType = false) => {
    set((state: CallStore) => ({
      ...initialCallState,
      agentType: reserveAgentType ? state.agentType : undefined,
    }));
  },
}));

export default useCallStore;
