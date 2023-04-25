#import "Class.h"
#import "shisangeCD.h"
#define kuandu  [UIScreen mainScreen].bounds.size.width
#define gaodu [UIScreen mainScreen].bounds.size.height
#import <AVFoundation/AVFoundation.h>
@interface SkillView : UIView
@property UIView* 技能1;
@property UIView* 技能2;
@property UIView* 技能3;
@property UIView* 技能4;
@end

@implementation SkillView
@end

@interface Smoba : UIView
- (void) 初始化视图;
@property (nonatomic, strong) dispatch_source_t jctimer;
@property (nonatomic, strong) dispatch_source_t hztimer;
@end

Smoba* IView;


@implementation Smoba
CAShapeLayer *小地图野怪血圈视图[100];
CAShapeLayer *小地图野怪血圈背景视图[100];
UILabel *野怪血量[100];
CAShapeLayer* 小地图方框样式;
CAShapeLayer* 血背景样式;
CAShapeLayer* 血圈景样式;
CAShapeLayer* 大图血圈样式;
UIBezierPath* 小地图方框路径;
UIBezierPath* Path_血背景;
UIBezierPath* Path_血圈;
UIBezierPath* Path_大地图血圈路径;

UIImageView* 小地图英雄头像视图[10];
UIImageView* 技能表英雄头像视图[10];
UIImageView* 大招图标视图[10];
UIImageView* 方框技能图标视图[10];
UILabel* 技能时间[10];
UILabel* 大招时间[10];
SkillView* 技能小点视图[10];
Vector2 GameCanvas;
Vector2 小地图;
std::vector<SaveImage> NetImage;
float 屏幕宽度,屏幕高度;
static bool GameMV;
static UIWindow* 根视图;
static float 初始音量;
float mapx,mapy,半径,技能绘制x调节,技能绘制y调节,R;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self 初始化视图];
        });
    }
    return self;
}

+(void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mapx =[[NSUserDefaults standardUserDefaults] floatForKey:@"mapx"];
            mapy =[[NSUserDefaults standardUserDefaults] floatForKey:@"mapy"];
            技能绘制x调节=[[NSUserDefaults standardUserDefaults] floatForKey:@"技能绘制x调节"];
            技能绘制y调节=[[NSUserDefaults standardUserDefaults] floatForKey:@"技能绘制y调节"];
            
            IView = [[Smoba alloc] init];
            [IView 定时器];
        });
    });
}


+ (UIViewController *)fetchViewControllerFromRootViewController
{
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (vc) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
+ (UIWindow *)获取顶层视图{
    UIWindow*顶层视图=[UIApplication sharedApplication].keyWindow;
    if (顶层视图.windowLevel !=UIWindowLevelNormal) {
        NSArray*arr=[UIApplication sharedApplication].windows;
        for (UIWindow*tmp in arr) {
            if (tmp.windowLevel == UIWindowLevelNormal) {
                顶层视图=tmp;
                break;
            }
        }
    }
    return 顶层视图;
}

-(void)定时器
{
    if (!self.jctimer || !dispatch_source_testcancel(self.jctimer)) {
        // 创建定时器
        self.jctimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        // 设置定时器的触发时间、间隔时间和精度
        uint64_t interval = 5 * NSEC_PER_SEC; // 定时器间隔时间为 1 秒
        uint64_t leeway = 0.1 * NSEC_PER_SEC; // 定时器精度为 0.1 秒
        dispatch_source_set_timer(self.jctimer, DISPATCH_TIME_NOW, interval, leeway);
        // 设置定时器的任务
        dispatch_source_set_event_handler(self.jctimer, ^{
            // 定时器触发时执行的代码块
            GameMV=Gameinitialization();
            if (GameMV){
                屏幕宽度 = [UIScreen mainScreen].bounds.size.width;
                屏幕高度 = [UIScreen mainScreen].bounds.size.height;
                IView.userInteractionEnabled=NO;
                IView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                IView.frame=CGRectMake(0, 0, 屏幕高度, 屏幕宽度);
                根视图=[Smoba 获取顶层视图];
                [根视图 addSubview:IView];
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [IView 初始化视图];
                });
                
                [self 绘制定时器];
                
            }else{
                NSLog(@"判断定时器是否存在");
                // 判断定时器是否存在
                if (self.hztimer==nil) {
                    // 定时器已经被取消
                    NSLog(@"定时器已经被取消");
                } else {
                    // 定时器还存在
                    NSLog(@"定时器还存在");
                    dispatch_source_cancel(self.hztimer);
                    self.hztimer = nil;
                }
                
            }
        });
        
        // 启动定时器
        dispatch_resume(self.jctimer);
    }
    
}

- (void)绘制过直播:(BOOL)开关
{

}
- (void) 初始化视图
{
    
    self.backgroundColor = [UIColor clearColor];
    [self setUserInteractionEnabled:NO];
    
    GameCanvas.横轴x = 屏幕宽度;
    GameCanvas.大小 = 屏幕高度;
    
    
    小地图方框样式 = [[CAShapeLayer alloc] init];
    小地图方框样式.frame = self.frame;
    小地图方框样式.strokeColor = UIColor.greenColor.CGColor;//方框颜色
    小地图方框样式.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:小地图方框样式];//标记
    
    血背景样式 = [[CAShapeLayer alloc] init];
    血背景样式.frame = self.frame;
    血背景样式.lineWidth=3;
    血背景样式.strokeColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3].CGColor;//方框颜色
    血背景样式.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:血背景样式];//标记
    
    
    血圈景样式 = [[CAShapeLayer alloc] init];
    血圈景样式.frame = self.frame;
    血圈景样式.lineWidth=3;
    血圈景样式.strokeColor = UIColor.redColor.CGColor;//方框颜色
    血圈景样式.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:血圈景样式];//标记
    
    大图血圈样式 = [[CAShapeLayer alloc] init];
    大图血圈样式.frame = self.frame;
    大图血圈样式.lineWidth=1;
    大图血圈样式.strokeColor = UIColor.redColor.CGColor;//方框颜色
    大图血圈样式.fillColor = UIColor.redColor.CGColor;
    [self.layer addSublayer:大图血圈样式];//标记
    
    
    
    for (int i=0; i<10; i++) {
        小地图英雄头像视图[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        小地图英雄头像视图[i].backgroundColor = [UIColor clearColor];
        小地图英雄头像视图[i].layer.masksToBounds = YES;
        小地图英雄头像视图[i].hidden=YES;
        小地图英雄头像视图[i].layer.borderColor = [UIColor redColor].CGColor;
        小地图英雄头像视图[i].layer.borderWidth = 0.5;
        [self addSubview:小地图英雄头像视图[i]];
    }
    
    for (int i=0; i<10; i++) {
        技能表英雄头像视图[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        技能表英雄头像视图[i].backgroundColor = [UIColor clearColor];
        技能表英雄头像视图[i].layer.masksToBounds = YES;
        技能表英雄头像视图[i].hidden=YES;
        技能表英雄头像视图[i].layer.borderColor = [UIColor redColor].CGColor;
        技能表英雄头像视图[i].layer.borderWidth = 0.f;
        [self addSubview:技能表英雄头像视图[i]];
    }
    
    for (int i=0; i<10; i++) {
        大招图标视图[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        大招图标视图[i].backgroundColor = [UIColor clearColor];
        大招图标视图[i].layer.masksToBounds = YES;
        大招图标视图[i].hidden=YES;
        大招图标视图[i].layer.borderColor = [UIColor redColor].CGColor;
        大招图标视图[i].layer.borderWidth = 0.f;
        [self addSubview:大招图标视图[i]];
    }
    
    for (int i=0; i<10; i++) {
        技能时间[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        技能时间[i].text = nil;
        技能时间[i].numberOfLines = 0;
        技能时间[i].lineBreakMode = NSLineBreakByCharWrapping;
        技能时间[i].textAlignment = NSTextAlignmentCenter;
        技能时间[i].font = [UIFont boldSystemFontOfSize:20];
        技能时间[i].textColor = [UIColor whiteColor];
        [self addSubview:技能时间[i]];
    }
    
    for (int i=0; i<10; i++) {
        大招时间[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        大招时间[i].text = nil;
        大招时间[i].numberOfLines = 0;
        大招时间[i].lineBreakMode = NSLineBreakByCharWrapping;
        大招时间[i].textAlignment = NSTextAlignmentCenter;
        大招时间[i].font = [UIFont boldSystemFontOfSize:20];
        大招时间[i].textColor = [UIColor whiteColor];
        [self addSubview:大招时间[i]];
    }
    
    
    
    for (int i=0; i<10; i++) {
        技能小点视图[i] = [[SkillView alloc] initWithFrame:CGRectMake(0, 0, 80, 16)];
        技能小点视图[i].技能1 = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 16, 16)];
        技能小点视图[i].技能2 = [[UIView alloc] initWithFrame:CGRectMake(22, 0, 16, 16)];
        技能小点视图[i].技能3 = [[UIView alloc] initWithFrame:CGRectMake(42, 0, 16, 16)];
        技能小点视图[i].技能4 = [[UIView alloc] initWithFrame:CGRectMake(62, 0, 16, 16)];
        
        [技能小点视图[i] addSubview:技能小点视图[i].技能1];
        [技能小点视图[i] addSubview:技能小点视图[i].技能2];
        [技能小点视图[i] addSubview:技能小点视图[i].技能3];
        [技能小点视图[i] addSubview:技能小点视图[i].技能4];
        
        技能小点视图[i].技能1.backgroundColor = [UIColor greenColor];
        技能小点视图[i].技能1.layer.masksToBounds = YES;
        技能小点视图[i].技能1.layer.cornerRadius = 8;
        技能小点视图[i].技能1.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        技能小点视图[i].技能1.layer.borderWidth = 1.f;
        
        技能小点视图[i].技能2.backgroundColor = [UIColor greenColor];
        技能小点视图[i].技能2.layer.masksToBounds = YES;
        技能小点视图[i].技能2.layer.cornerRadius = 8;
        技能小点视图[i].技能2.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        技能小点视图[i].技能2.layer.borderWidth = 1.f;
        
        技能小点视图[i].技能3.backgroundColor = [UIColor greenColor];
        技能小点视图[i].技能3.layer.masksToBounds = YES;
        技能小点视图[i].技能3.layer.cornerRadius = 8;
        技能小点视图[i].技能3.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        技能小点视图[i].技能3.layer.borderWidth = 1.f;
        
        技能小点视图[i].技能4.backgroundColor = [UIColor greenColor];
        技能小点视图[i].技能4.layer.masksToBounds = YES;
        技能小点视图[i].技能4.layer.cornerRadius = 8;
        技能小点视图[i].技能4.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        技能小点视图[i].技能4.layer.borderWidth = 1.f;
        
        技能小点视图[i].backgroundColor = [UIColor clearColor];
        [技能小点视图[i] setHidden:YES];
        [self addSubview:技能小点视图[i]];
        
        
    }
    
    for (int i=0; i<30; i++) {
        小地图野怪血圈背景视图[i] = [CAShapeLayer layer];
        小地图野怪血圈背景视图[i].fillColor = [UIColor blackColor].CGColor;
        小地图野怪血圈背景视图[i].strokeColor = [UIColor blackColor].CGColor;
        小地图野怪血圈背景视图[i].lineWidth = 1;
        [self.layer addSublayer:小地图野怪血圈背景视图[i]];
        
        小地图野怪血圈视图[i] = [CAShapeLayer layer];
        小地图野怪血圈视图[i].fillColor = [UIColor whiteColor].CGColor;
        小地图野怪血圈视图[i].strokeColor = [UIColor whiteColor].CGColor;
        小地图野怪血圈视图[i].lineWidth = 1;
        [self.layer addSublayer:小地图野怪血圈视图[i]];
        
        
    }
    
    
    
}
//技能倒计时调节
- (void) 绘制定时器{
    if (!self.hztimer || !dispatch_source_testcancel(self.hztimer)) {
        // 创建定时器
        self.hztimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        
        // 设置定时器的触发时间、间隔时间和精度
        uint64_t interval = 0.05 * NSEC_PER_SEC; // 定时器间隔时间为 1 秒
        uint64_t leeway = 0 * NSEC_PER_SEC; // 定时器精度为 0.1 秒
        dispatch_source_set_timer(self.hztimer, DISPATCH_TIME_NOW, interval, leeway);
        
        // 设置定时器的任务
        dispatch_source_set_event_handler(self.hztimer, ^{
            // 定时器触发时执行的代码块
            
            [self Drawing];
        });
        // 启动定时器
        dispatch_resume(self.hztimer);
    }
}

bool 透视开关,血条开关,射线开关,方框开关,技能开关,野怪绘制开关;
static int YXsum = 0;
- (void) Drawing
{
    小地图.横轴x = mapx;
    小地图.大小 = mapy;
    
    for (int i=0; i<10; i++) {
        [小地图英雄头像视图[i] setHidden:YES];
        [技能小点视图[i] setHidden:YES];
        
        [技能表英雄头像视图[i] setHidden:YES];
        [大招图标视图[i] setHidden:YES];
        [方框技能图标视图[i] setHidden:YES];
        [技能时间[i] setHidden:YES];
        [大招时间[i] setHidden:YES];
    }
    for (int i=0; i<30; i++) {
        [小地图野怪血圈视图[i] setHidden:YES];
        [小地图野怪血圈背景视图[i] setHidden:YES];
        
    }
    
    小地图方框路径 = [[UIBezierPath alloc] init];
    Path_血圈 = [[UIBezierPath alloc] init];
    Path_血背景 = [[UIBezierPath alloc] init];
    Path_大地图血圈路径 = [[UIBezierPath alloc] init];
    
    if (GameMV && 透视开关)
    {
        [小地图方框路径 appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(小地图.横轴x, 0, 小地图.大小, 小地图.大小)]];
        if (RefreshMatrix())
        {
            std::vector<SmobaHeroData> 读取英雄数据;
            GetPlayers(&读取英雄数据);
            if (读取英雄数据.size() > 0)
            {
                YXsum = 0;
                for (int i=0; i<读取英雄数据.size(); i++) {
                    Vector2 BoxPos;
                    if (!读取英雄数据[i].Dead)
                    {
                        if (ToScreen(GameCanvas,读取英雄数据[i].Pos,&BoxPos))
                        {
                            //小地图头像
                            Vector2 MiniPos = ToMiniMap(小地图, 读取英雄数据[i].Pos);
                            R=小地图.大小/14;
                            小地图英雄头像视图[i].image = GetHeroImage(读取英雄数据[i].英雄ID);
                            小地图英雄头像视图[i].layer.cornerRadius = R;
                            if (小地图英雄头像视图[i].image==nil ||小地图英雄头像视图[i].image==NULL) {
                                continue;
                            }
                            [小地图英雄头像视图[i] setHidden:NO];
                            [小地图英雄头像视图[i] setFrame:CGRectMake(MiniPos.横轴x-R, MiniPos.大小-R, R*2, R*2)];
                            //小地血圈圈条
                            if(血条开关)
                            {
                                float 血量 =读取英雄数据[i].HP;
                                //小地图
                                UIBezierPath *Line = [UIBezierPath bezierPathWithArcCenter:CGPointMake(MiniPos.横轴x,MiniPos.大小) radius:半径 startAngle:(0) endAngle:M_PI*2 clockwise:true];
                                [Path_血背景 appendPath:Line];
                                
                                UIBezierPath *Line3 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(MiniPos.横轴x,MiniPos.大小) radius:半径 startAngle:(0) endAngle:M_PI*2*血量 clockwise:true];
                                [Path_血圈 appendPath:Line3];
                                //大地图
                                [Path_大地图血圈路径 appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(BoxPos.横轴x-19, BoxPos.大小-14, 38*血量, 5)]];
                                
                            }
                        }
                        if (射线开关) {
                            UIBezierPath *bezierPath = [UIBezierPath bezierPath];
                            [bezierPath moveToPoint:CGPointMake(屏幕宽度/2, 屏幕高度/2)];
                            [bezierPath addLineToPoint:CGPointMake(BoxPos.横轴x, BoxPos.大小-20)];
                            
                            [小地图方框路径 appendPath:bezierPath];
                        }
                        if (方框开关)
                        {
                            [小地图方框路径 appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(BoxPos.横轴x-20, BoxPos.大小-48, 40, 40)]];
                        }
                        //方框下面的技能点
                        if (技能开关)
                        {
                            //方框下面的技能点
                            技能小点视图[i].center = CGPointMake(BoxPos.横轴x, BoxPos.大小+10);
                            [技能小点视图[i] setHidden:NO];
                            技能小点视图[i].技能1.backgroundColor = 读取英雄数据[i].Skill1?[UIColor greenColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            技能小点视图[i].技能2.backgroundColor = 读取英雄数据[i].Skill2?[UIColor greenColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            技能小点视图[i].技能3.backgroundColor = 读取英雄数据[i].Skill3?[UIColor greenColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            技能小点视图[i].技能4.backgroundColor = 读取英雄数据[i].Skill4?[UIColor redColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            
                            
                        }
                        
                        
                    }
                    if (技能开关) {
                        YXsum++;
                        //绘制人物头像
                        技能表英雄头像视图[i].image = GetHeroImage(读取英雄数据[i].英雄ID);
                        [技能表英雄头像视图[i] setFrame:CGRectMake(技能绘制x调节 + (技能绘制y调节+3)*YXsum, 0, 技能绘制y调节, 技能绘制y调节)];
                        
                        //绘制召唤师技能
                        大招图标视图[i].image = GetHeroImage(读取英雄数据[i].HeroTalent);
                        [大招图标视图[i] setFrame:CGRectMake(技能绘制x调节 + (技能绘制y调节+3)*YXsum, 技能绘制y调节+10, 技能绘制y调节, 技能绘制y调节)];
                        
                        //召唤师技能时间显示
                        if(读取英雄数据[i].仅能倒计时 == 0){
                            大招图标视图[i].layer.borderColor = [UIColor redColor].CGColor;
                            技能时间[i].text = nil;
                            
                        }
                        else{
                            大招图标视图[i].layer.borderColor = [UIColor clearColor].CGColor;
                            NSString *stringValue = [NSString stringWithFormat:@"%d", (读取英雄数据[i].仅能倒计时)];
                            技能时间[i].text = stringValue;
                            
                        }
                        
                        //召唤师大招时间
                        if(读取英雄数据[i].大招倒计时 == 0){
                            大招时间[i].text = nil;
                        }
                        else{
                            NSString *stringValue = [NSString stringWithFormat:@"%d", (读取英雄数据[i].大招倒计时)];
                            大招时间[i].text = stringValue;
                        }
                        
                        //绘制技能时间
                        [技能时间[i] setFrame:CGRectMake(技能绘制x调节 + (技能绘制y调节+3)*YXsum, 技能绘制y调节+10, 技能绘制y调节, 技能绘制y调节)];
                        //绘制大招时间
                        [大招时间[i] setFrame:CGRectMake(技能绘制x调节 + (技能绘制y调节+3)*YXsum, 技能绘制y调节/2, 技能绘制y调节, 技能绘制y调节)];
                        
                        //显示全部控件
                        [技能表英雄头像视图[i] setHidden:NO];
                        [技能时间[i] setHidden:NO];
                        [大招时间[i] setHidden:NO];
                        [大招图标视图[i] setHidden:NO];
                        
                        
                    }
                    
                }
                //==================大地图野怪====================
                Vector2 MonsterScreen;
                if (野怪绘制开关) {
                    for (int i= 0; i < 野怪数据.size(); i++) {
                        if (野怪数据[i].野怪当前血量 > 0) {
                            if (ToScreen(GameCanvas,野怪数据[i].MonsterPos,&MonsterScreen)){
                                Vector2 MiniMonsterPos = ToMiniMap(小地图, 野怪数据[i].MonsterPos);
                                //野怪背景
                                UIBezierPath *MonsterPath2 = [UIBezierPath bezierPath];
                                [MonsterPath2 addArcWithCenter:CGPointMake(MiniMonsterPos.横轴x,MiniMonsterPos.大小) radius:4 startAngle:0 endAngle:M_PI*2 clockwise:true];
                                小地图野怪血圈背景视图[i].path = MonsterPath2.CGPath;
                                [小地图野怪血圈背景视图[i] setHidden:NO];
                                
                                //野怪血圈
                                UIBezierPath *MonsterPath = [UIBezierPath bezierPath];
                                [MonsterPath moveToPoint:CGPointMake(MiniMonsterPos.横轴x,MiniMonsterPos.大小)];
                                [MonsterPath addArcWithCenter:CGPointMake(MiniMonsterPos.横轴x,MiniMonsterPos.大小) radius:3 startAngle:0 endAngle:M_PI*2*野怪数据[i].野怪当前血量/野怪数据[i].野怪最大血量 clockwise:true];
                                [MonsterPath addLineToPoint:CGPointMake(MiniMonsterPos.横轴x,MiniMonsterPos.大小)];
                                小地图野怪血圈视图[i].path = MonsterPath.CGPath;
                                [小地图野怪血圈视图[i] setHidden:NO];
                                
                                
                            }
                        }
                    }
                    
                }
            }
        }
    }
    小地图方框样式.path = 小地图方框路径.CGPath;
    血背景样式.path = Path_血背景.CGPath;
    血圈景样式.path = Path_血圈.CGPath;
    大图血圈样式.path = Path_大地图血圈路径.CGPath;
}

static void NetGetHeroImage(int HeroID)
{
    NSString*urlstring=[NSString stringWithFormat:@"https://qmui.oss-cn-hangzhou.aliyuncs.com/CIKEimage/%d.png",HeroID];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length < 1000)
    {
        for (int i=0; i<50; i++) {
            data = [NSData dataWithContentsOfURL:url];
            if (data.length > 1000) break;
        }
    }
    
    SaveImage Temp;
    Temp.HeroID = HeroID;
    Temp.Image = [UIImage imageWithData:data];
    NetImage.push_back(Temp);
}

static UIImage* GetHeroImage(int HeroID)
{
    for (int i=0;i<NetImage.size();i++)
    {
        if (NetImage[i].HeroID == HeroID) return NetImage[i].Image;
    }
    NetGetHeroImage(HeroID);
    return NetImage[NetImage.size()-1].Image;
}


@end
