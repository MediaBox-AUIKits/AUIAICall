import { create } from 'zustand';

import { lastOfArray } from '@/common/utils';
import { AIChatEngineState, AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';

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
  historyMessages: (messages: AIChatMessage[], userId: string) => void;
  interruptAgent: () => void;
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
  | 'reset'
> => ({
  chatState: AIChatEngineState.Init,
  sessionId: undefined,
  messageList: [],
  currentMessage: undefined,
  voiceIdList: [],
  voiceId: '',
  playingMessageId: undefined,
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
      console.log('updateSendMessage', message, state.currentMessage);
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

      // 添加 Message
      // 1. 没有消息
      // 2. 当前消息为发送
      // 3. 当前消息 requestId 不相同
      if (!currentMessage || currentMessage?.isSend || currentMessage?.message.requestId !== message.requestId) {
        if (currentMessage?.isProcessing) {
          flushMessage(state.messageList, currentMessage);
        }
        newState.messageList = [...state.messageList, newReceiveMessage];
      }

      // 当前消息明确已结束
      if (message.isEnd && currentMessage?.message.requestId === message.requestId) {
        flushMessage(state.messageList, currentMessage);
        newState.messageList = [...state.messageList];
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
  historyMessages: (messages: AIChatMessage[], userId: string) =>
    set((state: ChatStore) => {
      const newState: Partial<ChatStore> = {};
      const chatMessageList = messages.map((message) => ({
        message,
        isSend: message.senderId === userId,
        isProcessing: false,
      }));
      newState.messageList = [...chatMessageList, ...state.messageList];
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

  reset: () => set(getInitialChatState()),
}));

useChatStore.subscribe((state, prevState) => {
  if (!state.sessionId) return;
  if (state.messageList !== prevState.messageList) {
    const last20items = state.messageList.slice(-20);
    last20items.forEach((item) => {
      if (item.message.messageState === AIChatMessageState.Transfering) {
        item.message.messageState = AIChatMessageState.Interrupted;
      }
    });
    localStorage.setItem(`${messageCachePrefix}${state.sessionId}`, JSON.stringify(last20items));
    return;
  }
});

export default useChatStore;
