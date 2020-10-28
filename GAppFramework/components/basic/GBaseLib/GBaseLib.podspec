# @Author: **guozd**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 guozd All rights reserved
#
# 组件说明: GBaseLib组件
#    a. 功能:
#       1.统一管理第三方开发库
#       2.使版本依赖变为单一依赖, 不再受具体的三方库版本牵绊
#       3.扩展第三方库功能
#
Pod::Spec.new do |spec|
  #=> 组件名称: GBaseLib
  spec.name         = "GBaseLib"
  #=> 组件版本: 0.1.0
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GBaseLib."
  #=> 组件描述
  spec.description  = "GBaseLib the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/katongzhong1/GBaseLib"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com:katongzhong1/GBaseLib.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files = "GBaseLib", "GBaseLib/**/*.{h,m}"
  #=> 组件ARC
  spec.requires_arc = true
  #=> 平台信息
  spec.platform     = :ios, '9.0'
  #=> 依赖库
  spec.dependency 'Masonry'
  spec.dependency 'AFNetworking'
  spec.dependency 'ReactiveObjC', '3.1.1'
  spec.dependency 'YYKit', '1.0.9'
  spec.dependency 'MJRefresh', '3.1.16'
  spec.dependency 'SDWebImage', '5.0.2'
end
