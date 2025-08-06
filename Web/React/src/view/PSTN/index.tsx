import PSTNInbound from './Inbound';
import PSTNOutbound from './Outbound';

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
  if (type === 'Inbound') {
    return <PSTNInbound {...rest} />;
  }
  return <PSTNOutbound {...rest} />;
}

export default PSTN;
