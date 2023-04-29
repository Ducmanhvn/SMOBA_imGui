//
//  ViewController.h
//  Radar
//
//  Created by 十三哥 on 2022/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
extern bool 透视开关,血条开关,射线开关,方框开关,技能开关,野怪绘制开关,过直播开关;
extern float mapx,mapy,半径,技能绘制x调节,技能绘制y调节;
@interface Smoba : UIView

- (void)绘制过直播:(BOOL)开关;

@end

NS_ASSUME_NONNULL_END
