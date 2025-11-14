import { createContext } from 'react';

import AUIAICallController from '@/controller/call/AUIAICallController';

const ControllerContext = createContext<AUIAICallController | null>(null);

export default ControllerContext;
