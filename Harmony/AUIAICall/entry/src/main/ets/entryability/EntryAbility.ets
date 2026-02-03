import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIContext, window } from '@kit.ArkUI';
import { ZRouter } from '@hzw/zrouter';
import BuildProfile from 'BuildProfile';
import { DialogUtil, PreferencesUtil } from '@pura/harmony-utils';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    // 如果项目中存在hsp模块则传入true
    ZRouter.initialize((config) => {
      config.isLoggingEnabled = BuildProfile.DEBUG
      config.isHSPModuleDependent = false
    })

  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }

      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      // 获取主窗口的UIContext
      const mainWindow = windowStage.getMainWindowSync();
      const uiContext = mainWindow.getUIContext();

      // 存储到AppStorage
      AppStorage.setOrCreate('UIContext', uiContext);

      //设置Dialog样式
      DialogUtil.setDefaultConfig((config) => {
        config.title = ""
        config.alignment = DialogAlignment.Center
        config.width = '80%'
        config.autoCancel = true
        config.cornerRadius = {
          topLeft: '10vp',
          topRight: '10vp',
          bottomLeft: '10vp',
          bottomRight: '10vp'
        }
      });
      // 初始化时获取颜色模式
      AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);

      let isFirst: boolean = PreferencesUtil.getSync('isFirst', undefined, 'isFirst') as boolean
      if (isFirst == undefined) {
        PreferencesUtil.putSync('isFirst', true, 'isFirst')
      }

      // this.registerBreakPointListener(mainWindow);

    });
  }

  private registerBreakPointListener(win: window.Window): void {
    try {
      const uiContext = AppStorage.get('UIContext') as UIContext;
      const handleBreakpoint = (widthBp: number, heightBp: number): void => {
        AppStorage.setOrCreate('currentWidthBreakpoint', widthBp); // 存储横向断点
        AppStorage.setOrCreate('currentHeightBreakpoint', heightBp); // 存储纵向断点
      };


      // 初始化赋值
      handleBreakpoint(
        uiContext.getWindowWidthBreakpoint(),
        uiContext.getWindowHeightBreakpoint()
      );

      // 监听窗口变化
      win.on('windowSizeChange', (size: window.Size) => {
        handleBreakpoint(
          uiContext.getWindowWidthBreakpoint(),
          uiContext.getWindowHeightBreakpoint()
        );
      });
    } catch (e) {
      console.error(`监听断点失败: ${JSON.stringify(e)}`);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    // 当系统配置变更时更新
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}