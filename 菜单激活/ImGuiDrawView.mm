
#import "ImGuiDrawView.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include "imgui.h"
#include "imgui_impl_metal.h"
#import <Foundation/Foundation.h>
#import "Smoba.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface ImGuiDrawView () <MTKViewDelegate>

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;

@end


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
static int 横竖屏状态 = 1;
static bool 菜单显示状态;
+(void)showHiede{
    菜单显示状态=!菜单显示状态;
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
    
    if (view.hidden == false) {
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
                
                ImGui::Checkbox("透视总开关", &透视开关);
                ImGui::SameLine();
                ImGui::Checkbox("技能开关", &技能开关);
                ImGui::SameLine();
                ImGui::Checkbox("野怪开关", &野怪绘制开关);
                
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
                
                
                if (ImGui::RadioButton("左横屏", 横竖屏状态 == 0))
                    横竖屏状态 = 0;
                ImGui::SameLine();
                if (ImGui::RadioButton("竖屏", 横竖屏状态 == 1))
                    横竖屏状态 = 1;
                ImGui::SameLine();
                if (ImGui::RadioButton("右横屏", 横竖屏状态 == 2))
                    横竖屏状态 = 2;
                
                ImGui::SliderFloat("小地图横轴", &mapx, 0, 500);
                
                ImGui::SliderFloat("小地图大小", &mapy, 0, 500);
                
                ImGui::SliderFloat("技能图标横轴", &技能绘制x调节, 0, 500);
                
                ImGui::SliderFloat("技能图标大小", &技能绘制y调节, 0, 100);
                
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
        
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
        
    }
    [commandBuffer commit];
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

