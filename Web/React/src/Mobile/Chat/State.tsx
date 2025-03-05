import { AIChatEngineState } from 'aliyun-auikit-aicall';
import useChatStore from './store';
import { Dialog, SpinLoading } from 'antd-mobile';
import { getRootElement } from '@/common/utils';

import './state.less';
import { Action } from 'antd-mobile/es/components/dialog';

function ChatState({ onExit }: { onExit: () => void }) {
  const state = useChatStore((state) => state.chatState);

  if (state === AIChatEngineState.Connected) return null;

  let content: React.ReactNode = (
    <div>
      <SpinLoading style={{ '--size': '48px' }} />
      <div>接通中</div>
    </div>
  );
  let actions: Action[] = [];

  if (state === AIChatEngineState.Disconnect) {
    content = '连接已断开';
    actions = [
      {
        key: 'exit',
        text: '退出',
        onClick: () => {
          onExit?.();
        },
      },
    ];
  }

  return (
    <Dialog
      className={
        state === AIChatEngineState.Connecting || state === AIChatEngineState.Init ? 'chat-state-loading-dialog' : ''
      }
      visible
      content={content}
      getContainer={getRootElement}
      closeOnAction
      actions={actions}
    />
  );
}

export default ChatState;
