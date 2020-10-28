# @Author: **guozd**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 guozd All rights reserved
#
# 组件说明: TAB管理组件
#

Pod::Spec.new do |spec|
  #=> 组件名称: Tab
  spec.name         = "GMainTab"
  #=> 组件版本: 0.01
  spec.version      = "0.0.1"
  #=> 组件简介
  spec.summary      = "GMainTab."
  #=> 组件描述
  spec.description  = "GMainTab the convi"
  #=> 组件网站
  spec.homepage     = "http://temp/GMainTab"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "http://temp/GMainTab.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "GMainTab", "GMainTab/**/*.{h,m}"
  #=> 组件ARC
  spec.requires_arc = true
  spec.ios.deployment_target = "9.0"
  #=> 依赖
  spec.dependency 'CYLTabBarController', '1.28.4'
end
