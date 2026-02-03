import { appTasks } from '@ohos/hvigor-ohos-plugin';
// 1、导入
import { routerRegisterPlugin, PluginConfig } from 'router-register-plugin'

// 2、初始化配置
const config: PluginConfig = {
  scanDirs: ['src/main/ets/pages', 'src/main/ets/views', 'src/main/ets/component', 'src/main/ets/dialog'], // 扫描的目录，如果不设置，默认是扫描src/main/ets目录
  logEnabled: true, // 查看日志
  viewNodeInfo: false, // 查看节点信息
  ignoredModules:['RouterApi','common','xxx'], // 忽略的参与构建的模块，根据自己项目自行设置
  enableUiPreviewBuild: false, // 启用UI预览构建，不建议启动
}

export default {
  system: appTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  // 3、添加插件
  plugins: [routerRegisterPlugin(config)]       /* Custom plugin to extend the functionality of Hvigor. */
}