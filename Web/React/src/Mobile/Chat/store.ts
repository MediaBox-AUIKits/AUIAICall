import { create } from 'zustand';

import { AIChatAgentResponseState, AIChatAttachment, AIChatEngineState, AIChatMessage } from 'aliyun-auikit-aicall';

const MAX_CACHE_LENGTH = 20;

export interface ChatMessageItem {
  message: AIChatMessage;
  isSend?: boolean;
}

interface ChatStore {
  chatState: AIChatEngineState;
  chatResponseState: AIChatAgentResponseState;
  sessionId?: string;
  messageList: ChatMessageItem[];
  voiceIdList: string[];
  voiceId: string;
  playingMessageId?: string;
  sendMessage: (message: AIChatMessage) => void;
  updateSendMessage: (message: AIChatMessage) => void;
  receiveMessage: (message: AIChatMessage) => void;
  deleteMessage: (message: AIChatMessage) => void;
  historyMessages: (messages: AIChatMessage[], userId: string, isUpdateRecent?: boolean) => void;
  interruptAgent: () => void;

  attachmentList: AIChatAttachment[];
  addAttachment: (attachment: AIChatAttachment) => void;
  removeAttachment: (attachmentId: string) => void;
  attachmentCanSend: boolean;

  // 更新消息列表，不修改内容，当前主要作用是触发消息列表滚动到最后
  // update message list without updating message list content, just trigger message list scroll to bottom
  updateMessageList: () => void;
  reset: () => void;
}

export const messageCachePrefix = 'chatcall-message-list-cache-';

const getInitialChatState = (): Omit<
  ChatStore,
  | 'sendMessage'
  | 'updateSendMessage'
  | 'receiveMessage'
  | 'deleteMessage'
  | 'historyMessages'
  | 'interruptAgent'
  | 'updateMessageList'
  | 'addAttachment'
  | 'removeAttachment'
  | 'reset'
> => ({
  chatState: AIChatEngineState.Init,
  chatResponseState: AIChatAgentResponseState.Listening,
  sessionId: undefined,
  messageList: [],
  voiceIdList: [],
  voiceId: '',
  playingMessageId: undefined,
  attachmentList: [],
  attachmentCanSend: true,
});

const useChatStore = create<ChatStore>((set) => ({
  ...getInitialChatState(),
  sendMessage: (message: AIChatMessage) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      const newSendMessage = { message, isSend: true, isProcessing: true };
      newState.messageList = [...state.messageList, newSendMessage];
      return newState;
    }),
  updateSendMessage: (message: AIChatMessage) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      // 当前 Message 为发送且 requestId 一致
      // current message is send and requestId is same
      const existMessageIndex = state.messageList.findIndex(
        (item) => item.isSend && item.message.requestId === message.requestId
      );
      if (existMessageIndex > -1) {
        state.messageList.splice(existMessageIndex, 1, { message, isSend: true });
      }

      return newState;
    }),
  receiveMessage: (message: AIChatMessage) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      const newReceiveMessage: ChatMessageItem = { message };

      const existMessageIndex = state.messageList.findIndex(
        (item) => !item.isSend && item.message.requestId === message.requestId && item.message.nodeId === message.nodeId
      );

      if (existMessageIndex > -1) {
        state.messageList.splice(existMessageIndex, 1, newReceiveMessage);
      } else {
        state.messageList.push(newReceiveMessage);
      }
      newState.messageList = [...state.messageList];

      return newState;
    }),
  deleteMessage: (message: AIChatMessage) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      newState.messageList = state.messageList.filter((item) => item.message.dialogueId !== message.dialogueId);
      return newState;
    }),

  historyMessages: (messages: AIChatMessage[], userId: string, isUpdateRecent = false) =>
    set((state: ChatStore) => {
      // 可能已经下拉获取更多，直接跳过
      // maybe already pull more, skip
      if (state.messageList.length > MAX_CACHE_LENGTH) {
        return state;
      }

      const newState: Partial<ChatStore> = {};
      const chatMessageList = messages.map((message) => ({
        message,
        isSend: message.senderId === userId,
        isProcessing: false,
      }));

      if (isUpdateRecent) {
        newState.messageList = chatMessageList;
      } else {
        newState.messageList = [...chatMessageList, ...state.messageList];
      }
      return newState;
    }),

  interruptAgent: () =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      newState.messageList = [...state.messageList];
      return newState;
    }),
  updateMessageList: () =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      newState.messageList = [...state.messageList];
      return newState;
    }),

  addAttachment: (attachment: AIChatAttachment) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      newState.attachmentList = [...state.attachmentList, attachment];
      return newState;
    }),

  removeAttachment: (attachmentId: string) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      newState.attachmentList = state.attachmentList.filter((item) => item.id !== attachmentId);
      return newState;
    }),

  reset: () => set(getInitialChatState()),
}));

useChatStore.subscribe((state, prevState) => {
  if (!state.sessionId) return;
  if (state.messageList !== prevState.messageList) {
    const lastCacheItems = state.messageList.slice(0 - MAX_CACHE_LENGTH);

    localStorage.setItem(`${messageCachePrefix}${state.sessionId}`, JSON.stringify(lastCacheItems));
    return;
  }
});

export default useChatStore;
