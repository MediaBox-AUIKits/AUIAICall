import { createRoot } from 'react-dom/client';
import App from './AppWithAuth.tsx';

interface AICallUIConfig {
  userId: string;
  root: HTMLElement;
  shareToken?: string;
  userToken?: string;
  appServer?: string;
}

export class ARTCAICallUI {
  private userId: string;
  private shareToken?: string;
  private root: HTMLElement;
  private config?: AICallUIConfig;

  constructor(config: AICallUIConfig) {
    const { userId, shareToken, root } = config;
    this.userId = userId;
    this.shareToken = shareToken;
    this.root = root;
    this.config = config;
    this.validate();
  }

  validate() {
    if (!this.userId || !this.shareToken) {
      const error = new Error('userId or shareToken is empty');
      console.error(error);
      throw error;
    }
    if (!this.root) {
      const error = new Error('root is empty');
      console.error(error);
      throw error;
    }

    // 非分享进入模式
    if (!this.shareToken) {
      if (!this.config?.appServer) {
        const error = new Error('appServer is empty');
        console.error(error);
        throw error;
      }
    }
  }

  render() {
    createRoot(this.root).render(
      <App
        userId={this.userId}
        shareToken={this.shareToken}
        userToken={this.config?.userToken}
        appServer={this.config?.appServer}
      />
    );
  }
}
