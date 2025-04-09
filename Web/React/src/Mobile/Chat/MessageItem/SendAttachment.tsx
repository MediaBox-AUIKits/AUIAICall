import { AIChatMessage } from 'aliyun-auikit-aicall';

import './sendAttachment.less';
import { memo } from 'react';

const CachedImage = memo((props: { src: string; name: string }) => {
  return <img {...props} />;
});

function SendAttachment({ message }: { message: AIChatMessage }) {
  if ((message.attachmentList || []).length === 0) {
    return null;
  }

  return (
    <div className='_send-attachment'>
      <ul>
        {(message.attachmentList || []).map((item) => {
          return (
            <li key={item.id}>
              <CachedImage src={item.path} name={item.name} />
            </li>
          );
        })}
      </ul>
    </div>
  );
}

export default SendAttachment;
