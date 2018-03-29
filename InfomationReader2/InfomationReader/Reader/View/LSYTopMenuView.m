//
//  LSYTopMenuView.m
//  LSYReader
//
//  Created by Labanotation on 16/6/1.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "LSYTopMenuView.h"
#import "LSYMenuView.h"
#import "LSYReadUtilites.h"
#define ViewSize(view)  (view.frame.size)

@interface LSYTopMenuView ()
@property (nonatomic,strong) UIButton *back;
@property (nonatomic,strong) UILabel *titleLabel;
@end
@implementation LSYTopMenuView
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
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [self addSubview:self.back];
    [self addSubview:self.titleLabel];
}
-(UIButton *)back
{
    if (!_back) {
        _back = [LSYReadUtilites commonButtonSEL:@selector(backView) target:self];
        [_back setImage:[UIImage imageWithContentsOfFile:[LSYReadUtilites getImagWithPath:@"bg_back_white@2x.png"]] forState:UIControlStateNormal];
    }
    return _back;
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
-(void)TopMenuViewChangeFileName:(NSString *)fileName BackColor:(UIColor *)backColor AlphaValue:(float)alphaValue
{
    _titleLabel.text = [NSString stringWithFormat:@"%@",fileName];
    [self setBackgroundColor:[backColor colorWithAlphaComponent:alphaValue]];
}
-(void)backView
{
    [[LSYReadUtilites getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    _back.frame = CGRectMake(0, 24, 40, 40);
//    _more.frame = CGRectMake(ViewSize(self).width-50, 24, 40, 40);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
