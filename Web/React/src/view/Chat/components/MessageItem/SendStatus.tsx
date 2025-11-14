import { AIChatAttachmentUploader, AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';
import { Button, SpinLoading } from 'antd-mobile';
import { useContext } from 'react';

import ChatEngineContext from 'chat/ChatEngineContext';

import { resendSVG } from '../Icons';

function MessageItemSendStatus({ message }: { message: AIChatMessage }) {
  const engine = useContext(ChatEngineContext);
  const resend = () => {
    let uploader: AIChatAttachmentUploader | undefined;
    if (message.attachmentList.length > 0) {
      uploader = new AIChatAttachmentUploader();
      uploader.attachmentList = message.attachmentList;
    }
    engine?.sendMessage(message, uploader);
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
