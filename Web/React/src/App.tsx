import './App.css';
import ControllerContext from './ControlerContext';
import AUIAICallStandardController from './controller/AUIAICallStandardController';
import AICall from './AICall';
import { useState } from 'react';

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
