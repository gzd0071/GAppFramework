# @Author: **guozd**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 guozd All rights reserved
# https://www.jianshu.com/p/9096a2eb2804
# 组件说明: BLogin
#

Pod::Spec.new do |spec|
  #=> 组件名称: BLogin
  spec.name         = "BLogin"
  #=> 组件版本: 0.01
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "BLogin."
  #=> 组件描述
  spec.description  = "BLogin the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/katongzhong1/BLogin"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com:katongzhong1/BLogin.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "BLogin", "BLogin/**/*.{h,m}"
  #=> 组件ARC
  spec.requires_arc = true
  #=> 平台信息
  spec.platform      = :ios, '9.0'
  #=> 依赖库
  spec.dependency 'DMLogin'
end
