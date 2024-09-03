import { create } from 'zustand';

import { AICallAgentState, AICallState, AICallSubtitleData } from '../aiCall/type';
import { AICallAgentInfo } from '../api/type';

type SubtitleItem = {
  data: AICallSubtitleData;
  source: 'agent' | 'user';
};

interface CallStore {
  // 通话状态
  callState: AICallState;
  // 通话错误
  callErrorMessage?: string;

  // Agent 信息
  agentInfo?: AICallAgentInfo;

  // Agent 状态
  agentState: AICallAgentState;

  // 是否正在说话
  isSpeaking: boolean;

  // 字幕
  currentSubtitle?: SubtitleItem;
  subtitleList: SubtitleItem[];
  setCurrentSubtitle: (subtitle: SubtitleItem) => void;

  enableVoiceInterrupt: boolean;
  updatingVoiceInterrupt: boolean;

  voiceId: string;
  updatingVoiceId: boolean;

  microphoneMuted: boolean;

  reset: () => void;
}

const initialCallState: Omit<CallStore, 'setCurrentSubtitle' | 'reset'> = {
  callState: AICallState.None,
  agentInfo: undefined,
  agentState: AICallAgentState.Listening,
  isSpeaking: false,
  currentSubtitle: undefined,
  subtitleList: [],
  enableVoiceInterrupt: true,
  updatingVoiceInterrupt: false,
  voiceId: 'zhixiaoxia',
  updatingVoiceId: false,
  microphoneMuted: false,
};

const useCallStore = create<CallStore>((set) => ({
  ...initialCallState,
  setCurrentSubtitle: (subtitle) =>
    set((state: CallStore) => {
      let newSubtitle = subtitle;

      const currentSubtitle = state.currentSubtitle;
      // agent 的字幕连续出现，进行拼接
      if (
        subtitle.source === 'agent' &&
        currentSubtitle?.source === 'agent' &&
        subtitle.data.sentenceId === currentSubtitle.data?.sentenceId
      ) {
        currentSubtitle.data.text = currentSubtitle.data.text + subtitle.data.text;
        currentSubtitle.data.end = subtitle.data.end;
        newSubtitle = currentSubtitle;
      }

      const newState: Partial<CallStore> = {
        currentSubtitle: { ...newSubtitle },
      };

      // 如果 end 则添加到 subtitleList
      if (newSubtitle.data.end && newSubtitle.data.text) {
        newState.subtitleList = [...state.subtitleList, newSubtitle];
      }
      return newState;
    }),
  reset: () => {
    set(initialCallState);
  },
}));

export default useCallStore;
