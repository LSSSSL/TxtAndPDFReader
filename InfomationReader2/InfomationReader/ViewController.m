//
//  ViewController.m
//  LSYReader
//
//  Created by Labanotation on 16/5/30.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "ViewController.h"
#import "LSYReadViewController.h"
#import "LSYReadPageViewController.h"
#import "LSYReadUtilites.h"
#import "LSYReadModel.h"
#import "LSYPDFController.h"

@interface ViewController ()<LSYPDFReaderDelegate>
@property(nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1 CreateUI
    [self CreateUI];
}
#pragma mark -CreateUI
-(void)CreateUI{
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 60, self.view.frame.size.width-100, 40)];
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 setTitle:@"Txt 阅读" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(begin1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];

    UIButton *btn4 = [[UIButton alloc] initWithFrame:CGRectMake(50, 240, self.view.frame.size.width-100, 40)];
    btn4.backgroundColor = [UIColor orangeColor];
    [btn4 setTitle:@"PDF 阅读" forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(begin4:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
}
-(void)begin1:(id)sender{
    
    LSYReadPageViewController *pageView = [[LSYReadPageViewController alloc] init];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"mdjyml"withExtension:@"txt"];
    pageView.resourceURL = fileURL;    //文件位置
    pageView.fileName = @"mdjyml.txt";
    pageView.alphaValue = 1.0;
    pageView.backColor = [UIColor colorWithRed:(float)(106/255.0f) green:(float)(183/255.0f) blue:(float)(237/255.0f) alpha:1.0f];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        pageView.model = [LSYReadModel getLocalModelWithURL:fileURL];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self presentViewController:pageView animated:YES completion:nil];
        });
    });
}
-(void)begin4:(id)sender{
    
    LSYPDFController *targetViewCtrl = [[LSYPDFController alloc] init];
    targetViewCtrl.url = [[NSBundle mainBundle] URLForResource:@"001"withExtension:@"pdf"];
    targetViewCtrl.fileName = @"001.pdf";
    targetViewCtrl.alphaValue = 1.0;
    targetViewCtrl.backColor = [UIColor colorWithRed:(float)(106/255.0f) green:(float)(183/255.0f) blue:(float)(237/255.0f) alpha:1.0f];
    targetViewCtrl.delegate = self;
    [self presentViewController:targetViewCtrl animated:YES completion:^{
    }];
}
-(void)LSYPDFReaderFristViewController:(ZPDFPageController *)FristViewController WithIndex:(int)index
{
    NSLog(@"-Frist-%d",index);
}
-(void)LSYPDFReaderAfterViewController:(ZPDFPageController *)afterViewController WithIndex:(int)index
{
    NSLog(@"-After-%d",index);
}
-(void)LSYPDFReaderLastViewController:(ZPDFPageController *)LastViewController WithIndex:(int)index
{
    NSLog(@"-Last-%d",index);
}

@end



