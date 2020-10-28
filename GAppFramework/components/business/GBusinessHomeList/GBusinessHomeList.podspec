# @Author: **guozd**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 guozd All rights reserved
#
# 组件说明: 业务组件
#   首页列表页面
#

Pod::Spec.new do |spec|
  #=> 组件名称: Tab
  spec.name         = "GBusinessHomeList"
  #=> 组件版本: 0.01
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GBusinessHomeList."
  #=> 组件描述
  spec.description  = "GBusinessHomeList the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/gzd0071/GBusinessHomeList"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com:gzd0071/GBusinessHomeList.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "GHomeList", "GHomeList/**/*.{h,m,c}"
  spec.resources = ['GHomeList/img/*.png']
  #=> 组件ARC
  spec.requires_arc = true
  #=> 平台信息
  spec.platform      = :ios, '9.0'
  #=> 依赖库
  # spec.dependency 'GBaseLib'
end
