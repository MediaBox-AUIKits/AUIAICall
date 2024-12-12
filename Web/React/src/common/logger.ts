/* eslint-disable @typescript-eslint/no-explicit-any */
export enum AUIAICallLogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

const logLevelMap = {
  [AUIAICallLogLevel.DEBUG]: 'DEBUG',
  [AUIAICallLogLevel.INFO]: 'INFO',
  [AUIAICallLogLevel.WARN]: 'WARN',
  [AUIAICallLogLevel.ERROR]: 'ERROR',
};

export type AUIAICallExternalTarget = {
  log: (level: AUIAICallLogLevel, ...args: any[]) => void;
  setParams: (params: { [key: string]: string | number }) => void;
};

class AUIAICallLogger {
  private _logLevel = AUIAICallLogLevel.ERROR;

  private externalTarget?: AUIAICallExternalTarget;

  getLogLevel() {
    return this._logLevel;
  }
  setLogLevel(level: AUIAICallLogLevel) {
    this._logLevel = level;
  }

  setExternalLogger(logger: AUIAICallExternalTarget) {
    this.externalTarget = logger;
  }

  setParams(params: { [key: string]: string | number }) {
    try {
      if (this.externalTarget) {
        this.externalTarget.setParams(params);
      }
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      // ignore error
    }
  }

  debug(...args: any[]) {
    this.log(AUIAICallLogLevel.DEBUG, ...args);
  }
  info(
    module: string,
    name: string,
    args?: {
      [key: string]: any;
    }
  ) {
    this.log(AUIAICallLogLevel.INFO, module, name, args);
  }

  warn(name: string, ...args: any[]) {
    this.log(AUIAICallLogLevel.WARN, name, ...args);
  }

  error(name: string, error: Error) {
    this.log(AUIAICallLogLevel.ERROR, name, error);
  }

  log(level: AUIAICallLogLevel, ...args: any[]) {
    if (level > this._logLevel) {
      console.log([`[${logLevelMap[level]}]`], ...args);
    }
    try {
      if (this.externalTarget) {
        this.externalTarget.log(level, ...args);
      }
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      // ignore error
    }
  }
}

export default new AUIAICallLogger();
