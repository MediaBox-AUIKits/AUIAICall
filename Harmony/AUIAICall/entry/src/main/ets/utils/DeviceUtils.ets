import { ConfigurationConstant } from "@kit.AbilityKit";
import { LogUtil } from "@pura/harmony-utils";

/**
 * @description 设备工具类
 * */
class DeviceUtils {
  //切换深色模式
  static changeDarkOrLightMode(colorMode: number) {
    let uiContext = AppStorage.get('UIContext') as UIContext;
    let context = uiContext.getHostContext()?.getApplicationContext()
    try {
      if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
        context?.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      }
      if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        context?.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
      }

    } catch (error) {
      LogUtil.error("Implement error handling.")
    }
  }
}

export { DeviceUtils }