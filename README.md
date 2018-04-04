# TxtAndPDFReader 

[![TxtAndPDFReader](https://img.shields.io/badge/TxtAndPDFReader-1.0.0-ff69b4.svg)](https://github.com/LSSSSL/TxtAndPDFReader)
[![Author](https://img.shields.io/badge/author-LSSSSL-yellowgreen.svg)](https://github.com/LSSSSL)

电子书阅读器，支持txt，pdf格式 （txt 借鉴 ：https://github.com/GGGHub/Reader  进行了部分修改）

pdf 可通过捏合缩放 放大查看内容

## 用法

1.将Reader文件夹（Resource测试资源文件）和information.bundle 拉取使用

2.Build Phases -Compile Sources 设置 NSString+HTML.M 和 GTMNSString+HTML.M 两个文件不使用arc 添加 -fno-objc-arc 

## 注意 如何设置更加合适自己项目的分辨率（提高清晰度）

```
-(UIImage *)drawInContextAtPageNo:(int)page_no{
    if (_pageNO == 0) {
        _pageNO = 1;
    }
    CGPDFPageRef page = CGPDFDocumentGetPage(_pdfDocument, _pageNO);
    CGRect tempRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    int wScale =  ceil(2100.0f/tempRect.size.width);//1.根据拿到的pdf大小 与标准a4 大小 取一个放大比例 向上取整
    CGRect pageRect = CGRectMake(0, 0, tempRect.size.width*wScale, tempRect.size.height*wScale);//2.根据比例放大绘制区域（使分辨率提高）
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef imgContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(imgContext);
    CGContextTranslateCTM(imgContext, 0.0, pageRect.size.height);
    CGContextScaleCTM(imgContext,  wScale,-wScale);//3.同样按比例放大
    CGContextSetInterpolationQuality(imgContext, kCGInterpolationHigh);
    CGContextSetRenderingIntent(imgContext, kCGRenderingIntentDefault);
    CGContextDrawPDFPage(imgContext, page);
    CGContextRestoreGState(imgContext);
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    return tempImage;
}

```
