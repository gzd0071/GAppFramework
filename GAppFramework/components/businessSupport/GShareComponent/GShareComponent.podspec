# @Author: **xxxxx**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 xxxxx All rights reserved
# https://www.jianshu.com/p/9096a2eb2804
# 组件说明: 分享组件
#

Pod::Spec.new do |spec|
  #=> 组件名称: Tab
  spec.name         = "GShareComponent"
  #=> 组件版本: 0.01
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GShareComponent."
  #=> 组件描述
  spec.description  = "GShareComponent the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/GShareComponent"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com/GShareComponent.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "GShareComponent", "GShareComponent/**/*.{h,m,plist}"
  spec.vendored_frameworks = 'GShareComponent/TencentOpenAPI.framework'
  #=> 组件ARC
  spec.requires_arc = true
  #=> 平台信息
  spec.platform      = :ios, '9.0'
end
