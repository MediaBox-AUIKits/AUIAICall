import { Button, Dialog, Form, Input, Radio, Space, Switch } from 'antd-mobile';
import { ExclamationCircleFill } from 'antd-mobile-icons';

import { AICallAgentConfig, AICallAgentError, AICallAgentType, AICallConfig } from 'aliyun-auikit-aicall';

import './index.less';
import { useEffect, useState } from 'react';
import { VoiceOneSVG, VoiceThreeSVG, VoiceTwoSVG } from '../../Call/Icons';
import { copyText, getRootElement } from '@/common/utils';
import { useTranslation } from '@/common/i18nContext';
import standard from '@/service/standard';
import { CallFailSVG, CallSuccessSVG } from '../Icons';
import Header from '../Header';

const agentVoiceIdList = [
  'longcheng_v2',
  'longhua_v2',
  'longshu_v2',
  'loongbella_v2',
  'longwan_v2',
  'longxiaochun_v2',
  'longxiaoxia_v2',
  'loongstella',
];

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

  return (
    <>
      {value}
      <Dialog
        className='responsive-dialog'
        visible={visible}
        closeOnAction
        closeOnMaskClick
        onClose={() => setVoiceIdVisible(false)}
        getContainer={getRootElement}
        title='音色选择'
        actions={[
          [
            {
              key: 'close',
              text: t('common.close'),
            },
          ],
        ]}
        bodyClassName='pstn-voice-id-picker'
        content={
          <Radio.Group value={value} onChange={(v) => onChange?.(v as string)}>
            <Space direction='vertical' block>
              {agentVoiceIdList.map((voiceId, index) => {
                const iconIndex = index % 3;
                const VoiceSVG = [VoiceOneSVG, VoiceTwoSVG, VoiceThreeSVG][iconIndex];
                return (
                  <Radio
                    key={voiceId}
                    value={voiceId}
                    style={{
                      // @ts-expect-error custom style
                      '--btn-text': JSON.stringify(t('common.use')),
                    }}
                  >
                    <span className='_voiceIcon'>{VoiceSVG}</span>
                    <span className='_voiceName'>{voiceId}</span>
                  </Radio>
                );
              })}
            </Space>
          </Radio.Group>
        }
      />
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
    <div className='stage-wrapper'>
      <div className='stage'>
        <Header
          title={t('pstn.outbound.title')}
          onExit={onExit}
          instanceId={result?.instanceId}
          // @ts-expect-error reqId
          reqId={result?.reqId || error?.reqId}
        />
        <div className='stage-bd pstn-bd'>
          {result || error ? (
            <>
              <div className='pstn-call-result'>
                <div className='_icon'>{error ? CallFailSVG : CallSuccessSVG}</div>
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
                className='pstn-form'
                form={form}
                initialValues={{
                  phone: '',
                  interrupt: true,
                  voiceId: 'longwan_v2',
                }}
              >
                <Form.Item
                  name='phone'
                  className='_phone'
                  label={t('pstn.outbound.phone.label')}
                  childElementPosition='right'
                  rules={[{ validator: checkMobile }]}
                >
                  <Input type='number' placeholder={t('pstn.outbound.phone.placeholder')} />
                </Form.Item>
                <div className='_tip'>{t('pstn.outbound.phone.tip')}</div>
                <Form.Item
                  label={t('pstn.outbound.interrupt.label')}
                  name='interrupt'
                  childElementPosition='right'
                  valuePropName='checked'
                >
                  <Switch style={{ '--height': '18px', '--width': '36px' }} />
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
                <Form.Item className='_help'>
                  <ExclamationCircleFill color='var(--adm-color-primary)' />
                  {t('pstn.outbound.help')}
                </Form.Item>
              </Form>

              <div className='_holder' />

              <div className='pstn-btn-box'>
                <Button color='primary' block onClick={onSubmit} disabled={!submittable}>
                  {t('pstn.outbound.start')}
                </Button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default PSTNOutbound;
