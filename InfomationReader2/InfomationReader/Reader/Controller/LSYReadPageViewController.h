//
//  LSYReadPageViewController.h
//  LSYReader
//
//  Created by Labanotation on 16/5/30.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSYReadModel.h"
@interface LSYReadPageViewController : UIViewController
@property (nonatomic,strong) NSURL *resourceURL;
@property (nonatomic,strong) LSYReadModel *model;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) UIColor *backColor;
@property (nonatomic,assign) float alphaValue;
@end
