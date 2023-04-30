
#import "ImGuiDrawView.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>

#import <shisangeIMGUI/imgui_impl_metal.h>
#import <shisangeIMGUI/imgui.h>
#import <Foundation/Foundation.h>
#import "Class.h"
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface ImGuiDrawView () <MTKViewDelegate>

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;

@end
UIImageView* 小地图英雄头像视图[10];
UIImageView* 技能表英雄头像视图[10];
UIImageView* 大招图标视图[10];
UIImageView* 方框技能图标视图[10];

@implementation ImGuiDrawView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
    
    
}


- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    NSLog(@"initWithNibName");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    
    if (!self.device) abort();
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    
    ImGui::StyleColorsDark();
    
    NSString *FontPath = @"/System/Library/Fonts/LanguageSupport/PingFang.ttc";
    io.Fonts->AddFontFromFileTTF(FontPath.UTF8String, 40.f,NULL,io.Fonts->GetGlyphRangesChineseFull());
    
    ImGui_ImplMetal_Init(_device);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapx=[[NSUserDefaults standardUserDefaults] floatForKey:@"mapx"];
        mapy=[[NSUserDefaults standardUserDefaults] floatForKey:@"mapy"];
        技能绘制x调节=[[NSUserDefaults standardUserDefaults] floatForKey:@"技能绘制x调节"];
        技能绘制y调节=[[NSUserDefaults standardUserDefaults] floatForKey:@"技能绘制y调节"];
        半径=[[NSUserDefaults standardUserDefaults] floatForKey:@"半径"];
        GameCanvas.x = kWidth;
        GameCanvas.y = kHeight;
        
        //小地图英雄头像视图
        for (int i=0; i<10; i++) {
            小地图英雄头像视图[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            小地图英雄头像视图[i].backgroundColor = [UIColor clearColor];
            小地图英雄头像视图[i].layer.masksToBounds = YES;
            小地图英雄头像视图[i].hidden=YES;
            小地图英雄头像视图[i].layer.borderColor = [UIColor redColor].CGColor;
            小地图英雄头像视图[i].layer.borderWidth = 0.5;
            [self.view addSubview:小地图英雄头像视图[i]];
        }
        //技能表英雄头像视图
        for (int i=0; i<10; i++) {
            技能表英雄头像视图[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            技能表英雄头像视图[i].backgroundColor = [UIColor clearColor];
            技能表英雄头像视图[i].layer.masksToBounds = YES;
            技能表英雄头像视图[i].hidden=YES;
            技能表英雄头像视图[i].layer.borderColor = [UIColor redColor].CGColor;
            技能表英雄头像视图[i].layer.borderWidth = 0.f;
            [self.view addSubview:技能表英雄头像视图[i]];
        }
        //大招图标视图
        for (int i=0; i<10; i++) {
            大招图标视图[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            大招图标视图[i].backgroundColor = [UIColor clearColor];
            大招图标视图[i].layer.masksToBounds = YES;
            大招图标视图[i].hidden=YES;
            大招图标视图[i].layer.borderColor = [UIColor redColor].CGColor;
            大招图标视图[i].layer.borderWidth = 0.f;
            [self.view addSubview:大招图标视图[i]];
        }
    });
    
    return self;
}



- (MTKView *)mtkView
{
    
    return (MTKView *)self.view;
}

- (void)loadView
{
    
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}


#pragma mark - MTKViewDelegate

//声明默认开关和 状态
static ImVec4 血条颜色 = ImVec4(1.0f, 1.0f, 0.0f, 1.0f);
static ImVec4 方框颜色 = ImVec4(0.0f, 1.0f, 0.0f, 1.0f);
static ImVec4 射线颜色 = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
static ImVec4 野怪颜色 = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

static bool 菜单显示状态;
static bool 透视开关,技能开关,野怪绘制开关,血条开关,方框开关,射线开关,兵线,野怪倒计时开关,过直播开关;
static float mapx,mapy,技能绘制x调节,技能绘制y调节,半径;
static Vector2 GameCanvas;
+(void)showHiede:(BOOL)MenDeal{
    菜单显示状态=MenDeal;
}
- (void)drawInMTKView:(MTKView*)view
{
    
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    
    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    if (菜单显示状态) {
        //菜单显示时 交互为YES可点击
        [self.view setUserInteractionEnabled:YES];
    } else{
        //菜单显示时 交互为NO 不可可点击
        [self.view setUserInteractionEnabled:NO];
        //跨进程旋转屏幕
    }
    
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui shisange"];
        
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        ImFont* font = ImGui::GetFont();
        font->Scale = 20.f / font->FontSize;//字体 大小 分辨率
        //默认窗口大小
        CGFloat width =350;//宽度
        CGFloat height =300;//高度
        ImGui::SetNextWindowSize(ImVec2(width, height), ImGuiCond_FirstUseEver);//大小
        
        //默认显示位置 屏幕中央
        CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - width) / 2;
        CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - height) / 2;
        
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);//默认位置
        
        //开始菜单=====================
        if (菜单显示状态) {
            
            ImGui::Begin("十三哥WX:NongShiFu123",&菜单显示状态);
            
            //选项卡例子=============
            ImGui::BeginTabBar("绘制功能"); // 开始一个选项卡栏
            
            if (ImGui::BeginTabItem("绘制功能")) // 开始第一个选项卡
            {
                // 在这里添加第一个选项卡的内容
                
                ImGui::Checkbox("透视", &透视开关);
                ImGui::SameLine();
                ImGui::Checkbox("技能", &技能开关);
                ImGui::SameLine();
                ImGui::Checkbox("野怪", &野怪绘制开关);
                ImGui::SameLine();
                ImGui::Checkbox("野怪倒计时", &野怪倒计时开关);
                
                ImGui::Checkbox("血条", &血条开关);
                ImGui::ColorEdit3("血条颜色", (float*)&血条颜色);
                
                
                ImGui::Checkbox("方框", &方框开关);
                ImGui::ColorEdit3("方框颜色", (float*) &方框颜色);
                
                
                ImGui::Checkbox("射线", &射线开关);
                ImGui::ColorEdit3("射线颜色", (float*) &射线颜色);
                
                ImGui::EndTabItem(); // 结束第一个选项卡
            }
            
            if (ImGui::BeginTabItem("高级功能")) // 开始第二个选项卡
            {
                // 在这里添加第二个选项卡的内容
                ImGui::Checkbox("过直播开关", &过直播开关);
                ImGui::NewLine();
                
                if (ImGui::SliderFloat("小地图血圈半径", &半径, 0, 80)) {
                    [[NSUserDefaults standardUserDefaults] setFloat:半径 forKey:@"半径"];
                }
                
                if (ImGui::SliderFloat("小地图横轴", &mapx, 0, 500)) {
                    [[NSUserDefaults standardUserDefaults] setFloat:mapx forKey:@"mapx"];
                }
                if (ImGui::SliderFloat("小地图大小", &mapy, 0, 500)) {
                    [[NSUserDefaults standardUserDefaults] setFloat:mapy forKey:@"mapy"];
                }
                
               
                
                if(ImGui::SliderFloat("技能图标横轴", &技能绘制x调节, 0, 500)){
                    [[NSUserDefaults standardUserDefaults] setFloat:技能绘制x调节 forKey:@"技能绘制x调节"];
                }
                
                if(ImGui::SliderFloat("技能图标大小", &技能绘制y调节, 0, 100)){
                    [[NSUserDefaults standardUserDefaults] setFloat:技能绘制y调节 forKey:@"技能绘制y调节"];
                }
                
                ImGui::EndTabItem();
            }
            
            if (ImGui::BeginTabItem("其他功能")) // 开始第二个选项卡
            {
                ImGui::Text("人生如戏-全靠演技\n到期时间:2099-01-01 22:55:77\n\n\n");
                ImGui::EndTabItem();
            }
            
            
            ImGui::EndTabBar(); // 结束选项卡栏
            
            
            
            ImGui::Text("QQ:350722326 %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
            
            
            
            ImGui::End();
            //结束菜单=========================
            
        }
        
        //开始绘制==========================
        ImDrawList*MsDrawList = ImGui::GetForegroundDrawList();//读取整个菜单元素
        [self Drawing:MsDrawList];
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
        
    }
    [commandBuffer commit];
}
//绘制扇形
static void DrawSector(ImDrawList* drawList, const ImVec2& center, float radius, float fromAngle, float toAngle, ImU32 color, int num_segments)
{
    const float PI = 3.14159265358979323846f;

    // 计算角度
    fromAngle = fromAngle * PI / 180.0f;
    toAngle = toAngle * PI / 180.0f;

    // 计算每段的增量角
    float deltaAngle = (toAngle - fromAngle) / (float)num_segments;

    // 添加中心顶点
    drawList->PathLineTo(center);

    // 添加弧顶点
    for (int i = 0; i <= num_segments; ++i)
    {
        float angle = fromAngle + deltaAngle * (float)i;
        ImVec2 pos(center.x + radius * cosf(angle), center.y + radius * sinf(angle));
        drawList->PathLineTo(pos);
    }

    //关闭路径
    drawList->PathFillConvex(color);
}

static int YXsum = 0;
std::vector<SaveImage> NetImage;
- (void) Drawing:(ImDrawList*)MsDrawList
{
   
    if (透视开关)
    {
        Gameinitialization();
        
        if (方框开关) {
            MsDrawList->AddRect(ImVec2(mapx,0), ImVec2(mapx+mapy,mapy), ImColor(方框颜色));
            
            
        }
        
        if (RefreshMatrix())
        {
            std::vector<SmobaHeroData> 读取英雄数据;
            GetPlayers(&读取英雄数据);
            if (读取英雄数据.size() > 0)
            {
                YXsum = 0;
                for (int i=0; i<读取英雄数据.size(); i++) {
                    [小地图英雄头像视图[i] setHidden:YES];
                    [技能表英雄头像视图[i] setHidden:YES];
                    [大招图标视图[i] setHidden:YES];
                    
                    Vector2 BoxPos;
                    if (!读取英雄数据[i].Dead)
                    {
                        if (ToScreen(GameCanvas,读取英雄数据[i].Pos,&BoxPos))
                        {
                            //小地图头像
                            Vector2 小地图;
                            小地图.x=mapx;
                            小地图.y=mapy;
                            //小地图头像
                            Vector2 MiniPos = ToMiniMap(小地图, 读取英雄数据[i].Pos);
                            float R=小地图.y/14;
                            小地图英雄头像视图[i].image = GetHeroImage(读取英雄数据[i].英雄ID);
                            小地图英雄头像视图[i].layer.cornerRadius = R;
                            if (小地图英雄头像视图[i].image==nil ||小地图英雄头像视图[i].image==NULL) {
                                continue;
                            }
                            [小地图英雄头像视图[i] setHidden:NO];
                            [小地图英雄头像视图[i] setFrame:CGRectMake(MiniPos.x-R, MiniPos.y-R, R*2, R*2)];
                        
                            
                            if(血条开关)
                            {
                                //小地血圈圈条
                                float 血量 =读取英雄数据[i].HP;
                                //血背景
                                DrawSector(MsDrawList, ImVec2(MiniPos.x,MiniPos.y), 半径, 0, 360, ImColor(0,0,0), 32);
                                
                                //血条
                                DrawSector(MsDrawList, ImVec2(MiniPos.x,MiniPos.y), 半径, 0, 360*血量, ImColor(血条颜色), 32);
                                
                                
                                //大地血圈条背景
                                MsDrawList->AddRect(ImVec2(BoxPos.x-20, BoxPos.y), ImVec2(BoxPos.x+20, BoxPos.y+10), ImColor(方框颜色));
                                //血条
                                MsDrawList->AddRectFilled(ImVec2(BoxPos.x-20, BoxPos.y), ImVec2(BoxPos.x-20+血量*40, BoxPos.y+10), ImColor(血条颜色));
                            }
                        }
                        if (射线开关) {
                            
                            MsDrawList->AddLine(ImVec2(kWidth/2, kHeight/2), ImVec2(BoxPos.x, BoxPos.y-20), ImColor(射线颜色));
                        }
                        if (方框开关)
                        {
                            MsDrawList->AddRect(ImVec2(BoxPos.x-20, BoxPos.y-50), ImVec2(BoxPos.x+20, BoxPos.y+10), ImColor(方框颜色));
                        }
                        //方框下面的技能点
                        if (技能开关)
                        {
                            //方框下面的技能点
                            MsDrawList->AddCircle(ImVec2(BoxPos.x-20, BoxPos.y+15), 4, 读取英雄数据[i].Skill1 ? 0x00ff00 : 0xff0000);
                            MsDrawList->AddCircle(ImVec2(BoxPos.x-15, BoxPos.y+10), 4, 读取英雄数据[i].Skill2 ? 0x00ff00 : 0xff0000);
                            MsDrawList->AddCircle(ImVec2(BoxPos.x+15, BoxPos.y+10), 4, 读取英雄数据[i].Skill3 ? 0x00ff00 : 0xff0000);
                            MsDrawList->AddCircle(ImVec2(BoxPos.x+20, BoxPos.y+10), 4, 读取英雄数据[i].Skill4 ? 0x00ff00 : 0xff0000);
                        }
                        //顶部技能图
                        if (技能开关) {
                            YXsum++;
                            //绘制人物头像
                            技能表英雄头像视图[i].image = GetHeroImage(读取英雄数据[i].英雄ID);
                            [技能表英雄头像视图[i] setFrame:CGRectMake(技能绘制x调节 + (技能绘制y调节+3)*YXsum, 0, 技能绘制y调节, 技能绘制y调节)];
                            
                            //大招图标视图
                            大招图标视图[i].image = GetHeroImage(读取英雄数据[i].HeroTalent);
                            [大招图标视图[i] setFrame:CGRectMake(技能绘制x调节 + (技能绘制y调节+3)*YXsum, 技能绘制y调节+10, 技能绘制y调节, 技能绘制y调节)];
                            
                            //显示全部控件
                            [技能表英雄头像视图[i] setHidden:NO];
                            [大招图标视图[i] setHidden:NO];
                            
                            //大招技能时间显示
                            const char *技能倒计时文字;
                            const char *大招倒计时文字;
                            if(读取英雄数据[i].仅能倒计时 == 0){
                                技能倒计时文字="";
                            }else{
                                
                                技能倒计时文字 = [NSString stringWithFormat:@"%d", (读取英雄数据[i].仅能倒计时)].UTF8String;
                            }
                            
                            //召唤师大招时间
                            if(读取英雄数据[i].大招倒计时 == 0){
                                大招倒计时文字="";
                            }
                            else{
                                大招倒计时文字 = [NSString stringWithFormat:@"%d", (读取英雄数据[i].大招倒计时)].UTF8String;
                                
                            }
                                
                            //绘制技能时间
                           
                            MsDrawList->AddText(ImGui::GetFont(), 40 ,ImVec2(技能绘制x调节 + (技能绘制y调节+3)*YXsum,技能绘制y调节+10), ImColor(方框颜色), (char*)技能倒计时文字);
                            //绘制大招时间
                            
                            MsDrawList->AddText(ImGui::GetFont(), 40 ,ImVec2(技能绘制x调节 + (技能绘制y调节+3)*YXsum,技能绘制y调节+10), ImColor(方框颜色), (char*)大招倒计时文字);
                            
                            
                        }
                        
                    }
                    
                    
                }
                
               
                
            }
            
            //==================大地图野怪====================
           
            if (野怪绘制开关) {
                Vector2 MonsterScreen;
                std::vector<SmobaMonsterData> 野怪数据;
                GetMonster(&野怪数据);
                NSLog(@"野怪数据=%ld",野怪数据.size());
                for (int i= 0; i < 野怪数据.size(); i++) {
                    
                    if (野怪数据[i].野怪当前血量 > 0) {
                        if (ToScreen(GameCanvas,野怪数据[i].MonsterPos,&MonsterScreen)){
                            //小地图野怪
                            Vector2 小地图;
                            小地图.x=mapx;
                            小地图.y=mapy;
                            Vector2 MiniMonsterPos = ToMiniMap(小地图, 野怪数据[i].MonsterPos);
                            
                            //野怪背景
                            DrawSector(MsDrawList, ImVec2(MiniMonsterPos.x,MiniMonsterPos.y), 4, 0, 360, ImColor(0,0,0), 32);
                            //野怪血条
                            DrawSector(MsDrawList, ImVec2(MiniMonsterPos.x,MiniMonsterPos.y), 4, 0, 360*野怪数据[i].野怪当前血量/野怪数据[i].野怪最大血量, ImColor(血条颜色), 32);
                            //大地图野怪
                            if(血条开关)
                            {
                                //大地血圈条背景
                                MsDrawList->AddRect(ImVec2(MonsterScreen.x-20, MonsterScreen.y), ImVec2(MonsterScreen.x+20, MonsterScreen.y+10), ImColor(方框颜色));
                                //血条
                                MsDrawList->AddRectFilled(ImVec2(MonsterScreen.x-20, MonsterScreen.y), ImVec2(MonsterScreen.x-20+(40*野怪数据[i].野怪当前血量/野怪数据[i].野怪最大血量), MonsterScreen.y+10), ImColor(血条颜色));
                                
                            }
                            
                            if (方框开关)
                            {
                                MsDrawList->AddRect(ImVec2(MonsterScreen.x-20, MonsterScreen.y-50), ImVec2(MonsterScreen.x+20, MonsterScreen.y+10), ImColor(方框颜色));
                            }
                            
                            
                        }
                    }
                }
                
                
            }
            if (野怪倒计时开关) {
                
                std::vector<SmobaMonsterTime> 野怪倒计时数据;
                GetMonsterTime(&野怪倒计时数据);
                
                for (int i=0; i<野怪倒计时数据.size(); i++) {
                    
                    Vector2 小地图;
                    小地图.x=mapx;
                    小地图.y=mapy;
                    Vector2 MiniMonsterPos = ToMiniMap(小地图, 野怪倒计时数据[i].MonsterPos);
                    const char *倒计时文字;
                    倒计时文字 = [NSString stringWithFormat:@"%d", (野怪倒计时数据[i].野怪倒计时)].UTF8String;
                    NSLog(@"读取野怪倒计时数据=%s %f  %f",倒计时文字,MiniMonsterPos.x,MiniMonsterPos.y);
                    
                    MsDrawList->AddText(ImGui::GetFont(), 15 ,ImVec2(MiniMonsterPos.x, MiniMonsterPos.y), ImColor(1,0,0,1), (char*)倒计时文字);
                    
                }
            }
            
        }
    }
    
}

#pragma mark 内存函数
static void NetGetHeroImage(int HeroID)
{
    NSString*urlstring=[NSString stringWithFormat:@"https://qmui.oss-cn-hangzhou.aliyuncs.com/CIKEimage/%d.png",HeroID];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length < 1000)
    {
        for (int i=0; i<5; i++) {
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


#pragma mark - 触摸互动
- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    
    
    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

@end

