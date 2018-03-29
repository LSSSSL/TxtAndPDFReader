# TxtAndPDFReader 

[![TxtAndPDFReader](https://img.shields.io/badge/author-LSSSSL-red.svg)](https://github.com/LSSSSL/TxtAndPDFReader)
[![Author](https://img.shields.io/badge/author-LSSSSL-yellowgreen.svg)](https://github.com/LSSSSL)

电子书阅读器，支持txt，pdf格式 （txt 借鉴 ：https://github.com/GGGHub/Reader  进行了部分修改）

## 用法

1.将Reader文件夹（Resource测试资源文件）和information.bundle 拉取使用

2.Build Phases -Compile Sources 设置 NSString+HTML.M 和 GTMNSString+HTML.M 两个文件不使用arc 添加 -fno-objc-arc 
