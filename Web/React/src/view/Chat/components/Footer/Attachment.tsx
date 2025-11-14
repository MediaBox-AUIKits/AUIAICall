import { AIChatAttachment, AIChatAttachmentState, AIChatAttachmentUploader } from 'aliyun-auikit-aicall';
import { Button, ImageViewer } from 'antd-mobile';
import { RefObject, useEffect, useMemo, useState } from 'react';

import { getRootElement } from '@/common/utils';
import { attachmentRemoveSVG, attachmentUploadFailSVG } from 'chat/components/Icons';
import useChatStore from 'chat/store.ts';

function Progress({ attachment }: { attachment: AIChatAttachment }) {
  const [progress, setProgress] = useState(attachment.progress);

  useEffect(() => {
    const updateProgress = (v: number) => {
      setProgress(v);
    };
    attachment.on('progress', updateProgress);
    return () => {
      attachment.off('progress', updateProgress);
    };
  }, [attachment]);

  const circumference = 9 * 2 * Math.PI;

  return (
    <div className='_progress'>
      <svg className='_svg' width='22' height='22'>
        <circle
          className='_progress-background'
          stroke='rgba(255,255,255,.7)'
          strokeWidth='2'
          fill='transparent'
          r='9'
          cx='11'
          cy='11'
        />
        <circle
          className='_progress-circle'
          stroke='#fff'
          strokeWidth='2'
          fill='transparent'
          r='9'
          cx='11'
          cy='11'
          style={{
            strokeDasharray: `${circumference} ${circumference}`,
            strokeDashoffset: circumference - (progress / 100) * circumference,
          }}
        />
      </svg>
    </div>
  );
}

function ChatFooterAttachment({
  attachment,
  uploaderRef,
}: {
  attachment: AIChatAttachment;
  uploaderRef: RefObject<AIChatAttachmentUploader | undefined>;
}) {
  const [state, setState] = useState(attachment.state);

  const url = useMemo(() => {
    if (attachment.path) return attachment.path;
    return '';
  }, [attachment.path]);

  useEffect(() => {
    const updateState = (v: AIChatAttachmentState) => {
      setState(v);
    };
    attachment.on('stateChange', updateState);
    return () => {
      attachment.off('stateChange', updateState);
    };
  }, [attachment]);

  const cancelDownload = () => {
    uploaderRef.current?.removeAttachment(attachment.id);
    useChatStore.getState().removeAttachment(attachment.id);
    useChatStore.setState({
      attachmentCanSend: !uploaderRef.current || uploaderRef.current.allUploadSuccess,
    });
  };

  const onImageClick = (imageUrl: string) => {
    ImageViewer.show({
      image: imageUrl,
      getContainer: getRootElement,
    });
  };

  return (
    <li>
      <div className='_preview'>
        <img src={url} alt={attachment.name || ''} onClick={() => onImageClick(url)} />
      </div>

      {state === AIChatAttachmentState.Uploading && <Progress attachment={attachment} />}
      {state === AIChatAttachmentState.Failed && <div className='_failed'>{attachmentUploadFailSVG}</div>}

      <Button fill='none' className='_remove' onClick={cancelDownload}>
        {attachmentRemoveSVG}
      </Button>
    </li>
  );
}

export default ChatFooterAttachment;
