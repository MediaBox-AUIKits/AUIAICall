import { Button, Form, Selector } from 'antd-mobile';
import { useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import logger from '@/common/logger';
import { headerSettingSVG, settingSelectedSVG } from 'call/components/Icons';

import ResponsivePopup from '@/view/components/ResponsivePopup';
import settingVoiceImg1 from '@/view/images/setting_voice_1.png';
import settingVoiceImg2 from '@/view/images/setting_voice_2.png';
import useChatStore from '../store';

function Setting() {
  const { t } = useTranslation();
  const voiceIdList = useChatStore((state) => state.voiceIdList);
  const voiceId = useChatStore((state) => state.voiceId);
  const [settingVisible, setSettingVisible] = useState(false);

  return (
    <>
      <Button
        className='_setting-btn'
        fill='none'
        disabled={voiceIdList.length === 0}
        onClick={() => {
          logger.info('Header', 'Chat OpenSetting');
          setSettingVisible(true);
        }}
      >
        {headerSettingSVG}
        <span className='_text'>{t('settings.title')}</span>
      </Button>
      <ResponsivePopup
        title={t('settings.title')}
        visible={settingVisible}
        onClose={() => {
          setSettingVisible(false);
        }}
      >
        <Form layout='horizontal' className='ai-form ai-setting-form'>

          {(voiceIdList.length || 0) > 0 && (
            <>
              <Form.Item
                layout='vertical'
                label={t('settings.voiceId.title')}
                description={t('settings.voiceId.help')}
              />

              <Form.Item className='_voice-id is-follow'>
                <Selector
                  columns={1}
                  options={voiceIdList.map((voiceId, index) => {
                    return {
                      label: (
                        <div className='_voice-id-item'>
                          <img src={index % 2 === 0 ? settingVoiceImg1 : settingVoiceImg2} alt='' />
                          <span className='_title'>{voiceId}</span>
                          <div className='ai-flex-1'></div>
                          <div className='_tip'>
                            <span className='_tip-text'>{t('settings.voiceId.use')}</span>
                            {settingSelectedSVG}
                          </div>
                        </div>
                      ),
                      value: voiceId,
                    };
                  })}
                  value={[voiceId]}
                  onChange={(v) => {
                    if (v.length) {
                      useChatStore.setState({ voiceId: v[0] as string });
                    }
                  }}
                />
              </Form.Item>
            </>
          )}
        </Form>
      </ResponsivePopup>
    </>
  );
}

export default Setting;
