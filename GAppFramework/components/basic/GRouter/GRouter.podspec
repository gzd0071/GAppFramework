# @Author: **guozd**
# @Date: 2019-06-22 15:00:36
# Copyright (c) 2019 Guozd All rights reserved
#
# 组件说明: GRouter管理组件
#

Pod::Spec.new do |spec|
  #=> 组件名称: Router
  spec.name         = "GRouter"
  #=> 组件版本: 0.01
  spec.version      = "0.0.1"
  #=> 组件简介
  spec.summary      = "GRouter."
  #=> 组件描述
  spec.description  = "GRouter the convi"
  #=> 组件网站
  spec.homepage     = "http://temp/GRouter"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "http://temp/GRouter.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "GRouter", "GRouter/**/*.{h,m}"
  #=> 组件ARC
  spec.requires_arc = true
  spec.ios.deployment_target = "9.0"
  #=> 依赖
  
end
