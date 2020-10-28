# @Author: **guozd**
# @Date: 2019-08-08 12:00:36
# Copyright (c) 2019 guozd All rights reserved
#
# 组件说明: GLogger 日志组件
#

Pod::Spec.new do |spec|
  #=> 组件名称: GLogger
  spec.name         = "GLogger"
  #=> 组件版本: 0.01
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GLogger."
  #=> 组件描述
  spec.description  = "GLogger the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/katongzhong1/GLogger"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com:katongzhong1/GLogger.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "GLogger", "GLogger/**/*.{h,m}"
  #=> 组件ARC
  spec.requires_arc = true
  spec.ios.deployment_target = "9.0"
  #=> 依赖
#  spec.dependency 'CocoaLumberjack', '3.5.3'
#  spec.dependency 'CocoaAsyncSocket'
#  spec.dependency 'CocoaHTTPServer'
end
