import Layout, { StageWrapper } from '../components/Layout';
import PSTNInbound from './Inbound';
import PSTNOutbound from './Outbound';

import './index.less';

export enum AIPSTNType {
  Outbound = 21,
  Inbound,
}
function PSTN({
  type,
  ...rest
}: {
  type: string;
  userId: string;
  agentId: string;
  region: string;
  onExit: () => void;
  onAuthFail: () => void;
}) {
  return (
    <Layout themeBtn={false} onExit={rest.onExit}>
      <StageWrapper className='is-pstn'>
        {type === 'Inbound' ? <PSTNInbound {...rest} /> : <PSTNOutbound {...rest} />}
      </StageWrapper>
    </Layout>
  );
}

export default PSTN;
