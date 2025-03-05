#
# Be sure to run `pod lib lint AUIAICall.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIAICall'
  s.version          = '2.1.0'
  s.summary          = 'A short description of AUIAICall.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/MediaBox-AUIKits/AUIAICall'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/MediaBox-AUIKits/AUIAICall', :tag =>"v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.swift_version = '5.0'
#  s.pod_target_xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1'}
  s.default_subspecs='Standard'


  
  s.subspec 'Standard' do |ss|
    ss.resources = 'Resources/AUIAICall.bundle'
    ss.source_files = 'Source/**/*.{swift,h,m,mm}'
    ss.exclude_files = 'Source/AUIAICallMainViewController.swift', 'Source/ChatBot/**/*.{swift,h,m,mm}'
    ss.dependency 'AUIFoundation'
    ss.dependency 'ARTCAICallKit'
    ss.dependency 'MJRefresh'
    ss.pod_target_xcconfig = {'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited)'}
  end
  
  s.subspec 'Chatbot' do |ss|
    ss.resources = 'Resources/AUIAICall.bundle', 'Resources/AUIAIChat.bundle'
    ss.source_files = 'Source/**/*.{swift,h,m,mm}'
    ss.exclude_files = 'Source/AUIAICallMainViewController.swift'
    ss.dependency 'AUIFoundation'
    ss.dependency 'ARTCAICallKit/Chatbot'
    ss.dependency 'MJRefresh'
    ss.pod_target_xcconfig = {'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) AICALL_ENABLE_CHATBOT'}
  end
  
  s.subspec 'Demo' do |ss|
    ss.resources = 'Resources/**/*.bundle'
    ss.source_files = 'Source/**/*.{swift,h,m,mm}'
    ss.dependency 'AUIFoundation'
    ss.dependency 'ARTCAICallKit/Chatbot'
    ss.dependency 'MJRefresh'
    ss.pod_target_xcconfig = {'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) AICALL_ENABLE_CHATBOT '}
  end
  
  s.subspec 'Demo_For_Debug' do |ss|
    ss.resources = 'Resources/**/*.bundle'
    ss.source_files = 'Source/**/*.{swift,h,m,mm}'
    ss.dependency 'AUIFoundation'
    ss.dependency 'ARTCAICallKit/Chatbot'
    ss.dependency 'MJRefresh'
    ss.pod_target_xcconfig = {'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) DEMO_FOR_DEBUG '}
  end
  
  s.subspec 'Demo_For_RTC' do |ss|
    ss.dependency 'AliVCSDK_ARTC'  # 可以替换为AliVCSDK_InteractiveLive 或 AliVCSDK_Standard，取决于你的Podfile依赖的是哪个
    ss.pod_target_xcconfig = {'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) DEMO_FOR_RTC'}
  end
  
end
