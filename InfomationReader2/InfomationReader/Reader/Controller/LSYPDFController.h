//
//  ZPDFReaderController.h
//  pdfReader
//
//  Created by XuJackie on 15/6/6.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -ZPDFPageController
@interface  ZPDFPageController : UIViewController
@property (assign, nonatomic) CGPDFDocumentRef pdfDocument;
@property (assign, nonatomic) int pageNO;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end

@class ZPDFPageController;
#pragma mark -ZPDFPageModel
@interface ZPDFPageModel : NSObject
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) int pageNO;
+(void)updateLocalModel:(ZPDFPageModel *)PDFModel url:(NSURL *)url;
+(ZPDFPageModel *)getLocalModelWithURL:(NSURL *)Url;
@end

#pragma mark -LSYPDFController
@protocol LSYPDFReaderDelegate <NSObject>
@optional
-(void)LSYPDFReaderAfterViewController:(ZPDFPageController*)afterViewController WithIndex:(int)index;
-(void)LSYPDFReaderLastViewController:(ZPDFPageController*)LastViewController WithIndex:(int)index;
-(void)LSYPDFReaderFristViewController:(ZPDFPageController*)FristViewController WithIndex:(int)index;
@end
@interface LSYPDFController : UIViewController
@property (nonatomic,strong)UIPageViewController *pageViewCtrl;
@property (nonatomic,strong)NSMutableArray *subViewControls;
@property (nonatomic,assign)CGPDFDocumentRef pdfDocument;
@property (nonatomic,weak) id<LSYPDFReaderDelegate> delegate; 
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSString *fileName;
@property (nonatomic,strong) UIColor *backColor;  //主题颜色
@property (nonatomic,assign) float alphaValue;
@end

#pragma mark -PDFMenuView
@class PDFMenuView;
@protocol PDFMenuViewDelegate <NSObject>
@optional
-(void)menuViewDidHidden:(PDFMenuView *)menu;
-(void)menuViewDidAppear:(PDFMenuView *)menu;
-(void)menuViewJumpPageWithTag:(int)Tag;
-(void)menuViewBack;
@end
@interface PDFMenuView : UIView
@property (nonatomic,weak) id<PDFMenuViewDelegate> delegate;
@property (nonatomic) int page;  //当钱前阅读的页数
@property (nonatomic) int pageCount;  //总页数
@property (nonatomic,strong) NSString *fileName;  //文件名称
@property (nonatomic,strong) UIColor *backColor;  //主题颜色
@property (nonatomic,assign) float alphaValue;
-(void)showAnimation:(BOOL)animation;
-(void)hiddenAnimation:(BOOL)animation;
@end


