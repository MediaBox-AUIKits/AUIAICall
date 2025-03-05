import { AIChatEngine } from 'aliyun-auikit-aicall';
import { createContext } from 'react';

const ChatEngineContext = createContext<AIChatEngine | null>(null);

export default ChatEngineContext;
