#
# Be sure to run `pod lib lint DMLogin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DMLogin'
  s.version          = '0.1.0'
  s.summary          = '斗米通用登录模块'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://git.corp.doumi.com/middle-end/DMLogin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NonMac' => 'NonMac@aliyun.com' }
  s.source           = { :git => 'git@git.corp.doumi.com:middle-end/DMLogin.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  
  s.default_subspecs = 'C' #, 'MapperMacros', 'DataSources'


  s.subspec 'C' do |employee|
    employee.source_files = [
      'Classes/*.{h,m}',
      'Classes/logic**/*',
      'Classes/network/**/*',
      'Classes/UI/**/*',
      'Classes/ChinaMobile/**/*',
      'Classes/FlashVerify/**/*'
    ]
    employee.resources = ['Assets/*.*']

    #对一键登录的 framework 的读取配置
    employee.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => ["${PODS_ROOT}/OneKeyLoginSDK/Classes/移动联通电信/", "${PODS_ROOT}/../doumi_framework_ios/"]}
    #
    # employee.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "${PODS_ROOT}/../../斗米各个模块/OneKeyLoginSDK/Classes"}
    #,'Classes⁩/⁨DMNewLoginViewController⁩/⁨ValidationSMS⁩/DMLSMSValidationVC.xib'
  end

  # s.subspec 'B' do |ss|
  # end

end
