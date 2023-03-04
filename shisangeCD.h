
//  WX:NongShiFu123
//  QQ:350722326
//  Created by  十三哥 on 2023/2/21.
//


NS_ASSUME_NONNULL_BEGIN
typedef void (^子功能)(void);
typedef void (^执行函数)(void);
typedef UIView* _Nullable (^自定义视图)(UIView*);
extern bool 是否过直播;
@interface shisangeCD : UIView<UITextFieldDelegate>
+ (UIWindow *)获取顶层视图;
+ (void)悬浮图标;
+ (void)添加分组:(NSString *)标题 分组说明:(NSString *)分组说明 是否展开:(BOOL)是否展开 功能数:(int)功能数 子功能:(子功能)子功能;
+ (void)添加开关:(NSString *)标题 开启:(执行函数)开启 关闭:(执行函数)关闭;
+ (void)添加按钮:(NSString *)标题 点击操作:(执行函数)点击操作 尺寸:(CGRect)Rect;
+ (UIView *)添加自定义视图:(UIView *)视图;
+ (void)过直播调用:(BOOL)开关;
@end

NS_ASSUME_NONNULL_END
