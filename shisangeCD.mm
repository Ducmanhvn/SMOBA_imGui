
//  WX:NongShiFu123
//  QQ:350722326
//  Created by  十三哥 on 2023/2/21.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AdSupport/AdSupport.h>
#import <AVKit/AVKit.h>
#import "shisangeCD.h"
#import "Config.h"



@interface shisangeCD ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITextField *textField;
@end
static UIWindow *顶层视图;

static UIView*旋转视图;
static UIView *菜单视图;
static UIView *图标视图;
static UITableView *表格视图;
static NSTimer *顶层视图定时器;
static float 初始音量;
static NSString* UI类型[1000];

static BOOL 展开[100];

static int 分组数量;
static int 分组排序=0;
static int 功能数量[100];
static NSString*分组标题[100];
static NSString*分组副标题[100];
bool 是否过直播;
BOOL 是否深色模式;
float gwidth;
float gheight;
@implementation shisangeCD
- (instancetype)init {
    self = [super init];
    if (self) {
        _textField= [[UITextField alloc] init];
        [_textField setSecureTextEntry:是否过直播];
        
        self = _textField.subviews.firstObject;
        [self setUserInteractionEnabled:true];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textField= [[UITextField alloc] init];
        [_textField setSecureTextEntry:是否过直播];
        self = _textField.subviews.firstObject;
        self.frame=frame;
        [self setUserInteractionEnabled:true];
    }
    return self;
}
+ (void)load{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            是否过直播=YES;
            [shisangeCD 悬浮图标];
            是否深色模式=[self 判断颜色模式];
        
        });
        
    });
}

+ (UIWindow *)获取顶层视图{
    顶层视图=[UIApplication sharedApplication].keyWindow;
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


+ (void)悬浮图标{
    顶层视图=[self 获取顶层视图];
    if (旋转视图==nil) {
        旋转视图=[[UIView alloc] init];
    }
    
    旋转视图.frame=顶层视图.bounds;
    [顶层视图 addSubview:旋转视图];
    图标视图 = [[shisangeCD alloc] initWithFrame:CGRectMake(图标起点X,图标起点Y, 图标大小, 图标大小)];
    图标视图.backgroundColor=[UIColor colorWithRed:239 / 255.0 green:238 / 255.0 blue:245 / 255.0 alpha:1];
    图标视图.layer.borderColor = [[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f] CGColor];
    图标视图.layer.borderWidth = 1.0f;
    图标视图.clipsToBounds = YES;
    图标视图.layer.cornerRadius = 图标大小/2;
    图标视图.alpha = 0;
    图标视图.userInteractionEnabled=YES;
    [旋转视图 addSubview:图标视图];
    
    //图标拖动事件
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(拖动事件:)];
    [图标视图 addGestureRecognizer:pan];
    
    //图标点击监听
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
    tap2.numberOfTapsRequired = 1;//点击次数
    tap2.numberOfTouchesRequired = 1;//手指数
    [tap2 addTarget:self action:@selector(菜单)];
    [图标视图 addGestureRecognizer:tap2];
    
    //图标背景图
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:图标地址]];
        UIImage *decodedImage = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView*imgview=[[UIImageView alloc]init];
            imgview.frame=图标视图.bounds;
            imgview.image=decodedImage;
            imgview.clipsToBounds = YES;
            imgview.layer.cornerRadius = 图标大小/2;
            [图标视图 addSubview:imgview];
            
        });
    });
    
    //重复获取顶层视图
    if (顶层视图定时器==nil) {
        
        顶层视图定时器 = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer*t){
            gwidth = [UIScreen mainScreen].bounds.size.width;
            gheight = [UIScreen mainScreen].bounds.size.height;
            if (gwidth>gheight) {
                旋转视图.transform=CGAffineTransformMakeRotation(M_PI*0.5);
                旋转视图.frame=CGRectMake(0, 0, gheight, gwidth);
                
            }else{
                旋转视图.transform=CGAffineTransformIdentity;
                旋转视图.frame=顶层视图.bounds;
            }
            if (是否深色模式!=[self 判断颜色模式]) {
                是否深色模式=[self 判断颜色模式];
                CGRect rect=菜单视图.frame;
                CGRect rect2=图标视图.frame;
                //刷新UI
                [菜单视图 removeFromSuperview];
                菜单视图=nil;
                [图标视图 removeFromSuperview];
                图标视图=nil;
                [self 悬浮图标];
                [self 菜单];
                菜单视图.frame=rect;
                图标视图.frame=rect2;
                [表格视图 reloadData];
                
            }
            顶层视图 = [shisangeCD 获取顶层视图];
            if(图标视图.superview != 旋转视图) {
                [旋转视图 addSubview:图标视图];
                [顶层视图 addSubview:旋转视图];
            }
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setActive:YES error:nil];
            float 最新音量 = [audioSession outputVolume];
            if (初始音量!=最新音量) {
                初始音量=最新音量;
                [self 隐藏显示];
            }
        }];
    }
    
    
}
+ (void)菜单{
    
    if (菜单视图==nil) {
        菜单视图 = [[shisangeCD alloc] init];
        菜单视图.alpha=0;
        菜单视图.frame=CGRectMake(图标视图.frame.origin.x-图标大小/4, 图标视图.frame.origin.y+图标大小/2, 菜单宽度, 菜单高度);
        if (是否深色模式) {
            菜单视图.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            菜单视图.layer.borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] CGColor];
        }else{
            菜单视图.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
            菜单视图.layer.borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7] CGColor];
        }
        
        菜单视图.layer.borderWidth = 1.0f;
        菜单视图.clipsToBounds = YES;
        菜单视图.layer.cornerRadius = 统一圆角;
        [旋转视图 addSubview:菜单视图];
        //设置毛玻璃
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualView.clipsToBounds = YES;
        visualView.frame = 菜单视图.bounds;
        visualView.layer.cornerRadius = 统一圆角;
        for (UIView *subview in visualView.subviews) {
            subview.layer.cornerRadius = 统一圆角;
        }
        
        [菜单视图 addSubview:visualView];
    }
    if (表格视图==nil) {
        表格视图 = [[UITableView alloc]initWithFrame:CGRectMake(0,40,菜单视图.frame.size.width,菜单视图.frame.size.height-40) style:UITableViewStyleGrouped];
    }
    //表格视图
    表格视图.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    表格视图.clipsToBounds = YES;
    表格视图.layer.cornerRadius = 统一圆角;
    表格视图.bounces = YES;
    表格视图.dataSource = (id<UITableViewDataSource>) self;
    表格视图.delegate = (id<UITableViewDelegate>) self;
    
    表格视图.showsVerticalScrollIndicator = NO;
    表格视图.separatorStyle = UITableViewCellSeparatorStyleNone;
    表格视图.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    [菜单视图 addSubview:表格视图];
    
    UIView *顶部背景 = [[UIView alloc] initWithFrame:CGRectMake(0,0, 菜单宽度, 40)];
    if (是否深色模式) {
        顶部背景.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }else{
        顶部背景.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }
    
    [菜单视图 addSubview:顶部背景];
    
    //圆角设置
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:顶部背景.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = 顶部背景.bounds;
    maskLayer.path = maskPath.CGPath;
    顶部背景.layer.mask = maskLayer;
    
    
    //顶部拖动事件
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(拖动事件:)];
    [顶部背景 addGestureRecognizer:pan];
    
    
    //顶部LOGO
    UILabel *BT = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 顶部背景.frame.size.width, 20)];
    BT.numberOfLines = 0;
    
    BT.lineBreakMode = NSLineBreakByCharWrapping;
    BT.text = @"  风车菜单 WX:NongShiFu123";
    BT.textAlignment = NSTextAlignmentCenter;
    BT.font = [UIFont boldSystemFontOfSize:15];
    if (是否深色模式) {
        BT.textColor = [UIColor whiteColor];
    }else{
        BT.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    
    [顶部背景 addSubview:BT];
        
    
    
    [UIView animateWithDuration:0.5 animations:^{
        菜单视图.alpha=!菜单视图.alpha;
        [shisangeCD 转圈圈];
    }];
    if(菜单视图.alpha==1){
        
        [菜单视图 addSubview:图标视图];
        [UIView animateWithDuration:0.5 animations:^{
            图标视图.alpha=0.7;
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            图标视图.alpha=1;
        }];
    }
    
}
+ (BOOL)判断颜色模式{
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle mode = UITraitCollection.currentTraitCollection.userInterfaceStyle;
        if (mode == UIUserInterfaceStyleDark) {
            NSLog(@"深色模式");
            return YES;
        }
    }
    return NO;
}
+ (void)拖动事件:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:图标视图];
    if(recognizer.state == UIGestureRecognizerStateBegan){
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        图标视图.center = CGPointMake(图标视图.center.x + translation.x, 图标视图.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:图标视图];
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        CGFloat newX2=图标视图.center.x;
        CGFloat newY2=图标视图.center.y;
        图标视图.center = CGPointMake(newX2, newY2);
        [recognizer setTranslation:CGPointZero inView:图标视图];
    }
    //黏边效果
    
    [UIView animateWithDuration:0.5 animations:^{
        //超出屏幕左边
        if (图标视图.frame.origin.x<0) {
            图标视图.frame=CGRectMake(0, 图标视图.frame.origin.y, 图标视图.frame.size.width, 图标视图.frame.size.height);
        }
        //超出屏幕上面
        if (图标视图.frame.origin.y<0) {
            图标视图.frame=CGRectMake(图标视图.frame.origin.x, 0, 图标视图.frame.size.width, 图标视图.frame.size.height);
        }
        //超出屏幕底部
        if (图标视图.frame.origin.y+图标大小>gheight) {
            图标视图.frame=CGRectMake(图标视图.frame.origin.x, kHeight-图标大小, 图标视图.frame.size.width, 图标视图.frame.size.height);
        }
        //超出屏幕右边
        if (图标视图.frame.origin.x+图标大小>gwidth) {
            图标视图.frame=CGRectMake(kWidth-图标大小, 图标视图.frame.origin.y, 图标视图.frame.size.width, 图标视图.frame.size.height);
        }
        [shisangeCD 转圈圈];
    }];
    菜单视图.frame=CGRectMake(图标视图.frame.origin.x-图标大小/4, 图标视图.frame.origin.y+图标大小/2, 菜单宽度, 菜单高度);
}
+(void)转圈圈
{
    图标视图.transform = CGAffineTransformMakeRotation(M_PI);
    [UIView animateWithDuration:0.5 animations:^{
        图标视图.transform = CGAffineTransformMakeRotation(M_PI*2);
        if (菜单视图.alpha==1) {
            图标视图.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }else{
            图标视图.transform = CGAffineTransformMakeScale(1, 1);
        }
    }];
    
    
    
}
+ (void)隐藏显示{
    [UIView animateWithDuration:0.5 animations:^{
        [shisangeCD 转圈圈];
        图标视图.alpha=!图标视图.alpha;
        
        }];
}
+ (void)过直播调用:(BOOL)开关
{
    CGRect rect=菜单视图.frame;
    CGRect rect2=图标视图.frame;
    //刷新UI
    [菜单视图 removeFromSuperview];
    菜单视图=nil;
    [图标视图 removeFromSuperview];
    图标视图=nil;
    [self 悬浮图标];
    [self 菜单];
    菜单视图.frame=rect;
    图标视图.frame=rect2;
    [表格视图 reloadData];
    
}




#pragma mark - 各种UI添加操作
#pragma mark - 添加分组
static UISwitch* switchView[1000];
static NSString*开关标题[1000];
static BOOL 开关状态[1000];
static int 排序;
+ (void)添加分组:(NSString *)标题 分组说明:(NSString *)分组说明 是否展开:(BOOL)是否展开 功能数:(int)功能数 子功能:(子功能)子功能
{
    展开[分组数量]=是否展开;
    分组数量++;
    分组排序++;
    功能数量[分组排序-1]=功能数+1;
    分组标题[分组排序-1]=标题;
    分组副标题[分组排序-1]=分组说明;
    子功能();
    排序=0;
    
}
#pragma mark - 添加开关
static int 操作ID;
static 执行函数 开启代码[1000],关闭代码[1000];
+ (void)添加开关:(NSString *)标题 开启:(执行函数)开启 关闭:(执行函数)关闭
{
    操作ID=分组排序*100+排序++;
    开关标题[操作ID]=标题;
    switchView[操作ID] = [[UISwitch alloc] init];
    switchView[操作ID].on=开关状态[操作ID];
    switchView[操作ID].tag=操作ID;
    [switchView[操作ID] addTarget:self action:@selector(开关调用:) forControlEvents:UIControlEventValueChanged];
    UI类型[操作ID]=@"开关";
    开启代码[操作ID]=开启;
    关闭代码[操作ID]=关闭;
    NSLog(@"分组排序=%d 操作ID=%d",分组排序,操作ID);
    
}
+(void)开关调用:(UISwitch*)Switch
{
    int tag=(int)Switch.tag;
    开关状态[tag]=!开关状态[tag];
    if (开关状态[tag]) {
        开启代码[tag]();
    }else{
        关闭代码[tag]();
    }
}
#pragma mark - 添加按钮
static UIButton* button[1000];
static NSString*按钮标题[1000];
static 执行函数 按钮执行[1000];
+ (void)添加按钮:(NSString *)标题 点击操作:(执行函数)点击操作 尺寸:(CGRect)Rect
{
    操作ID=分组排序*100+排序++;
    
    按钮标题[操作ID]=标题;
    UI类型[操作ID]=@"按钮";
    按钮执行[操作ID]=点击操作;
    button[操作ID] = [[UIButton alloc]init];
    button[操作ID].layer.cornerRadius = 10.0;
    [button[操作ID] setTitle:@"粘贴" forState:UIControlStateNormal];
    [button[操作ID] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//p1颜色
    button[操作ID].backgroundColor = [UIColor colorWithRed:34/255.0 green:181/255.0 blue:115/250.0 alpha:1];
    button[操作ID].frame = Rect;
    button[操作ID].layer.borderColor = [[UIColor whiteColor] CGColor];//边框颜色
    button[操作ID].layer.borderWidth = 1.0f;//边框大小
    button[操作ID].tag=操作ID;
    [button[操作ID].titleLabel setFont:[UIFont systemFontOfSize:15]];//字体大小
    [button[操作ID] addTarget:self action:@selector(按钮调用:) forControlEvents:UIControlEventTouchUpInside];
    
}
+(void)按钮调用:(UIButton*)Button
{
    int tag=(int)Button.tag;
    按钮执行[tag]();
    
}
static 自定义视图 视图[1000];
static UIView* 父级视图[1000];
+ (UIView *)添加自定义视图:(UIView *)视图
{
    操作ID=分组排序*100+排序++;
    父级视图[操作ID]=视图;
    UI类型[操作ID]=@"视图";
    return 父级视图[操作ID];
}


#pragma mark - TbaleView的数据源代理方法实现
+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if (是否深色模式) {
        cell.textLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];;
    }else{
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];;
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    for (int i=0; i<分组数量; i++) {
        if (indexPath.section==i) {
            //设置每个分组的标题
            if (indexPath.row==0) {
                cell.textLabel.text = 分组标题[i];
                if(!展开[i]){
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.tintColor=[UIColor systemRedColor];
                }
            }else{
                //设置每个分组的子功能标题
                int cj=(((int)indexPath.section+1)*100)+(int)indexPath.row-1;
                NSLog(@"cj=%d section=%d",cj,(int)indexPath.section);
                if ([UI类型[cj] isEqual:@"开关"]) {
                    cell.textLabel.text = 开关标题[cj];
                    cell.accessoryView=switchView[cj];
                }
                if ([UI类型[cj] isEqual:@"按钮"]) {
                    cell.textLabel.text = 按钮标题[cj];
                    cell.accessoryView=button[cj];
                }
                if ([UI类型[cj] isEqual:@"视图"]) {
                    cell.textLabel.text = 按钮标题[cj];
                    [cell addSubview:父级视图[cj]];
                    
                }
                
            }
        }
        
        
    }
    
    
    
    
    return cell;
}
#pragma mark - 点击后操作

+ (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0) {
        展开[indexPath.section]=!展开[indexPath.section];
    }
    [表格视图 reloadData];
}
//分组数量
+ (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (分组数量==0) {
        return 1;
    }
    return 分组数量;
}

#pragma mark - 第二个控制器行树
//默认多少表格
+ (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (分组数量!=0) {
        for (int i=0; i<分组数量; i++) {
            if(section==i) //展开的
            {
                if (展开[section]) {
                    return 功能数量[i];
                }
                return 1;
            }
        }
    }else{
        return 排序;
    }
    
    
    return 0;
}

//默认顶部高度
+ (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 25;
    }
    return 10;
}

//默认表格每格高度
+ (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

//默认顶部文字
+ (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerLabel;
    for (int i=0; i<分组数量; i++) {
        if (section==i) {
            headerLabel = [NSString stringWithFormat:@"%@",分组副标题[i]];
        }
    }

    if (分组数量==0) {

        headerLabel=@"分组错误 请先添加分组 后添加功能";
    }
    return headerLabel;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

#pragma mark - 表格样式

+ (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 设置cell的背景色为透明，如果不设置这个的话，则原来的背景色不会被覆盖
    cell.backgroundColor = UIColor.clearColor;
    
    // 圆角弧度半径
    CGFloat cornerRadius = 10.0f;
    
    // 创建一个shapeLayer
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    // 显示选中
    CAShapeLayer *backgroundLayer = [[CAShapeLayer alloc] init];
    //   创建一个可变的图像Path句柄，该路径用于保存绘图信息
    CGMutablePathRef pathRef = CGPathCreateMutable();
    //   获取cell的size
    //    第一个参数,是整个 cell 的 bounds, 第二个参数是距左右两端的距离,第三个参数是距上下两端的距离
    CGRect bounds = CGRectInset(cell.bounds, 0, 0);
    
    //      CGRectGetMinY：返回对象顶点坐标
    //      CGRectGetMaxY：返回对象底点坐标
    //      CGRectGetMinX：返回对象左边缘坐标
    //      CGRectGetMaxX：返回对象右边缘坐标
    //      CGRectGetMidX: 返回对象中心点的X坐标
    //      CGRectGetMidY: 返回对象中心点的Y坐标
    //      这里要判断分组列表中的第一行，每组section的第一行，每组section的中间行
    NSInteger rows = [tableView numberOfRowsInSection:indexPath.section];
    BOOL addLine = NO;
    if (rows == 1) {
        // 初始起点为cell的左侧中间坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMidY(bounds));
        // 起始坐标为左下角，设为p，（CGRectGetMinX(bounds), CGRectGetMinY(bounds)）为左上角的点，设为p1(x1,y1)，(CGRectGetMidX(bounds), CGRectGetMinY(bounds))为顶部中点的点，设为p2(x2,y2)。然后连接p1和p2为一条直线l1，连接初始点p到p1成一条直线l，则在两条直线相交处绘制弧度为r的圆角。
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMinX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMinX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 终点坐标为右下角坐标点，把绘图信息都放到路径中去,根据这些路径就构成了一块区域了
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    } else if (indexPath.row == 0) {
        // 初始起点为cell的左下角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        // 起始坐标为左下角，设为p，（CGRectGetMinX(bounds), CGRectGetMinY(bounds)）为左上角的点，设为p1(x1,y1)，(CGRectGetMidX(bounds), CGRectGetMinY(bounds))为顶部中点的点，设为p2(x2,y2)。然后连接p1和p2为一条直线l1，连接初始点p到p1成一条直线l，则在两条直线相交处绘制弧度为r的圆角。
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 终点坐标为右下角坐标点，把绘图信息都放到路径中去,根据这些路径就构成了一块区域了
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        addLine = YES;
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        // 初始起点为cell的左上角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 添加一条直线，终点坐标为右下角坐标点并放到路径中去
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        // 添加cell的rectangle信息到path中（不包括圆角）
        CGPathAddRect(pathRef, nil, bounds);
        addLine = YES;
    }
    
    // 把已经绘制好的可变图像路径赋值给图层，然后图层根据这图像path进行图像渲染render
    layer.path = pathRef;
    backgroundLayer.path = pathRef;
    
    // 注意：但凡通过Quartz2D中带有creat/copy/retain方法创建出来的值都必须要释放
    CFRelease(pathRef);
    
    // 按照shape layer的path填充颜色，类似于渲染render
    if (是否深色模式) {
        layer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    }else{
        layer.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor;
    }
    
    
    // view大小与cell一致
    UIView *roundView = [[UIView alloc] initWithFrame:bounds];
    
    // 添加自定义圆角后的图层到roundView中
    [roundView.layer insertSublayer:layer atIndex:0];
    roundView.backgroundColor = UIColor.clearColor;
    
    // cell的背景view
    cell.backgroundView = roundView;
    
    // 添加分割线
    if (addLine == YES) {
        
        CALayer *lineLayer = [[CALayer alloc] init];
        
        CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
        
        lineLayer.frame = CGRectMake(0, bounds.size.height-lineHeight, bounds.size.width, lineHeight);
        
        if (是否深色模式) {
            lineLayer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
        }else{
            lineLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        }
       
        
        [layer addSublayer:lineLayer];
        
    }
    
    // 以上方法存在缺陷当点击cell时还是出现cell方形效果，因此还需要添加以下方法
    // 如果你 cell 已经取消选中状态的话,那以下方法是不需要的.
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:bounds];
    backgroundLayer.fillColor = tableView.separatorColor.CGColor;
    [selectedBackgroundView.layer insertSublayer:backgroundLayer atIndex:0];
    selectedBackgroundView.backgroundColor = UIColor.clearColor;
    cell.selectedBackgroundView = selectedBackgroundView;
    
    
    
}

@end
