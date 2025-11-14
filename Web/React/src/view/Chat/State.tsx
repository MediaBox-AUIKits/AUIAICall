import { AIChatEngineState } from 'aliyun-auikit-aicall';
import { Dialog, SpinLoading } from 'antd-mobile';
import { Action } from 'antd-mobile/es/components/dialog';

import { useTranslation } from '@/common/i18nContext';
import { getRootElement } from '@/common/utils';

import useChatStore from './store';

import './state.less';

function ChatState({ onExit }: { onExit: () => void }) {
  const { t } = useTranslation();
  const state = useChatStore((state) => state.chatState);

  if (state === AIChatEngineState.Connected) return null;

  let content: React.ReactNode = (
    <div>
      <SpinLoading style={{ '--size': '48px' }} />
      <div>{t('chat.connecting')}</div>
    </div>
  );
  let actions: Action[] = [];

  if (state === AIChatEngineState.Disconnect) {
    content = t('chat.disconnected');
    actions = [
      {
        key: 'exit',
        text: t('common.exit'),
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
