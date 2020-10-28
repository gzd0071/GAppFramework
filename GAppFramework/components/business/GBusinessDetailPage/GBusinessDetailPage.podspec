# @Author: **guozd**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 guozd All rights reserved
#
# 组件说明: 业务组件
#   详情
#

Pod::Spec.new do |spec|
  #=> 组件名称: Tab
  spec.name         = "GBusinessDetailPage"
  #=> 组件版本: 0.01
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GBusinessDetailPage."
  #=> 组件描述
  spec.description  = "GBusinessDetailPage the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/gzd0071/GBusinessDetailPage"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com:gzd0071/GBusinessDetailPage.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "GDetailPage", "GDetailPage/**/*.{h,m,c}"
  spec.resources = ['GDetailPage/img/*.png']
  #=> 组件ARC
  spec.requires_arc = true
  #=> 平台信息
  spec.platform      = :ios, '9.0'
  #=> 依赖库
  # spec.dependency 'GBaseLib'
end
