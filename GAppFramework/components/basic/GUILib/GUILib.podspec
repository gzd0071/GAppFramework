# @Author: **guozd**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 guozd All rights reserved
#
# 组件说明: TAB管理组件
#

Pod::Spec.new do |spec|
  #=> 组件名称: Tab
  spec.name         = "GUILib"
  #=> 组件版本: 0.01
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GUILib."
  #=> 组件描述
  spec.description  = "GUILib the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/katongzhong1/GUILib"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com:katongzhong1/GUILib.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files = "GUILib", "GUILib/**/*.{h,m}"
  #=> 组件ARC
  spec.requires_arc = true
  #=> 平台信息
  spec.platform     = :ios, '8.0'
  #=> 依赖库
  # spec.dependency 'GBaseLib'
end
