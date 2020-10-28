# @Author: **iOS_Developer_G**
# @Date: 2019-12-04 19:10:39
# Copyright (c) 2019 iOS_Developer_G All rights reserved
#
# 组件说明：
#

Pod::Spec.new do |spec|
  #=> 组件名称: GPush
  spec.name         = "GPush"
  #=> 组件版本: 0.1.0
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GPush."
  #=> 组件描述
  spec.description  = "GPush the convi"
  #=> 组件网站
  spec.homepage     = "http://temp/GPush"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "http://temp/GPush.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files = "GPush", "GPush/**/*.{h,m}"
  #=> 组件ARC
  spec.requires_arc = true
  #=> 组件最低版本
  spec.ios.deployment_target = "9.0"
end
