import ControllerContext from '@/common/ControlerContext';
import AUIAICallStandardController from '@/controller/AUIAICallStandardController';
import AICall from '.';
import { useState } from 'react';

import './App.css';
import './call.less';

function App() {
  // @ts-expect-error setController should called after token updated
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [controller, setController] = useState(new AUIAICallStandardController('YourUserId', 'YourToken'));
  const onAuthFail = () => {
    // 获取新的 token 并更新 controller
  };

  return (
    <>
      <ControllerContext.Provider value={controller}>
        <AICall onAuthFail={onAuthFail} />
      </ControllerContext.Provider>
    </>
  );
}

export default App;
