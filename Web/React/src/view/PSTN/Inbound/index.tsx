import { AICallAgentError } from 'aliyun-auikit-aicall';
import { Button, Form, Input, Toast } from 'antd-mobile';
import { useEffect, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { copyText, getRootElement } from '@/common/utils';
import standard from '@/service/standard';
import Header from 'components/Header';
import { useResponsiveBreakpoint } from 'hooks/useResponsiveBreakpoint';

import { copySVG, refreshSVG } from '../Icons';

import './index.less';

function PSTNInbound({
  userId,
  agentId,
  region = 'cn-shanghai',
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
  const [agentNumber, setAgentNumber] = useState('');
  const isMobileUI = useResponsiveBreakpoint();

  const getAgentNumber = async () => {
    try {
      const result = await standard.describeAIAgent(userId, region, agentId);
      if (result && result.InboundPhoneNumbers && (result.InboundPhoneNumbers as string[]).length > 0) {
        setAgentNumber((result.InboundPhoneNumbers as string[])[0]);
      }
    } catch (error) {
      if ((error as AICallAgentError).name === 'ServiceAuthError') {
        onAuthFail();
        return;
      }
    }
  };

  useEffect(() => {
    getAgentNumber();
  }, [agentId, onAuthFail, region, userId]);

  const onStart = async () => {
    if (!agentNumber) return;

    window.open(`tel://${agentNumber}`);
  };

  const onCopy = () => {
    if (!agentNumber) return;
    copyText(agentNumber).then(() => {
      Toast.show({ content: t('common.copySuccess'), getContainer: getRootElement });
    });
  };

  return (
    <>
      <Header onExit={onExit} title={t('pstn.inbound.title')} actions={null} />
      <div className='stage-bd pstn-bd'>
        <>
          <Form layout='vertical' className='ai-form pstn-form'>
            <Form.Item className='_phone no-border' label={t('pstn.inbound.number')}>
              <Input type='number' placeholder={t('pstn.inbound.getting')} value={agentNumber} />
              <Button fill='none' className='_copy' onClick={onCopy} disabled={!agentNumber}>
                {copySVG}
              </Button>
            </Form.Item>
            <div className='_tip'>
              {t('pstn.inbound.numberHelp')}
              <Button
                fill='none'
                onClick={() => {
                  getAgentNumber();
                }}
              >
                {refreshSVG}
              </Button>
            </div>
          </Form>

          <div className='_holder' />

          <div className='pstn-btn-box'>
            {isMobileUI && (
              <>
                <Button fill='none' color='primary' block onClick={onStart} disabled={!agentNumber}>
                  {t('pstn.inbound.start')}
                </Button>
              </>
            )}
            <div className='ai-statement'>{t('system.statement')}</div>
          </div>
        </>
      </div>
    </>
  );
}

export default PSTNInbound;
