#import "Class.h"
#import "shisangeCD.h"
#define kuandu  [UIScreen mainScreen].bounds.size.width
#define gaodu [UIScreen mainScreen].bounds.size.height

@interface SkillView : UIView
@property UIView* Skill1;
@property UIView* Skill2;
@property UIView* Skill3;
@property UIView* Skill4;
@end

@implementation SkillView
@end

@interface TestSmoba : UIView
- (void) Start;
@end

TestSmoba* IView;


@implementation TestSmoba
CAShapeLayer *MsMonsterView[100];
CAShapeLayer *MsMonsterRect[100];

UILabel *野怪血量[100];
CAShapeLayer* Draw_HP;
UIBezierPath* Path_HP;
CAShapeLayer* Draw_Rect;
CAShapeLayer* 血背景样式;
CAShapeLayer* 血圈景样式;
CAShapeLayer* Draw_Circle;
CAShapeLayer* Draw_Circle_Disable;
UIBezierPath* Path_Rect;
UIBezierPath* Path_Circle;
UIBezierPath* Path_血背景;
UIBezierPath* Path_血圈;
UIBezierPath* Path_Circle_Disable;
UIImageView* HeroImage[10];
UIImageView* CIKEHeroImage[10];
UIImageView* CIKEJnImage[10];
UILabel* CIKEJnTime[10];
UILabel* CIKEDzTime[10];
//UIImageView* 大地图头像[10];
SkillView* SkillTable[10];
Vector2 GameCanvas;
Vector2 MiniMap;
std::vector<SaveImage> NetImage;
float wwidth,wheight;
static bool GameMV;
static UIWindow* window;
static NSTimer *进程定时器;
static NSTimer *绘制定时器;
float mapx,mapy,半径;
+(void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"gamevm=load");
            IView = [[TestSmoba alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [IView 定时器];
        });
    });
}
-(void)定时器
{
        //获取当前音量
        进程定时器 = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            GameMV=Gameinitialization();
            NSLog(@"gamevm=%d",GameMV);
            mapy=[[NSUserDefaults standardUserDefaults] floatForKey:@"mapy"];
            mapx=[[NSUserDefaults standardUserDefaults] floatForKey:@"mapx"];
            半径=[[NSUserDefaults standardUserDefaults] floatForKey:@"半径"];
            //判断王者进程存在才启动定时器 否则注销定时器 绘制 影响电量
            if (GameMV) {
                window=[shisangeCD 获取顶层视图];
                wwidth = [UIScreen mainScreen].bounds.size.width;
                wheight = [UIScreen mainScreen].bounds.size.height;
                IView.transform=CGAffineTransformMakeRotation(M_PI*0.5);
                IView.frame=CGRectMake(0, 0, wheight, wwidth);
                UITextField* textField = [[UITextField alloc] init];
                textField.secureTextEntry = 是否过直播;
                textField.frame = IView.bounds;
                textField.subviews.firstObject.userInteractionEnabled = YES;
                [textField.subviews.firstObject addSubview:IView];
                textField.userInteractionEnabled = NO;
                [window addSubview:textField];
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [IView Start];
                });
                //判断定时器是否为空
                if (绘制定时器==nil) {
                    绘制定时器 = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
                        [self Drawing];
                    }];
                    [[NSRunLoop currentRunLoop] addTimer:绘制定时器 forMode:NSRunLoopCommonModes];
                }
                
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //释放定时器
                    [绘制定时器 invalidate];
                    绘制定时器=nil;
                });
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:进程定时器 forMode:NSRunLoopCommonModes];
        
        
}
- (void) Start
{
    
    self.backgroundColor = [UIColor clearColor];
    [self setUserInteractionEnabled:NO];
    
    GameCanvas.x = IView.frame.size.width;
    GameCanvas.y = IView.frame.size.height;
    
    Draw_HP = [[CAShapeLayer alloc] init];
    Draw_HP.frame = self.frame;
    Draw_HP.lineWidth = 2.5;
    Draw_HP.strokeColor = UIColor.greenColor.CGColor;
    [self.layer addSublayer:Draw_HP];
    
    Draw_Rect = [[CAShapeLayer alloc] init];
    Draw_Rect.frame = self.frame;
    Draw_Rect.strokeColor = UIColor.greenColor.CGColor;//方框颜色
    Draw_Rect.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:Draw_Rect];//标记
    
    血背景样式 = [[CAShapeLayer alloc] init];
    血背景样式.frame = self.frame;
    血背景样式.lineWidth=3;
    血背景样式.strokeColor = UIColor.greenColor.CGColor;//方框颜色
    血背景样式.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:血背景样式];//标记
    
    
    血圈景样式 = [[CAShapeLayer alloc] init];
    血圈景样式.frame = self.frame;
    血圈景样式.lineWidth=3;
    血圈景样式.strokeColor = UIColor.redColor.CGColor;//方框颜色
    血圈景样式.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:血圈景样式];//标记
    
    
    
    Draw_Circle = [[CAShapeLayer alloc] init];
    Draw_Circle.frame = self.frame;
    Draw_Circle.strokeColor = UIColor.clearColor.CGColor;
    Draw_Circle.fillColor = UIColor.greenColor.CGColor;
    [self.layer addSublayer:Draw_Circle];
    
    Draw_Circle_Disable = [[CAShapeLayer alloc] init];
    Draw_Circle_Disable.frame = self.frame;
    Draw_Circle_Disable.strokeColor = UIColor.clearColor.CGColor;
    Draw_Circle_Disable.fillColor = [UIColor colorWithWhite:0.2f alpha:1.f].CGColor;
    [self.layer addSublayer:Draw_Circle_Disable];
    
    for (int i=0; i<10; i++) {
        HeroImage[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        HeroImage[i].backgroundColor = [UIColor clearColor];
        HeroImage[i].layer.masksToBounds = YES;
        HeroImage[i].layer.cornerRadius = 9;
        HeroImage[i].hidden=YES;
        HeroImage[i].layer.borderColor = [UIColor redColor].CGColor;
        HeroImage[i].layer.borderWidth = 1.f;
        [self addSubview:HeroImage[i]];
        
        
        for (int i=0; i<10; i++) {
            HeroImage[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            HeroImage[i].backgroundColor = [UIColor clearColor];
            HeroImage[i].layer.masksToBounds = YES;
            HeroImage[i].layer.cornerRadius = 9;
            HeroImage[i].hidden=YES;
            HeroImage[i].layer.borderColor = [UIColor redColor].CGColor;
            HeroImage[i].layer.borderWidth = 1.f;
            [self addSubview:HeroImage[i]];
        }
        
        for (int i=0; i<10; i++) {
            CIKEHeroImage[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            CIKEHeroImage[i].backgroundColor = [UIColor clearColor];
            CIKEHeroImage[i].layer.masksToBounds = YES;
            //  CIKEHeroImage[i].layer.cornerRadius = 30;
            CIKEHeroImage[i].hidden=YES;
            CIKEHeroImage[i].layer.borderColor = [UIColor redColor].CGColor;
            CIKEHeroImage[i].layer.borderWidth = 0.f;
            [self addSubview:CIKEHeroImage[i]];
        }
        
        for (int i=0; i<10; i++) {
            CIKEJnImage[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            CIKEJnImage[i].backgroundColor = [UIColor clearColor];
            CIKEJnImage[i].layer.masksToBounds = YES;
            //  CIKEJnImage[i].layer.cornerRadius = 15;
            CIKEJnImage[i].hidden=YES;
            CIKEJnImage[i].layer.borderColor = [UIColor redColor].CGColor;
            CIKEJnImage[i].layer.borderWidth = 0.f;
            [self addSubview:CIKEJnImage[i]];
        }
        
        for (int i=0; i<10; i++) {
            CIKEJnTime[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            CIKEJnTime[i].text = nil;
            CIKEJnTime[i].numberOfLines = 0;
            CIKEJnTime[i].lineBreakMode = NSLineBreakByCharWrapping;
            CIKEJnTime[i].textAlignment = NSTextAlignmentCenter;
            CIKEJnTime[i].font = [UIFont boldSystemFontOfSize:20];
            CIKEJnTime[i].textColor = [UIColor whiteColor];
            [self addSubview:CIKEJnTime[i]];
        }
        
        for (int i=0; i<10; i++) {
            CIKEDzTime[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            CIKEDzTime[i].text = nil;
            CIKEDzTime[i].numberOfLines = 0;
            CIKEDzTime[i].lineBreakMode = NSLineBreakByCharWrapping;
            CIKEDzTime[i].textAlignment = NSTextAlignmentCenter;
            CIKEDzTime[i].font = [UIFont boldSystemFontOfSize:20];
            CIKEDzTime[i].textColor = [UIColor whiteColor];
            [self addSubview:CIKEDzTime[i]];
        }
        
    }
    
    for (int i=0; i<10; i++) {
        SkillTable[i] = [[SkillView alloc] initWithFrame:CGRectMake(0, 0, 80, 16)];
        SkillTable[i].Skill1 = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 16, 16)];
        SkillTable[i].Skill2 = [[UIView alloc] initWithFrame:CGRectMake(22, 0, 16, 16)];
        SkillTable[i].Skill3 = [[UIView alloc] initWithFrame:CGRectMake(42, 0, 16, 16)];
        SkillTable[i].Skill4 = [[UIView alloc] initWithFrame:CGRectMake(62, 0, 16, 16)];
        
        [SkillTable[i] addSubview:SkillTable[i].Skill1];
        [SkillTable[i] addSubview:SkillTable[i].Skill2];
        [SkillTable[i] addSubview:SkillTable[i].Skill3];
        [SkillTable[i] addSubview:SkillTable[i].Skill4];
        
        SkillTable[i].Skill1.backgroundColor = [UIColor greenColor];
        SkillTable[i].Skill1.layer.masksToBounds = YES;
        SkillTable[i].Skill1.layer.cornerRadius = 8;
        SkillTable[i].Skill1.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        SkillTable[i].Skill1.layer.borderWidth = 1.f;
        
        SkillTable[i].Skill2.backgroundColor = [UIColor greenColor];
        SkillTable[i].Skill2.layer.masksToBounds = YES;
        SkillTable[i].Skill2.layer.cornerRadius = 8;
        SkillTable[i].Skill2.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        SkillTable[i].Skill2.layer.borderWidth = 1.f;
        
        SkillTable[i].Skill3.backgroundColor = [UIColor greenColor];
        SkillTable[i].Skill3.layer.masksToBounds = YES;
        SkillTable[i].Skill3.layer.cornerRadius = 8;
        SkillTable[i].Skill3.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        SkillTable[i].Skill3.layer.borderWidth = 1.f;
        
        SkillTable[i].Skill4.backgroundColor = [UIColor greenColor];
        SkillTable[i].Skill4.layer.masksToBounds = YES;
        SkillTable[i].Skill4.layer.cornerRadius = 8;
        SkillTable[i].Skill4.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
        SkillTable[i].Skill4.layer.borderWidth = 1.f;
        
        SkillTable[i].backgroundColor = [UIColor clearColor];
        [SkillTable[i] setHidden:YES];
        [self addSubview:SkillTable[i]];
    }
    
    for (int i=0; i<30; i++) {
        MsMonsterView[i] = [CAShapeLayer layer];
        [self.layer addSublayer:MsMonsterView[i]];
        
        MsMonsterRect[i] = [CAShapeLayer layer];
        [self.layer addSublayer:MsMonsterRect[i]];
        
    }
    
    
    
}
//技能倒计时调节

float 技能绘制x调节 = 410;
float 技能绘制y调节 = 3;
bool 透视开关,血条开关,射线开关,方框开关,技能开关,野怪绘制开关;
static int YXsum = 0;
- (void) Drawing
{
    
    MiniMap.x = mapx;
    MiniMap.y = mapy;
    
    for (int i=0; i<10; i++) {
        [HeroImage[i] setHidden:YES];
        [SkillTable[i] setHidden:YES];
        
        [CIKEHeroImage[i] setHidden:YES];
        [CIKEJnImage[i] setHidden:YES];
        [CIKEJnTime[i] setHidden:YES];
        [CIKEDzTime[i] setHidden:YES];
    }
    
    Path_Rect = [[UIBezierPath alloc] init];
    Path_HP = [[UIBezierPath alloc] init];
    Path_血圈 = [[UIBezierPath alloc] init];
    Path_血背景 = [[UIBezierPath alloc] init];
    Path_HP.lineWidth = 2.5;
    if (GameMV)
    {
        [Path_Rect appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(MiniMap.x, 0, MiniMap.y, MiniMap.y)]];
        if (RefreshMatrix())
        {
            std::vector<SmobaHeroData> HeroData;
            GetPlayers(&HeroData);
            if (HeroData.size() > 0)
            {
                for (int i=0; i<HeroData.size(); i++) {
                    Vector2 BoxPos;
                    if (!HeroData[i].Dead)
                    {
                        
                        
                        if (ToScreen(GameCanvas,HeroData[i].Pos,&BoxPos))
                        {
                            if (透视开关) {
                                //头像
                                Vector2 MiniPos = ToMiniMap(MiniMap, HeroData[i].Pos);
                                float R=MiniMap.y/14;
                                HeroImage[i].image = GetHeroImage(HeroData[i].HeroID);
                                [HeroImage[i] setHidden:NO];
                                [HeroImage[i] setFrame:CGRectMake(MiniPos.x-R, MiniPos.y-R, R*2, R*2)];
                                if(血条开关)
                                {
                                    float 血量 =M_PI*2*HeroData[i].HP;
                                   
                                    UIBezierPath *Line = [UIBezierPath bezierPathWithArcCenter:CGPointMake(MiniPos.x,MiniPos.y) radius:半径 startAngle:(0) endAngle:M_PI*2 clockwise:true];
                                    [Path_血背景 appendPath:Line];
                                    
                                    UIBezierPath *Line3 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(MiniPos.x,MiniPos.y) radius:半径 startAngle:(0) endAngle:血量 clockwise:true];
                                    [Path_血圈 appendPath:Line3];
                                    
                                }
                                
                            }
                        }
                        if (射线开关) {
                            UIBezierPath *bezierPath = [UIBezierPath bezierPath];
                            [bezierPath moveToPoint:CGPointMake(kuandu/2, gaodu/2)];
                            [bezierPath addLineToPoint:CGPointMake(BoxPos.x, BoxPos.y-20)];
                            
                            [Path_Rect appendPath:bezierPath];
                        }
                        if (方框开关)
                        {
                            [Path_Rect appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(BoxPos.x-20, BoxPos.y-48, 40, 40)]];
                        }
                        if (技能开关)
                        {
                            SkillTable[i].center = CGPointMake(BoxPos.x, BoxPos.y+10);
                            [SkillTable[i] setHidden:NO];
                            SkillTable[i].Skill1.backgroundColor = HeroData[i].Skill1?[UIColor greenColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            SkillTable[i].Skill2.backgroundColor = HeroData[i].Skill2?[UIColor greenColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            SkillTable[i].Skill3.backgroundColor = HeroData[i].Skill3?[UIColor greenColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            SkillTable[i].Skill4.backgroundColor = HeroData[i].Skill4?[UIColor redColor]:[UIColor colorWithWhite:0.4f alpha:1.f];
                            
                            }
                        
                        
                        
                        //==================大地图野怪====================
                        Vector2 MonsterScreen;
                        if (野怪绘制开关) {
                            for (int i= 0; i < MonsterData.size(); i++) {
                                if (MonsterData[i].MonsterHP >= 0) {
                                    if (ToScreen(GameCanvas,MonsterData[i].MonsterPos,&MonsterScreen)){
                                        Vector2 MiniMonsterPos = ToMiniMap(MiniMap, MonsterData[i].MonsterPos);
                                        
                                        UIBezierPath *MonsterPath = [UIBezierPath bezierPath];
                                        [MonsterPath addArcWithCenter:CGPointMake(MiniMonsterPos.x,MiniMonsterPos.y) radius:2 startAngle:M_PI_2 + M_PI *MonsterData[i].MonsterHP/MonsterData[i].MonsterMaxHP endAngle:M_PI_2 - M_PI *MonsterData[i].MonsterHP/MonsterData[i].MonsterMaxHP clockwise:NO];
                                        MsMonsterView[i].fillColor = [UIColor whiteColor].CGColor;
                                        MsMonsterView[i].strokeColor = [UIColor blackColor].CGColor;
                                        MsMonsterView[i].lineWidth = 1;
                                        MsMonsterView[i].path = MonsterPath.CGPath;
                                    }
                                }
                            }
                        }
                        
                    }
                    if (透视开关 && 技能开关) {
                        CIKEHeroImage[i].image = GetHeroImage(HeroData[i].HeroID);
                        [CIKEHeroImage[i] setFrame:CGRectMake(MiniMap.x + 技能绘制x调节 + 43*YXsum, 技能绘制y调节, 40, 40)];
                        //绘制人物头像
                        
                        CIKEJnImage[i].image = GetHeroImage(HeroData[i].HeroTalent);
                        [CIKEJnImage[i] setFrame:CGRectMake(MiniMap.x + 技能绘制x调节 + 43*YXsum, 技能绘制y调节 + 50, 40, 40)];
                        //绘制召唤师技能
                        
                        if(HeroData[i].HeroTalentTime == 0){
                            CIKEJnImage[i].layer.borderColor = [UIColor redColor].CGColor;
                            CIKEJnTime[i].text = nil;
                        }
                        else{
                            CIKEJnImage[i].layer.borderColor = [UIColor clearColor].CGColor;
                            NSString *stringValue = [NSString stringWithFormat:@"%d", (HeroData[i].HeroTalentTime)];
                            CIKEJnTime[i].text = stringValue;
                        }
                        //                        读取召唤师技能时间
                        
                        if(HeroData[i].HeroSkillTime == 0){
                            CIKEDzTime[i].text = nil;
                        }
                        else{
                            NSString *stringValue = [NSString stringWithFormat:@"%d", (HeroData[i].HeroSkillTime)];
                            CIKEDzTime[i].text = stringValue;
                        }
                        //                        读取大招技能时间
                        
                        [CIKEJnTime[i] setFrame:CGRectMake(MiniMap.x + 技能绘制x调节 + 43*YXsum, 技能绘制y调节 + 50, 40, 40)];
                        //                        绘制技能时间
                        [CIKEDzTime[i] setFrame:CGRectMake(MiniMap.x + 技能绘制x调节 + 43*YXsum, 技能绘制y调节 , 40, 40)];
                        //                        绘制大招时间
                        
                        [CIKEHeroImage[i] setHidden:NO];
                        [CIKEJnTime[i] setHidden:NO];
                        [CIKEDzTime[i] setHidden:NO];
                        [CIKEJnImage[i] setHidden:NO];
                        //                        显示全部控件
                        
                        if(YXsum == 4){
                            //     NSLog(@"=========信息绘制完成");
                            YXsum = 0;
                        }
                        else{
                            YXsum++;
                        }
                    }
                }
            }
        }else{
            NSLog(@"RefreshMatrix=%d",RefreshMatrix());
        }
    }
    Draw_Rect.path = Path_Rect.CGPath;
    Draw_HP.path = Path_HP.CGPath;
    血背景样式.path = Path_血背景.CGPath;
    血圈景样式.path = Path_血圈.CGPath;
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
