import { useState } from 'react';
import { Button } from 'antd-mobile';
import { AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';
import { reasoningEndSVG, reasoningExpandSVG } from '../Icons';
import MessageItemTextLineRender from './TextLineRender';

function MessageItemReasoning({ message }: { message: AIChatMessage }) {
  const [expanded, setExpanded] = useState(true);

  if (!message?.reasoningText) return null;

  let titleText = '思考中';
  if (message.isReasoningEnd) {
    titleText = '思考完成';
  } else if (message.messageState === AIChatMessageState.Interrupted) {
    titleText = '思考停止';
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
