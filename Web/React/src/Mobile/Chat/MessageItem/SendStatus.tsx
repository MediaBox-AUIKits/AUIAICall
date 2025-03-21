import { useContext } from 'react';
import { Button, SpinLoading } from 'antd-mobile';
import { AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';

import ChatEngineContext from '../ChatEngineContext';
import { resendSVG } from '../Icons';

function MessageItemSendStatus({ message }: { message: AIChatMessage }) {
  const engine = useContext(ChatEngineContext);
  const resend = () => {
    engine?.sendMessage(message);
  };

  if (message.messageState !== AIChatMessageState.Transfering && message.messageState !== AIChatMessageState.Failed)
    return null;

  return (
    <div className='_status'>
      {message.messageState === AIChatMessageState.Transfering && (
        <SpinLoading style={{ '--size': '16px' }} color='#624AFF' />
      )}
      {message.messageState === AIChatMessageState.Failed && <Button onClick={resend}>{resendSVG}</Button>}
    </div>
  );
}

export default MessageItemSendStatus;
