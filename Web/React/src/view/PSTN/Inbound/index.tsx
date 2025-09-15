import { Button, Form, Input, Toast } from 'antd-mobile';

import { useTranslation } from '@/common/i18nContext';
import { copyText, getRootElement, isMobile } from '@/common/utils';
import standard from '@/service/standard';
import { AICallAgentError } from 'aliyun-auikit-aicall';
import { useEffect, useState } from 'react';
import Header from '../Header';
import { CopySVG } from '../Icons';
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

  useEffect(() => {
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
    <div className='stage-wrapper'>
      <div className='stage'>
        <Header onExit={onExit} title={t('pstn.inbound.title')} />
        <div className='stage-bd pstn-bd'>
          <>
            <Form layout='horizontal' className='pstn-form'>
              <Form.Item
                className='_phone'
                label={t('pstn.inbound.number')}
                childElementPosition='right'
                extra={
                  <Button fill='none' className='_copy' onClick={onCopy} disabled={!agentNumber}>
                    {CopySVG}
                  </Button>
                }
              >
                <Input type='number' placeholder={t('pstn.inbound.getting')} value={agentNumber} />
              </Form.Item>
              <div className='_tip'>{t('pstn.inbound.numberHelp')}</div>
            </Form>

            <div className='_holder' />

            <div className='pstn-btn-box'>
              {isMobile() && (
                <>
                  <div className='pstn-statement'>{t('system.statement')}</div>
                  <Button color='primary' block onClick={onStart} disabled={!agentNumber}>
                    {t('pstn.inbound.start')}
                  </Button>
                </>
              )}
            </div>
          </>
        </div>
      </div>
    </div>
  );
}

export default PSTNInbound;
