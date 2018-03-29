//
//  ZPDFReaderController.m
//  pdfReader
//
//  Created by XuJackie on 15/6/6.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "LSYPDFController.h"
#import "LSYReadUtilites.h"
#define AnimationDelay 0.3f
#define TopViewHeight 64.0f
#define ViewSize(view)  (view.frame.size)
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define minScale  1
#define maxScale  3

#pragma mark -ZPDFPageController
@interface ZPDFPageController ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIScrollView *srcollView;
@end
@implementation ZPDFPageController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self CreateSrcollView];
}
#pragma mark -图片浏览
-(void)CreateSrcollView
{
    _srcollView = [[UIScrollView alloc]init];
    _srcollView.delegate = self;
    _srcollView.userInteractionEnabled = YES;
    _srcollView.showsHorizontalScrollIndicator = YES;//是否显示侧边的滚动栏
    _srcollView.showsVerticalScrollIndicator = NO;
    _srcollView.scrollsToTop = NO;
    _srcollView.scrollEnabled = YES;
    _srcollView.frame = self.view.frame;
    UIImage *img = [self drawInContextAtPageNo:(int)self.pageNO];
    _imageView = [[UIImageView alloc]initWithImage:img];
    //设置这个_imageView能被缩放的最大尺寸，这句话很重要，一定不能少,如果没有这句话，图片不能缩放
    _imageView.frame = CGRectMake(0, 0, _imageView.image.size.width, _imageView.image.size.height);
    _srcollView.contentSize=_imageView.frame.size;
    [self.view addSubview:_srcollView];
    [_srcollView addSubview:_imageView];
    
    [_srcollView setMinimumZoomScale:minScale];
    [_srcollView setMaximumZoomScale:maxScale];
    [_srcollView setZoomScale:minScale animated:NO];
}
-(UIImage *)drawInContextAtPageNo:(int)page_no{
    //开始图像绘图
    UIGraphicsBeginImageContext(self.view.bounds.size);
    //获取当前CGContextRef
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.view.frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    if (_pageNO == 0) {
        _pageNO = 1;
    }
    CGPDFPageRef page = CGPDFDocumentGetPage(_pdfDocument, _pageNO);
    CGContextSaveGState(context);
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, self.view.bounds, 0, true);
    CGContextConcatCTM(context, pdfTransform);
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}
//当滑动结束时
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat offsetX = (_srcollView.bounds.size.width>_srcollView.contentSize.width)?(_srcollView.bounds.size.width-_srcollView.contentSize.width)*0.5:0.0;
    CGFloat offsetY = (_srcollView.bounds.size.height>_srcollView.contentSize.height)?(_srcollView.bounds.size.height-_srcollView.contentSize.height)*0.5:0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width*0.5+offsetX, scrollView.contentSize.height*0.5+offsetY);
}
@end

#pragma mark -ZPDFPageModel
@implementation ZPDFPageModel
+(void)updateLocalModel:(ZPDFPageModel *)PDFModel url:(NSURL *)url
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *key = [url.path lastPathComponent];
    [defaults setInteger:PDFModel.pageNO forKey:key];
    [defaults synchronize];
}
+(ZPDFPageModel *)getLocalModelWithURL:(NSURL *)Url
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *key = [Url.path lastPathComponent];
    ZPDFPageModel *model = [[ZPDFPageModel alloc] init];
    NSInteger pageNO = [defaults integerForKey:key];
    if (pageNO == 0) {
        model.url = Url;
        model.pageNO = 1;
    }else
    {
        model.url = Url;
        model.pageNO = (int)pageNO;
    }
    [self updateLocalModel:model url:Url];
    return model;
}
@end

#pragma mark- LSYPDFController
@interface LSYPDFController ()<PDFMenuViewDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (nonatomic,strong) PDFMenuView *menuView; //菜单栏
@property (nonatomic,assign)NSInteger Count;
@property (nonatomic,strong)ZPDFPageModel *pdfPageModel;
@property (nonatomic,assign) ZPDFPageController *readerView;//当前view
@property (nonatomic,assign)bool isNotFirst;
@end
@implementation LSYPDFController
@synthesize url;
@synthesize fileName;
@synthesize backColor;
@synthesize alphaValue;
- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.url = url;
    self.fileName = fileName;
    self.backColor = backColor;
    self.alphaValue = alphaValue;
    //获取是否上一次有保留浏览页数 没有则返回初始位置
    _pdfPageModel = [ZPDFPageModel getLocalModelWithURL:self.url];
    CFStringRef path;
    CFURLRef pdfUrl;
    path = CFStringCreateWithCString(NULL, [_pdfPageModel.url.path UTF8String], kCFStringEncodingUTF8);
    pdfUrl = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, NO);
   _pdfDocument = CGPDFDocumentCreateWithURL(pdfUrl);
    CFRelease(path);
    CFRelease(pdfUrl);
    
    if (!_pageViewCtrl) {
        _pageViewCtrl = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewCtrl.delegate = self;
        _pageViewCtrl.dataSource = self;
    }
    
    _subViewControls = [[NSMutableArray alloc]init];
    _Count = CGPDFDocumentGetNumberOfPages(_pdfDocument);
    
    if (_Count>0 ) {
        //创建初始界面
        ZPDFPageController *subViewController = [self viewControllerAtIndex:_pdfPageModel.pageNO];
        if (_pdfPageModel.pageNO==_Count) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(LSYPDFReaderLastViewController:WithIndex:)]) {
                [self.delegate LSYPDFReaderLastViewController:subViewController WithIndex:_pdfPageModel.pageNO];
            }
        }else if(_pdfPageModel.pageNO == 1)
        {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(LSYPDFReaderFristViewController:WithIndex:)]) {
                [self.delegate LSYPDFReaderFristViewController:subViewController WithIndex:_pdfPageModel.pageNO];
            }
        }else
        {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(LSYPDFReaderAfterViewController:WithIndex:)]) {
                [self.delegate LSYPDFReaderAfterViewController:subViewController WithIndex:_pdfPageModel.pageNO];
            }
        }
        //设置初始界面
        [_pageViewCtrl setViewControllers:@[subViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [_subViewControls addObject:subViewController];
        _readerView = subViewController;
        [self.view addSubview:_pageViewCtrl.view];
    }
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolMenu)];
        tap;
    })];
    _menuView = [self menuView];
    [self.view addSubview:_menuView];
}

-(PDFMenuView *)menuView
{
    if (!_menuView) {
        _menuView = [[PDFMenuView alloc] initWithFrame:self.view.frame];
        _menuView.hidden = YES;
        _menuView.delegate = self;
        _menuView.page = (int)_readerView.pageNO;
        _menuView.fileName = self.fileName==nil?@"":self.fileName;
        _menuView.backColor = self.backColor == nil?[UIColor blackColor]:self.backColor;
        _menuView.alphaValue = self.alphaValue == 0.0f?1.0f:self.alphaValue;
        _menuView.pageCount = (int)_Count;
    }
    return _menuView;
}
-(void)showToolMenu
{
    [self.menuView showAnimation:YES];
}
#pragma mark - Menu View Delegate
-(void)menuViewJumpPageWithTag:(int)Tag
{
    if(_Count<=0)
        return;
    if (Tag == 0) {
        //上一页
        int index = _readerView.pageNO;
        if (index==1) {
            _menuView.page = 1;//不用改变，页面不变
        }else{
            //上一个页面的设置
            _menuView.page = (int)index-1;
            //查找_subViewControls 里面是否存在
            if([self SubViewsIsExt:index-1])
            {
                _readerView =[self ReturnView:index-1];
                NSInteger tempIndex = [_subViewControls indexOfObject:_readerView];
                [_pageViewCtrl setViewControllers:@[_subViewControls[tempIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            }else
            {
                ZPDFPageController *subViewController = [self viewControllerAtIndex:index-1];
                _readerView =subViewController;
                [_subViewControls addObject:subViewController];
                [self SubViewControlsChange];
                NSInteger tempIndex = [_subViewControls indexOfObject:subViewController];
                [_pageViewCtrl setViewControllers:@[_subViewControls[tempIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            }
        }
        if (_readerView.pageNO ==1) {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderFristViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderFristViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }else
        {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderAfterViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderAfterViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }
    }else
    {
        //下一页
        int index = _readerView.pageNO;
        if (index==_Count) {
            _menuView.page = (int)_Count;
        }else{
            _menuView.page = (int)index+1;
            //查找_subViewControls 里面是否存在
            if([self SubViewsIsExt:index+1])
            {
                _readerView =[self ReturnView:index+1];
                NSInteger tempIndex = [_subViewControls indexOfObject:_readerView];
                [_pageViewCtrl setViewControllers:@[_subViewControls[tempIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            }else{
                ZPDFPageController *subViewController = [self viewControllerAtIndex:index+1];
                _readerView =subViewController;
                [_subViewControls addObject:subViewController];
                NSInteger tempIndex = [_subViewControls indexOfObject:subViewController];
                [_pageViewCtrl setViewControllers:@[_subViewControls[tempIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            }
        }
        if (_readerView.pageNO == _Count) {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderLastViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderLastViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }else
        {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderAfterViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderAfterViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }
    }
    _pdfPageModel.pageNO = _readerView.pageNO;
}
-(void)menuViewBack
{
    [ZPDFPageModel updateLocalModel:_pdfPageModel url:url];
}
#pragma mark -UIPageViewControllerDelegate,UIPageViewControllerDataSource
//翻页控制器进行向前翻页动作 这个数据源方法返回的视图控制器为要显示视图的视图控制器
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    if(_Count<=0)
        return nil;
    int index = (int)[self indexOfViewController: (ZPDFPageController *)viewController];
    if (index==1) {
        _menuView.page = 1;//不用改变，页面不变
        if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderFristViewController:WithIndex:)]) {
            [_delegate LSYPDFReaderFristViewController:_readerView WithIndex:_readerView.pageNO];
        }
    }else{
        ///上一个页面的设置
        _menuView.page = (int)index-1;
        //查找_subViewControls 里面是否存在
        if([self SubViewsIsExt:index-1])
        {
            _readerView =[self ReturnView:index-1];
        }
        else
        {
            ZPDFPageController *subViewController = [self viewControllerAtIndex:index-1];
            _readerView =subViewController;
            [_subViewControls addObject:subViewController];
            [self SubViewControlsChange];
            
        }
        if (_readerView.pageNO == 1) {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderFristViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderFristViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }else
        {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderAfterViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderAfterViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }
        return _readerView;
    }
    return nil;
}
//翻页控制器进行向后翻页动作 这个数据源方法返回的视图控制器为要显示视图的视图控制器
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    if(_Count<=0)
        return nil;
    int index = (int)[self indexOfViewController: (ZPDFPageController *)viewController];
    if (index==_Count) {
        _menuView.page = (int)_Count;
        if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderLastViewController:WithIndex:)]) {
            [_delegate LSYPDFReaderLastViewController:_readerView WithIndex:_readerView.pageNO];
        }
    }else{
        _menuView.page = (int)index+1;
        //查找_subViewControls 里面是否存在
        if([self SubViewsIsExt:index+1])
        {
            _readerView =[self ReturnView:index+1];
        }else
        {
            ZPDFPageController *subViewController = [self viewControllerAtIndex:index+1];
            _readerView =subViewController;
            [_subViewControls addObject:subViewController];
        }
        if (_readerView.pageNO == _Count) {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderLastViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderLastViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }else
        {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(LSYPDFReaderAfterViewController:WithIndex:)]) {
                [_delegate LSYPDFReaderAfterViewController:_readerView WithIndex:_readerView.pageNO];
            }
        }
        return _readerView;
    }
    return nil;
}
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(_Count<=0)
        return;
    if (!completed) {
        ZPDFPageController *readView = (ZPDFPageController *)previousViewControllers.firstObject;
        _readerView = readView;
        _pdfPageModel.pageNO = _readerView.pageNO;
    }
    else{
        _pdfPageModel.pageNO = _readerView.pageNO;
    }
}

- (NSUInteger)indexOfViewController:(ZPDFPageController *)viewController {
    return viewController.pageNO;
}
-(void)SubViewControlsChange
{
    if (_subViewControls== nil || _subViewControls.count<=0)
        return;
    for (NSInteger i = _subViewControls.count -1; i > 0; i--)
    {
        ZPDFPageController *I = _subViewControls[i];
        for (int j =0; j< i; j++)
        {
            ZPDFPageController *J = _subViewControls[j];
            if(I.pageNO< J.pageNO)
            {
                [_subViewControls exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}
-(bool)SubViewsIsExt:(int)pageNo
{
    bool isExt = NO;
    if (_subViewControls== nil || _subViewControls.count<=0)
        return isExt;
    for (NSInteger i = 0; i <= _subViewControls.count -1; i++)
    {
        ZPDFPageController *I = _subViewControls[i];
        if (pageNo==I.pageNO) {
            isExt = YES;
        }
    }
    return isExt;
}
-(ZPDFPageController *)ReturnView:(int)pageNo
{
    ZPDFPageController *isExtView = nil;
    if (_subViewControls== nil || _subViewControls.count<=0)
        return isExtView;
    for (NSInteger i = 0; i <= _subViewControls.count -1; i++)
    {
        ZPDFPageController *I = _subViewControls[i];
        if (pageNo==I.pageNO) {
            isExtView = I;
        }
    }
    return isExtView;
}
- (ZPDFPageController *)viewControllerAtIndex:(int)pageNO {
    long pageSum = CGPDFDocumentGetNumberOfPages(_pdfDocument);
    if (pageSum== 0 || pageNO >= pageSum+1) {
        return nil;
    }
    ZPDFPageController *pageController = [[ZPDFPageController alloc] init];
    pageController.pdfDocument = _pdfDocument;
    pageController.pageNO  = pageNO;
    pageController.pageViewController = _pageViewCtrl;
    return pageController;
}

@end

#pragma mark-PDFMenuView

@interface PDFMenuView ()
@property (nonatomic,strong) UIButton *back;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *lastBtn;
@property (nonatomic,strong) UIButton *nextBtn;
@property (nonatomic,strong) UILabel *pageLabel;
@property (nonatomic,strong) UILabel *titleLabel;
@end
@implementation PDFMenuView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenSelf)]];
}
-(UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, -TopViewHeight, ViewSize(self).width,TopViewHeight)];
        [_topView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85]];
    }
    [_topView addSubview:self.back];
    [_topView addSubview:self.titleLabel];
    return _topView;
}
-(UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ViewSize(self).height, ViewSize(self).width,TopViewHeight)];
        [_bottomView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85]];
    }
    [_bottomView addSubview:self.lastBtn];
    [_bottomView addSubview:self.nextBtn];
    [_bottomView addSubview:self.pageLabel];
    return _bottomView ;
}
-(UIButton *)back
{
    if (!_back) {
        _back = [LSYReadUtilites commonButtonSEL:@selector(backView) target:self];
        _back.frame = CGRectMake(0, 24, 40, 40);
        [_back setImage:[UIImage imageWithContentsOfFile:[LSYReadUtilites getImagWithPath:@"bg_back_white@2x.png"]] forState:UIControlStateNormal];
    }
    return _back;
}
-(UIButton *)lastBtn
{
    if (!_lastBtn) {
        _lastBtn = [LSYReadUtilites commonButtonSEL:@selector(lastOrNextImageView:) target:self];
        _lastBtn.frame = CGRectMake(30, (TopViewHeight-30)/2, 50, 30);
        _lastBtn.tag = 0;
        [_lastBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_lastBtn setTitle:@"上一页" forState:UIControlStateNormal];
    }
    return _lastBtn;
}
-(UIButton *)nextBtn
{
    if (!_nextBtn) {
        _nextBtn = [LSYReadUtilites commonButtonSEL:@selector(lastOrNextImageView:) target:self];
        _nextBtn.frame = CGRectMake(ViewSize(self).width-80, (TopViewHeight-30)/2, 50, 30);
        _nextBtn.tag = 1;
        [_nextBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_nextBtn setTitle:@"下一页" forState:UIControlStateNormal];
    }
    return _nextBtn;
}
-(UILabel *)pageLabel
{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, (TopViewHeight-30)/2, ViewSize(self).width-180, 30)];
        _pageLabel.font = [UIFont systemFontOfSize:15];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _pageLabel;
}
-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 24, ViewSize(self).width-100, 40)];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
-(void)setPage:(int)page
{
    _page = page;
    _pageLabel.text = [NSString stringWithFormat:@"%d/%d",_page,_pageCount];
}
-(void)setPageCount:(int)pageCount
{
    _pageCount = pageCount;
    _pageLabel.text = [NSString stringWithFormat:@"%d/%d",_page,_pageCount];
}
-(void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    _titleLabel.text = [NSString stringWithFormat:@"%@",_fileName];
}
-(void)setBackColor:(UIColor *)backColor
{
    _backColor = backColor;
    [_topView setBackgroundColor:[_backColor colorWithAlphaComponent:1]];
    [_bottomView setBackgroundColor:[_backColor colorWithAlphaComponent:1]];
}
-(void)setAlphaValue:(float)alphaValue
{
    _alphaValue = alphaValue;
    [_topView setBackgroundColor:[_backColor colorWithAlphaComponent:_alphaValue]];
    [_bottomView setBackgroundColor:[_backColor colorWithAlphaComponent:_alphaValue]];
}
-(void)backView
{
    if ([self.delegate respondsToSelector:@selector(menuViewBack)]) {
        [self.delegate menuViewBack];
    }
    [[LSYReadUtilites getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
}
-(void)lastOrNextImageView:(UIButton *)sender
{
    if (sender == _nextBtn) {
        if ([self.delegate respondsToSelector:@selector(menuViewJumpPageWithTag:)]) {
            [self.delegate menuViewJumpPageWithTag:(int)sender.tag];
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(menuViewJumpPageWithTag:)]) {
            [self.delegate menuViewJumpPageWithTag:(int)sender.tag];
        }
    }
}
#pragma mark-Animation
-(void)hiddenSelf
{
    [self hiddenAnimation:YES];
}
-(void)showAnimation:(BOOL)animation
{
    self.hidden = NO;
    [UIView animateWithDuration:animation?AnimationDelay:0 animations:^{
        _topView.frame = CGRectMake(0, 0, ViewSize(self).width, TopViewHeight);
        _bottomView.frame = CGRectMake(0, ViewSize(self).height-TopViewHeight, ViewSize(self).width, TopViewHeight);
    } completion:^(BOOL finished) {
        
    }];
    if ([self.delegate respondsToSelector:@selector(menuViewDidAppear:)]) {
        [self.delegate menuViewDidAppear:self];
    }
}
-(void)hiddenAnimation:(BOOL)animation
{
    [UIView animateWithDuration:animation?AnimationDelay:0 animations:^{
        _topView.frame = CGRectMake(0, -TopViewHeight, ViewSize(self).width, TopViewHeight);
        _bottomView.frame = CGRectMake(0, ViewSize(self).height, ViewSize(self).width,TopViewHeight);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    if ([self.delegate respondsToSelector:@selector(menuViewDidHidden:)]) {
        [self.delegate menuViewDidHidden:self];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
}
@end

