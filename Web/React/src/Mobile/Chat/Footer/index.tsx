import { AICallRunConfig } from '@/interface.ts';
import { useContext, useEffect, useRef, useState } from 'react';
import { Button, Popup, Toast } from 'antd-mobile';

import {
  openExtraSVG,
  imageUploadSVG,
  toVoiceSVG,
  toAvatarSVG,
  toVisionSVG,
  closeExtraSVG,
  attachmentAddSVG,
} from '../Icons';
import ChatEngineContext from '../ChatEngineContext';
import { AICallAgentType, AICallChatSyncConfig } from 'aliyun-auikit-aicall';
import { getRootElement } from '@/common/utils';
import VoiceSender from './VoiceSender';
import TextSender from '../Footer/TextSender';
import './index.less';
import { AIChatAttachment, AIChatAttachmentUploader } from 'aliyun-auikit-aicall';
import useChatStore from '@/Mobile/Chat/store.ts';
import Attachment from '@/Mobile/Chat/Footer/Attachment.tsx';
import resizeHandler from '@/Mobile/Chat/resizeHandler.ts';
import Call from '@/Mobile/Call';
import { useTranslation } from '@/common/i18nContext';

const MAX_FILE_SIZE = 1024 * 1024 * 10;
const MAX_FILE_COUNT = 9;

function ChatFooter({ userId, userToken, rc }: { userId: string; userToken: string; rc: AICallRunConfig }) {
  const { t } = useTranslation();

  const [mode, setMode] = useState<'text' | 'voice'>('text');
  const engine = useContext(ChatEngineContext);

  const [callVisible, setCallVisible] = useState(false);
  const [callAgentType, setCallAgentType] = useState<AICallAgentType>(AICallAgentType.VoiceAgent);

  const [extraViewVisible, setExtraViewVisible] = useState(false);
  const attachmentList = useChatStore((state) => state.attachmentList);
  const uploaderRef = useRef<AIChatAttachmentUploader>();
  const attachmentEndRef = useRef<HTMLLIElement>(null);

  const onHeightUpdate = () => {
    resizeHandler.emit('resize', true);
  };

  useEffect(() => {
    onHeightUpdate();
  }, [extraViewVisible]);

  const onUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!engine) return;
    const files = e.target.files;
    if (attachmentList.length + (files?.length || 0) > MAX_FILE_COUNT) {
      Toast.show({
        getContainer: () => getRootElement(),
        content: t('chat.uploader.countLimit', { count: `${MAX_FILE_COUNT}` }),
      });
      return;
    }

    if (files && files.length > 0) {
      const svgFilteredFiles = Array.from(files).filter((file) => {
        if (file.type === 'image/svg+xml' || file.name.toLowerCase().endsWith('.svg')) {
          return false;
        }
        return true;
      });
      if (svgFilteredFiles.length !== files.length) {
        Toast.show({
          getContainer: () => getRootElement(),
          content: t('chat.uploader.noSVG'),
        });
      }

      const filteredFiles = svgFilteredFiles.filter((file) => file.size <= MAX_FILE_SIZE);
      if (svgFilteredFiles.length !== filteredFiles.length) {
        Toast.show({
          getContainer: () => getRootElement(),
          content: t('chat.uploader.sizeLimit', {
            size: `${MAX_FILE_SIZE / 1024 / 1024}M`,
          }),
        });
      }

      if (filteredFiles.length > 0) {
        if (!uploaderRef.current) {
          uploaderRef.current = await engine.createAttachmentUploader();
          uploaderRef.current.on('uploadSuccess', () => {
            useChatStore.setState({
              attachmentCanSend: !uploaderRef.current || uploaderRef.current.allUploadSuccess,
            });
          });
        }

        useChatStore.setState({
          attachmentCanSend: false,
        });

        filteredFiles.forEach((file) => {
          const attachment = AIChatAttachment.createImageAttachment(file);
          useChatStore.getState().addAttachment(attachment);
          uploaderRef.current?.addAttachment(attachment);
        });

        // 添加完成后如有必要，将继续添加按钮移动到画面中
        // if needed scroll add button to view
        setTimeout(() => {
          attachmentEndRef.current?.scrollIntoView();
        }, 100);
      }
    }
  };

  const onStartUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    setExtraViewVisible(false);
    onUpload(e);
    if (uploaderRef.current) {
      uploaderRef.current.destroy(true);
      uploaderRef.current = undefined;
    }
  };
  const afterSend = (success: boolean) => {
    // 发送成功，清空 uploader
    // send success, clear uploader
    if (success) {
      uploaderRef.current?.destroy();
      uploaderRef.current = undefined;
    }

    useChatStore.setState({
      attachmentList: [],
    });
  };

  const fromShare = new URLSearchParams(window.location.search).get('token');

  return (
    <>
      <div className='chat-footer'>
        <div className='_bd'>
          {attachmentList.length === 0 && (
            <Button className='_extra-btn' onClick={() => setExtraViewVisible(!extraViewVisible)}>
              {extraViewVisible ? closeExtraSVG : openExtraSVG}
            </Button>
          )}

          <div className='_send-area'>
            {mode === 'voice' ? (
              <VoiceSender onTypeChange={(type) => setMode(type)} uploaderRef={uploaderRef} afterSend={afterSend} />
            ) : (
              <TextSender onTypeChange={(type) => setMode(type)} uploaderRef={uploaderRef} afterSend={afterSend} />
            )}
          </div>
        </div>
        {extraViewVisible && (
          <ul className='_extra-actions'>
            <li>
              <div className='_upload-button'>
                {imageUploadSVG}
                <input type='file' accept='image/*' multiple onChange={onStartUpload} />
              </div>
              <div className='_extra-action-label'>
                <span>{t('chat.actions.album')}</span>
              </div>
            </li>
            {!fromShare && (
              <>
                <li>
                  <Button
                    onClick={() => {
                      setExtraViewVisible(false);
                      setCallAgentType(AICallAgentType.VoiceAgent);
                      setCallVisible(true);
                    }}
                  >
                    {toVoiceSVG}
                  </Button>
                  <div className='_extra-action-label'>
                    <span>{t('chat.actions.toVoice')}</span>
                  </div>
                </li>
                <li>
                  <Button
                    onClick={() => {
                      setExtraViewVisible(false);
                      setCallAgentType(AICallAgentType.AvatarAgent);
                      setCallVisible(true);
                    }}
                  >
                    {toAvatarSVG}
                  </Button>
                  <div className='_extra-action-label'>
                    <span>{t('chat.actions.toAvatar')}</span>
                  </div>
                </li>
                <li>
                  <Button
                    onClick={() => {
                      setExtraViewVisible(false);
                      setCallAgentType(AICallAgentType.VisionAgent);
                      setCallVisible(true);
                    }}
                  >
                    {toVisionSVG}
                  </Button>
                  <div className='_extra-action-label'>
                    <span>{t('chat.actions.toVision')}</span>
                  </div>
                </li>
              </>
            )}
          </ul>
        )}

        {attachmentList.length > 0 && (
          <div className='_attachments'>
            <ul>
              {attachmentList.map((attachment) => (
                <Attachment key={attachment.id} attachment={attachment} uploaderRef={uploaderRef} />
              ))}
              <li>
                <div className='_add'>
                  {attachmentAddSVG}
                  <input type='file' accept='image/*' multiple onChange={onUpload} />
                </div>
              </li>
              <li ref={attachmentEndRef} />
            </ul>
          </div>
        )}
      </div>
      <Popup
        visible={callVisible}
        onMaskClick={() => setCallVisible(false)}
        destroyOnClose
        getContainer={getRootElement}
        bodyStyle={{ height: '100%' }}
      >
        <Call
          rc={rc}
          userId={userId}
          userToken={userToken}
          agentType={callAgentType}
          chatSyncConfig={
            new AICallChatSyncConfig(
              engine?.sessionId || '',
              engine?.agentInfo?.agentId || '',
              engine?.userInfo?.userId || ''
            )
          }
          autoCall
          onExit={() => setCallVisible(false)}
        />
      </Popup>
    </>
  );
}

export default ChatFooter;
