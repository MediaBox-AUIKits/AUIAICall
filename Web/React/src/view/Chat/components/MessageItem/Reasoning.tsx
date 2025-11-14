import { AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';
import { Button } from 'antd-mobile';
import { useState } from 'react';

import { useTranslation } from '@/common/i18nContext';

import { reasoningEndSVG, reasoningExpandSVG } from '../Icons';
import MessageItemTextLineRender from './TextLineRender';

function MessageItemReasoning({ message }: { message: AIChatMessage }) {
  const { t } = useTranslation();
  const [expanded, setExpanded] = useState(true);

  if (!message?.reasoningText) return null;

  let titleText = t('chat.response.reasoninging');
  if (message.isReasoningEnd) {
    titleText = t('chat.response.reasoningCompleted');
  } else if (message.messageState === AIChatMessageState.Interrupted) {
    titleText = t('chat.response.reasoningInterrupted');
  }

  const toggleExpanded = () => {
    setExpanded((prev) => !prev);
  };

  return (
    <div className='_reasoning'>
      <div className='_reasoning-title'>
        {message.isReasoningEnd && <span className='_reasoning-end-icon'>{reasoningEndSVG}</span>}
        <span>{titleText}</span>
        <Button className={`_reasoning-expand-btn ${expanded ? 'is-expanded' : ''}`} onClick={toggleExpanded}>
          {reasoningExpandSVG}
        </Button>
      </div>
      {expanded && (
        <div className='_reasoning-text'>
          <MessageItemTextLineRender text={message.reasoningText} />
        </div>
      )}
    </div>
  );
}

export default MessageItemReasoning;
