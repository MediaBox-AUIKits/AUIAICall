import { Button, Popup, Radio, SafeArea, Space } from 'antd-mobile';
import './header.less';
import { backSVG, settingSVG } from './Icons';
import useChatStore from './store';
import { getRootElement } from '@/common/utils';
import { useState } from 'react';
import { VoiceOneSVG, VoiceThreeSVG, VoiceTwoSVG } from '../Call/Icons';
import { useTranslation } from '@/common/i18nContext';


function ChatHeader({ onBack }: { onBack: () => void }) {
  const { t } = useTranslation();
  const voiceIdList = useChatStore((state) => state.voiceIdList);
  const voiceId = useChatStore((state) => state.voiceId);
  const [settingVisible, setSettingVisible] = useState(false);


  return (
    <div className='chat-header'>
      <Button className='_back-btn' onClick={onBack}>
        {backSVG}
      </Button>
      <img
        src='https://img.alicdn.com/imgextra/i4/O1CN01fcswVF24BjIbLhA3C_!!6000000007353-2-tps-84-84.png'
        width={28}
        height={28}
        alt=''
      />
      <div className='_title'>{t('hero.name')}</div>
      <div className='_gap' />
      <Button className='_setting-btn' disabled={voiceIdList.length === 0} onClick={() => setSettingVisible(true)}>
        {settingSVG}
      </Button>
      <Popup
        className='header-pop setting-pop'
        visible={settingVisible}
        getContainer={() => getRootElement()}
        onMaskClick={() => {
          setSettingVisible(false);
        }}
        onClose={() => {
          setSettingVisible(false);
        }}
      >
        <div className='_title'>{t('settings.title')}</div>
        <ul>
          {voiceIdList.length > 0 && (
            <li className='_voiceId'>
              <div className='_itemBox'>
                <div className='_itemInfo'>
                  <div className='_itemTitle'>{t('settings.voiceId.title')}</div>
                  <div className='_itemDesc'>{t('settings.voiceId.help')}</div>
                </div>
              </div>
              <Radio.Group
                value={voiceId}
                onChange={(v) => {
                  if (v as string) {
                    useChatStore.setState({ voiceId: v as string });
                  }
                }}
              >
                <Space direction='vertical' block>
                  {voiceIdList.map((voiceId, index) => {
                    const iconIndex = index % 3;
                    const VoiceSVG = [VoiceOneSVG, VoiceTwoSVG, VoiceThreeSVG][iconIndex];
                    return (
                      <Radio key={voiceId} value={voiceId}>
                        <span className='_voiceIcon'>{VoiceSVG}</span>
                        <span className='_voiceName'>{voiceId}</span>
                      </Radio>
                    );
                  })}
                </Space>
              </Radio.Group>
            </li>
          )}
        </ul>
        <SafeArea position='bottom' />
      </Popup>
    </div>
  );
}

export default ChatHeader;
