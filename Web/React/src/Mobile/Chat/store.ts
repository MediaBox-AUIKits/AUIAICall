import { create } from 'zustand';

import { lastOfArray } from '@/common/utils';
import { AIChatAttachment, AIChatEngineState, AIChatMessage } from 'aliyun-auikit-aicall';

const MAX_CACHE_LENGTH = 20;

export interface ChatMessageItem {
  message: AIChatMessage;
  isSend?: boolean;
  isProcessing?: boolean;
}

interface ChatStore {
  chatState: AIChatEngineState;
  sessionId?: string;
  messageList: ChatMessageItem[];
  currentMessage?: ChatMessageItem;
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
  sessionId: undefined,
  messageList: [],
  currentMessage: undefined,
  voiceIdList: [],
  voiceId: '',
  playingMessageId: undefined,
  attachmentList: [],
  attachmentCanSend: true,
});

/**
 * 刷新接收消息
 * @param message
 * @param messageList
 * @note 注意！此操作会原地修改 messageList 的最后一个消息，如果不符合预期返回 false
 */
const flushMessage = (messageList: ChatMessageItem[], messageItem?: ChatMessageItem): boolean => {
  const lastMessageItem = lastOfArray(messageList);
  const lastMessage = lastMessageItem?.message;
  if (!lastMessage) {
    return false;
  }

  if (
    !!lastMessageItem?.isSend === !!messageItem?.isSend &&
    lastMessage?.requestId === messageItem?.message.requestId
  ) {
    lastMessageItem.message = messageItem.message;
    lastMessageItem.isProcessing = false;
    return true;
  }
  return false;
};

const useChatStore = create<ChatStore>((set) => ({
  ...getInitialChatState(),
  sendMessage: (message: AIChatMessage) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      // 当前为收消息阶段
      if (
        (state.currentMessage && !state.currentMessage.isSend) ||
        state.currentMessage?.message.requestId !== message.requestId
      ) {
        flushMessage(state.messageList, state.currentMessage);
      }
      const newSendMessage = { message, isSend: true, isProcessing: true };
      newState.currentMessage = newSendMessage;
      newState.messageList = [...state.messageList, newSendMessage];
      return newState;
    }),
  updateSendMessage: (message: AIChatMessage) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      // 当前 Message 为发送且 requestId 一致
      if (state.currentMessage?.isSend && state.currentMessage?.message.requestId === message.requestId) {
        const newSendMessage = { message, isSend: true };
        if (message.isEnd) {
          flushMessage(state.messageList, newSendMessage);
        }
        newState.currentMessage = newSendMessage;
      } else {
        const existMessageIndex = state.messageList.findIndex((item) => item.message.requestId === message.requestId);
        if (existMessageIndex > -1) {
          state.messageList.splice(existMessageIndex, 1, { message, isSend: true });
        }
      }
      return newState;
    }),
  receiveMessage: (message: AIChatMessage) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      const newReceiveMessage: ChatMessageItem = { message, isProcessing: true };
      const currentMessage = state.currentMessage;

      // 添加 Message 到展示列表
      // 1. 没有消息
      // 2. 当前消息为发送
      // 3. 当前消息 requestId 不相同
      if (!currentMessage || currentMessage?.isSend || currentMessage?.message.requestId !== message.requestId) {
        if (currentMessage?.isProcessing) {
          flushMessage(state.messageList, currentMessage);
        }
        newState.messageList = [...state.messageList, newReceiveMessage];
      } else if (message.isEnd) {
        // 如果 message 结束，标记为已结束
        flushMessage(state.messageList, newReceiveMessage);
      }

      newState.currentMessage = newReceiveMessage;
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
      if (state.currentMessage && !state.currentMessage.isSend) {
        flushMessage(state.messageList, state.currentMessage);
      }
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
