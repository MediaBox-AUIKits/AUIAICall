import { memo, MouseEventHandler } from 'react';
import { AIChatMessage } from 'aliyun-auikit-aicall';

import './sendAttachment.less';
import { ImageViewer } from 'antd-mobile';
import { getRootElement } from '@/common/utils';

const CachedImage = memo((props: { src: string; name: string; onClick: MouseEventHandler<HTMLImageElement> }) => {
  return <img {...props} />;
});

function SendAttachment({ message }: { message: AIChatMessage }) {
  if ((message.attachmentList || []).length === 0) {
    return null;
  }

  const onImageClick = (imageUrl: string) => {
    ImageViewer.show({
      image: imageUrl,
      getContainer: getRootElement,
    });
  };

  return (
    <div className='_send-attachment'>
      <ul>
        {(message.attachmentList || []).map((item) => {
          return (
            <li key={item.id}>
              <CachedImage src={item.path} name={item.name} onClick={() => onImageClick(item.path)} />
            </li>
          );
        })}
      </ul>
    </div>
  );
}

export default SendAttachment;
