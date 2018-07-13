#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DDYBtnStyle) {
    DDYBtnStyleImgLeft           = 0,     // 左图右文，整体居中，设置间隙
    DDYBtnStyleImgRight          = 1,     // 左文右图，整体居中，设置间隙
    DDYBtnStyleImgTop            = 2,     // 上图下文，整体居中，设置间隙
    DDYBtnStyleImgDown           = 3,     // 下图上文，整体居中，设置间隙
    DDYBtnStyleNaturalImgLeft    = 4,     // 左图右文，自然对齐，两端对齐
    DDYBtnStyleNaturalImgRight   = 5,     // 左文右图，自然对齐，两端对齐
    DDYBtnStyleImgLeftThenLeft   = 6,     // 左图右文，整体居左，设置间隙
    DDYBtnStyleImgRightThenLeft  = 7,     // 左图右文，整体居左，设置间隙
    DDYBtnStyleImgRightThenRight = 8,     // 左图右文，整体居右，设置间隙
    DDYBtnStyleImgLeftThenRight  = 9,     // 左文右图，整体居左，设置间隙
};

@interface UIButton (DDYExtension)
/** 布局方式 */
@property (nonatomic, assign) DDYBtnStyle btnStyle;
/** 图文间距 */
@property (nonatomic, assign) CGFloat padding;

- (void)ddy_SetStyle:(DDYBtnStyle)style padding:(CGFloat)padding;

@end
