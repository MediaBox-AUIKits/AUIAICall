import ControllerContext from '@/Mobile/Call/ControlerContext';
import AUIAICallStandardController from '@/controller/call/AUIAICallStandardController';
import AICall from '.';
import { useState } from 'react';

import './App.css';
import './call.less';
import CallWelcome from './Welcome';
import useCallStore from '@/Mobile/Call/store';

function App() {
  const agentType = useCallStore((state) => state.agentType);

  // @ts-expect-error setController should called after token updated
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [controller, setController] = useState(new AUIAICallStandardController('YourUserId', 'YourToken'));
  const onAuthFail = () => {
    // 获取新的 token 并更新 controller
  };

  if (agentType === undefined || agentType === null) {
    return <CallWelcome onAgentTypeSelected={(type) => useCallStore.setState({ agentType: type })} />;
  }

  return (
    <>
      <ControllerContext.Provider value={controller}>
        <AICall onAuthFail={onAuthFail} />
      </ControllerContext.Provider>
    </>
  );
}

export default App;
