//
//  LSYReadUtilites.h
//  LSYReader
//
//  Created by Labanotation on 16/5/31.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSYReadUtilites : NSObject
+(void)separateChapter:(NSMutableArray **)chapters content:(NSString *)content;
+(NSString *)encodeWithURL:(NSURL *)url;
+(UIButton *)commonButtonSEL:(SEL)sel target:(id)target;
+(UIViewController *)getCurrentVC;
+(void)showAlertTitle:(NSString *)title content:(NSString *)string;
//新增的获取图片方法
+(NSString *)getImagWithPath:(NSString *)name;
@end
