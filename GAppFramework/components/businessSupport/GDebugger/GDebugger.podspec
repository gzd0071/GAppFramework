# @Author: **guozd**
# @Date: 2019-06-18 15:00:36
# Copyright (c) 2019 guozd All rights reserved
#
# 组件说明: TAB管理组件
#

Pod::Spec.new do |spec|
  #=> 组件名称: Tab
  spec.name         = "GDebugger"
  #=> 组件版本: 0.01
  spec.version      = "0.1.0"
  #=> 组件简介
  spec.summary      = "GDebugger."
  #=> 组件描述
  spec.description  = "GDebugger the convi"
  #=> 组件网站
  spec.homepage     = "https://github.com/katongzhong1/GDebugger"
  #=> 组件开源协议
  spec.license      = "MIT"
  #=> 组件作者
  spec.author       = { "iOS_Developer_G" => "iOS_Developer_G@xxxxx.com" }
  #=> 组件git
  spec.source       = { :git => "git@github.com:katongzhong1/GDebugger.git", :tag => spec.version }
  #=> 组件文件
  spec.source_files  = "debugger", "debugger/**/*.{h,m,c}"
  spec.resources = ['debugger/debugger/enter/img/*.png',
                    'debugger/debugger/items/common/net/json/data/*.js',
                    'debugger/debugger/items/common/net/json/data/*.css',
                    'debugger/debugger/items/common/net/json/data/*.html',
                    'debugger/debugger/funcs/httpserver/web/**/*.js',
                    'debugger/debugger/funcs/httpserver/web/**/*.json',
                    'debugger/debugger/funcs/httpserver/web/**/*.css',
                    'debugger/debugger/funcs/httpserver/web/**/*.html']
  #=> 组件ARC
  spec.requires_arc = true
  #=> 平台信息
  spec.platform      = :ios, '9.0'
  #=> 依赖库
  
end
