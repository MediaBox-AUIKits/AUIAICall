import { AICallAgentType, AIChatAgentType } from 'aliyun-auikit-aicall';

import { AIPSTNType } from '../PSTN';

export type WelcomeTypeValue = AICallAgentType | AIChatAgentType | AIPSTNType;

export interface SlideData {
  key: string;
  title: string;
  description: string;
  image: string;
  value: WelcomeTypeValue;
}

export interface WelcomeProps {
  userId: string;
  region?: string;
  onAuthFail?: () => void;
  showPstn: boolean;
  onSelected: (value: WelcomeTypeValue) => void;
}
