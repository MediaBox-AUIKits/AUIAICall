import React, { createContext, ReactNode, useContext } from 'react';
import { AICallErrorCode } from 'aliyun-auikit-aicall';

import en from './locales/en';
import zh from './locales/zh';

type LeafPaths<T, P extends string = ''> = T extends object
  ? {
      [K in keyof T & string]: T[K] extends object
        ? LeafPaths<T[K], `${P}${P extends '' ? '' : '.'}${K}`>
        : `${P}${P extends '' ? '' : '.'}${K}`;
    }[keyof T & string]
  : P;

type I18nPaths = LeafPaths<typeof zh>;
function getSystemLanguage() {
  if (typeof navigator !== 'undefined') {
    // 尝试获取用户语言列表
    // attmpt to get user language list
    const userLanguages = navigator.languages || [];

    // 首先检查主要语言
    // choose primary language first
    // @ts-expect-error userLanguage
    const primaryLanguage = (navigator.language || navigator.userLanguage || '').toLowerCase();

    if (primaryLanguage.startsWith('en')) return 'en';

    if (userLanguages.length > 0 && userLanguages[0].startsWith('en')) return 'en';
  }

  // 非英语返回中文
  // if no english, return chinese
  return 'zh';
}

const LOCALE = getSystemLanguage();

// 所有语言包
// all locales
const locales = {
  en,
  zh,
};

// 当前使用的语言包
// choose current language
const messages = locales[LOCALE as keyof typeof locales];

type I18nContextType = {
  t: (key: I18nPaths, params?: Record<string, string>) => string;
  e: (code: number | undefined) => string;
};

const ErrorCodeMessageMap: { [key: number]: string } = {
  [AICallErrorCode.ConnectionFailed]: 'error.connectionFailed',
  [AICallErrorCode.KickedByUserReplace]: 'error.kickedByUserReplace',
  [AICallErrorCode.KickedBySystem]: 'error.kickedBySystem',
  [AICallErrorCode.LocalDeviceException]: 'error.localDeviceException',
  [AICallErrorCode.AgentLeaveChannel]: 'error.agentLeaveChannel',
  [AICallErrorCode.AgentPullFailed]: 'error.agentPullFailed',
  [AICallErrorCode.AgentASRFailed]: 'error.agentASRFailed',
  [AICallErrorCode.AvatarServiceFailed]: 'error.avatarServiceFailed',
  [AICallErrorCode.AvatarRoutesExhausted]: 'error.avatarRoutesExhausted',
  [AICallErrorCode.TokenExpired]: 'error.tokenExpired',
  [AICallErrorCode.AgentSubscriptionRequired]: 'error.subscriptionRequired',
  [AICallErrorCode.AgentNotFound]: 'error.agentNotFound',
};

export const I18nContext = createContext<I18nContextType>({
  t: (key) => key,
  e: (code) => `${code}`,
});

// 获取嵌套对象属性的辅助函数
// get nested object property
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const getNestedValue = (obj: any, path: string): string => {
  const keys = path.split('.');
  return keys.reduce((acc, key) => (acc && acc[key] !== undefined ? acc[key] : undefined), obj);
};

export const I18nProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  // 翻译函数
  // translation function
  const t = (key: string, params?: Record<string, string>): string => {
    let value = getNestedValue(messages, key);
    if (value === undefined) {
      console.warn(`Translation key "${key}" not found`);
      return key;
    }

    // 处理参数替换{name} => John
    if (params) {
      Object.entries(params).forEach(([paramKey, paramValue]) => {
        value = value.replace(new RegExp(`{${paramKey}}`, 'g'), paramValue);
      });
    }

    return value;
  };

  // 错误信息函数
  // error message function
  const e = (code?: number): string => {
    if (code) {
      const message = ErrorCodeMessageMap[code];
      if (!message) {
        return t('error.unknown');
      } else {
        return t(message);
      }
    }
    return t('error.unknown');
  };

  return <I18nContext.Provider value={{ t, e }}>{children}</I18nContext.Provider>;
};

export const getText = (key: string) => {
  const value = getNestedValue(messages, key);
  if (!value) return key;
  return value;
};

export const useTranslation = () => {
  const { t, e } = useContext(I18nContext);
  return { t, e };
};
