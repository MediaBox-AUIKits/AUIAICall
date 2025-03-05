import { Button, Popup, Radio, SafeArea, Space } from 'antd-mobile';
import './header.less';
import { backSVG, settingSVG } from './Icons';
import useChatStore from './store';
import { getRootElement } from '@/common/utils';
import { useContext, useState } from 'react';
import { VoiceOneSVG, VoiceThreeSVG, VoiceTwoSVG } from '../Call/Icons';

import ChatEngineContext from './ChatEngineContext';

function ChatHeader({ onBack }: { onBack: () => void }) {
  const engine = useContext(ChatEngineContext);
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
      <div className='_title'>小云</div>
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
        <div className='_title'>设置</div>
        <ul>
          {voiceIdList.length > 0 && (
            <li className='_voiceId'>
              <div className='_itemBox'>
                <div className='_itemInfo'>
                  <div className='_itemTitle'>选择音色</div>
                  <div className='_itemDesc'>切换音色后，AI将在下一次回答中使用新的音色</div>
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
