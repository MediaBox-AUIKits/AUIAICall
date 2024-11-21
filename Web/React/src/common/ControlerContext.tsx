import { createContext } from 'react';
import AUIAICallController from '../controller/AUIAICallController';

const ControllerContext = createContext<AUIAICallController | null>(null);

export default ControllerContext;
