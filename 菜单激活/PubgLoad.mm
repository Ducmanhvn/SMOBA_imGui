//
//  PubgLoad.m
//  pubg
//
//  Created by 李良林 on 2021/2/14.
//

#import "PubgLoad.h"
#import <UIKit/UIKit.h>

#import "ImGuiDrawView.h"
#import <AVFoundation/AVFoundation.h>
@interface PubgLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
@end

@implementation PubgLoad
static PubgLoad *extraInfo;
static float 初始音量;
+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"load");
        extraInfo =  [PubgLoad alloc];
        [extraInfo jtyl];
    });
}
- (void)jtyl{
    NSLog(@"三指");
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;//点击次数
    tap.numberOfTouchesRequired = 3;//手指数
    [tap addTarget:self action:@selector(volumeChanged)];//三指调用
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:tap];//三指添加到顶层视图
    
    //音量
    AVAudioSession*audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    
}
- (void)volumeChanged:(NSNotification *)notification {
    float 最新音量 = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (初始音量!=最新音量) {
        初始音量=最新音量;
        [self volumeChanged];
    }
    NSLog(@"Current volume: %f", 最新音量);
}

static BOOL MenDeal;
- (void)volumeChanged {
    NSLog(@"菜单");
    MenDeal=!MenDeal;
    //初始化imgui视图
    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }
    
    [ImGuiDrawView showHiede:MenDeal];
    [[UIApplication sharedApplication].keyWindow addSubview:_vna.view];//imgui 添加到顶层视图

}


@end
