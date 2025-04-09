import ControllerContext from '@/Mobile/Call/ControlerContext';
import AUIAICallStandardController from '@/controller/call/AUIAICallStandardController';
import AICall from '.';
import { useState } from 'react';

import useCallStore from '@/Mobile/Call/store';
import runConfig from '@/runConfig.ts';
import CallWelcome from './Welcome';

import './App.css';
import './call.less';
import { getRuntimeConfig } from '@/interface.ts';

function App() {
  const agentType = useCallStore((state) => state.agentType);

  const getController = () => {
    const controller = new AUIAICallStandardController('YourUserId', 'YourToken');
    const rc = getRuntimeConfig(runConfig);
    if (rc.callTemplateConfig) {
      controller.config.templateConfig = rc.callTemplateConfig;
    }
    if (rc.callUserData) {
      controller.config.userData = rc.callUserData;
    }
    if (rc.region) {
      controller.config.region = rc.region;
    }
    if (rc.appServer) {
      controller.appServer = rc.appServer;
    }

    return controller;
  };

  // @ts-expect-error setController should called after token updated
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [controller, setController] = useState(getController());
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
