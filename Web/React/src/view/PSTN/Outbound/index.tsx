import { AICallAgentConfig, AICallAgentError, AICallAgentType, AICallConfig } from 'aliyun-auikit-aicall';
import { Button, Form, Input, Selector, Switch } from 'antd-mobile';
import { ExclamationCircleFill } from 'antd-mobile-icons';
import { useEffect, useMemo, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { copyText } from '@/common/utils';
import standard from '@/service/standard';
import settingVoiceImg1 from '@/view/images/setting_voice_1.png';
import settingVoiceImg2 from '@/view/images/setting_voice_2.png';
import { settingSelectedSVG } from 'call/components/Icons';
import Header from 'components/Header';
import ResponsivePopup from 'components/ResponsivePopup';

import { callFailSVG, callSuccessSVG } from '../Icons';

import './index.less';


const agentVoiceIdList = ['1185:云峰', '11:云穹', '1397:云薇', '1151:云玲'];

function VoiceIdPicker({
  value,
  onChange,
  visible = false,
  setVoiceIdVisible,
}: {
  value?: string;
  onChange?: (value: string) => void;
  visible: boolean;
  setVoiceIdVisible: (visible: boolean) => void;
}) {
  const { t } = useTranslation();

  const displayName = useMemo(() => {
    const matchItem = agentVoiceIdList.find((voiceId) => voiceId.split(':')[0] === String(value || ''));
    if (matchItem) {
      const [id, value] = matchItem.split(':');
      return value || id;
    }
    return '';
  }, [value]);

  return (
    <>
      {displayName}
      <ResponsivePopup
        className='responsive-dialog'
        visible={visible}
        closeOnMaskClick
        onClose={() => setVoiceIdVisible(false)}
        title={t('pstn.outbound.voiceId.title')}
      >
        <Selector
          className='ai-voice-selector'
          columns={1}
          options={agentVoiceIdList.map((voiceId, index) => {
            const [id, value] = voiceId.split(':');
            return {
              label: (
                <div className='_voice-id-item'>
                  <img src={index % 2 === 0 ? settingVoiceImg1 : settingVoiceImg2} alt='' />
                  <span className='_title'>{value || id}</span>
                  <div className='ai-flex-1'></div>
                  <div className='_tip'>
                    <span className='_tip-text'>{t('pstn.outbound.voiceId.use')}</span>
                    {settingSelectedSVG}
                  </div>
                </div>
              ),
              value: id,
            };
          })}
          value={value ? [value] : []}
          onChange={(v) => {
            if (v.length) {
              onChange?.(v[0] as string);
              setVoiceIdVisible(false);
            }
          }}
        />
      </ResponsivePopup>
    </>
  );
}

function PSTNOutbound({
  userId,
  agentId,
  region,
  onExit,
  onAuthFail,
}: {
  userId: string;
  agentId: string;
  region: string;
  onExit: () => void;
  onAuthFail: () => void;
}) {
  const { t } = useTranslation();
  const [form] = Form.useForm();
  const [voiceIdVisible, setVoiceIdVisible] = useState(false);
  const [submittable, setSubmittable] = useState(false);

  const [result, setResult] = useState<{ instanceId: string; reqId: string } | null>(null);
  const [error, setError] = useState<Error | null>(null);

  const onSubmit = async () => {
    const values = await form.validateFields();
    if (!values) return;

    const config: AICallConfig = {
      agentId,
      agentType: AICallAgentType.VoiceAgent,
      region: region || 'cn-shanghai',
      userId,
      userJoinToken: '',
      agentConfig: new AICallAgentConfig(),
    };


    if (!values.interrupt) {
      if (config.agentConfig) {
        config.agentConfig.interruptConfig.enableVoiceInterrupt = false;
      }
    }

    if (values.voiceId) {
      if (config.agentConfig) {
        config.agentConfig.ttsConfig.agentVoiceId = values.voiceId;
      }
    }

    try {
      const result = await standard.startAIAgentOutboundCall(userId, values.phone, config);
      setResult(result);
    } catch (error) {
      if ((error as AICallAgentError).name === 'ServiceAuthError') {
        onAuthFail();
        return;
      }
      setError(error as Error);
    }
  };

  const formPhone = Form.useWatch('phone', form);
  useEffect(() => {
    form
      .validateFields(['phone'], { validateOnly: true })
      .then(() => setSubmittable(true))
      .catch(() => setSubmittable(false));
  }, [form, formPhone]);

  const checkMobile = (_: unknown, value: string) => {
    const _value = value.trim();
    if (!_value) {
      return Promise.reject(new Error(t('pstn.outbound.phone.required')));
    }
    if (/^1[3-9]\d{9}$/.test(_value)) {
      return Promise.resolve();
    }
    return Promise.reject(new Error(t('pstn.outbound.phone.error')));
  };

  return (
    <>
      <Header title={t('pstn.outbound.title')} onExit={onExit} actions={null} />
      <div className='stage-bd pstn-bd'>
        {result || error ? (
          <>
            <div className='pstn-call-result'>
              <div className='_icon'>{error ? callFailSVG : callSuccessSVG}</div>
              <div className='_text'>
                {error
                  ? t('pstn.outbound.result.fail', {
                      code: `${(error as AICallAgentError).code}`,
                    })
                  : t('pstn.outbound.result.success')}
              </div>
              <div className='_req-id'>
                {/* @ts-expect-error reqId */}
                ID:{result?.reqId || error?.reqId || '-'}
                <Button
                  onClick={() => {
                    // @ts-expect-error reqId
                    copyText(result?.reqId || error?.reqId || '-');
                  }}
                >
                  {t('pstn.outbound.result.copy')}
                </Button>
              </div>
            </div>
          </>
        ) : (
          <>
            <Form
              layout='horizontal'
              className='ai-form pstn-form'
              form={form}
              initialValues={{
                phone: '',
                interrupt: true,
                voiceId: '1185',
              }}
            >
              <Form.Item
                layout='vertical'
                name='phone'
                className='_phone no-border'
                label={t('pstn.outbound.phone.label')}
                rules={[{ validator: checkMobile }]}
              >
                <Input type='number' placeholder={t('pstn.outbound.phone.placeholder')} />
              </Form.Item>
              <Form.Item className='is-follow' layout='vertical' description={t('pstn.outbound.phone.tip')}></Form.Item>
              <Form.Item
                label={t('pstn.outbound.interrupt.label')}
                name='interrupt'
                childElementPosition='right'
                valuePropName='checked'
              >
                <Switch style={{ '--height': '24px', '--width': '44px' }} />
              </Form.Item>
              <Form.Item
                label={t('pstn.outbound.voiceId.label')}
                name='voiceId'
                childElementPosition='right'
                arrowIcon
                onClick={() => setVoiceIdVisible(true)}
              >
                <VoiceIdPicker visible={voiceIdVisible} setVoiceIdVisible={setVoiceIdVisible} />
              </Form.Item>
              <Form.Item className='_help no-border'>
                <ExclamationCircleFill color='var(--adm-color-primary)' />
                {t('pstn.outbound.help')}
              </Form.Item>
            </Form>

            <div className='_holder' />

            <div className='pstn-btn-box'>
              <Button fill='none' color='primary' block onClick={onSubmit} disabled={!submittable}>
                {t('pstn.outbound.start')}
              </Button>
              <div className='ai-statement'>{t('system.statement')}</div>
            </div>
          </>
        )}
      </div>
    </>
  );
}

export default PSTNOutbound;
