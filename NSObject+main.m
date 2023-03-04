//
//  NSObject+main.m
//  3456
//
//  Created by  十三哥 on 2023/2/21.
//
#import "Smoba.h"
#import <UIKit/UIKit.h>
#import "shisangeCD.h"
#import "NSObject+main.h"
#include <sys/mount.h>
@implementation NSObject (main)
+(void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSObject 调用菜单测试];
        
        });
     
    });
}

-(void)调用菜单测试
{
    
    
    [shisangeCD 添加分组:@"这是一个分组" 分组说明:@"分组1说明" 是否展开:NO 功能数:5  子功能:^{
        //创建一个自定义视图 例子===================================
        UIView *a=[[UIView alloc] initWithFrame:CGRectMake(15, 0, 270, 40)];//这个尺寸为在单元格中的坐标系
        a.backgroundColor=[UIColor systemBlueColor];//随便设置个背景红色
        UILabel*lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 40)];
        lab.text=@"这是一个自定义视图例子";
        lab.textColor=[UIColor yellowColor];
        [a addSubview:lab];
        //视图绑定点击事件 便于点击操作
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
        tap2.numberOfTapsRequired = 1;//点击次数
        tap2.numberOfTouchesRequired = 1;//手指数
        [tap2 addTarget:self action:@selector(菜单)];
        [a addGestureRecognizer:tap2];
        //视图添加到菜单
        [shisangeCD 添加自定义视图:(a)];
        
        //添加一个开关 包含开启和关闭调用 例子===================================
        [shisangeCD 添加开关:@"这是一个开关例子" 开启:^{
            NSLog(@"测试功能2开启");
        } 关闭:^{
            NSLog(@"测试功能2关闭");
        }];
        
        
        //添加一个按钮 传送的是按钮在表格单元格的坐标系 例子===================================
        CGRect A=CGRectMake(0, 0, 80, 30);
        [shisangeCD 添加按钮:@"这是一个按钮例子" 点击操作:^{
            NSLog(@"点击了按钮3");
        } 尺寸:(A)];
        
        
        
        //添加一个选项卡 例子===================================
        NSArray *array = [NSArray arrayWithObjects:@"选项卡例子",@"选项卡2",@"选项卡3", nil];
        UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:array];
        segment.frame = CGRectMake(15,5,270,30);
        segment.selectedSegmentIndex = 1;
        segment.apportionsSegmentWidthsByContent = YES;
        [segment addTarget:self action:@selector(选项卡调用:) forControlEvents:UIControlEventValueChanged];
        //选项卡添加到菜单
        [shisangeCD 添加自定义视图:segment];
        
        
        
        
        //添加一个滑条视图例子=================
        UIView *父级视图=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];//这个尺寸为在单元格中的坐标系
        父级视图.backgroundColor=[UIColor clearColor];//随便设置个背景红色
        
        UISlider *slider1 = [[UISlider alloc] initWithFrame:CGRectMake(160, 5, 120, 30)];
        slider1.minimumValue = 0;
        slider1.maximumValue = 300;
        slider1.value = 100;
        [slider1 setContinuous:YES];
        slider1.tag=1;
        [slider1 addTarget:self action:@selector(滑条调用:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        [父级视图 addSubview:slider1];
        
        UILabel*lab2=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250, 40)];
        lab2.text=@"这是一个滑条例子";
        lab2.textColor=[UIColor systemBlueColor];
        [父级视图 addSubview:lab2];
        
        [shisangeCD 添加自定义视图:父级视图];
        
        
    }];
    //第二个分组一样
    
    [shisangeCD 添加分组:@"这是第二分组"  分组说明:@"王者跨进程" 是否展开:YES 功能数:9  子功能:^{
        [shisangeCD 添加开关:@"透视开关" 开启:^{
            透视开关=YES;
        } 关闭:^{
            透视开关=NO;
        }];
        [shisangeCD 添加开关:@"血条开关" 开启:^{
            血条开关=YES;
        } 关闭:^{
            血条开关=NO;
        }];
        [shisangeCD 添加开关:@"射线开关" 开启:^{
            射线开关=YES;
        } 关闭:^{
            射线开关=NO;
        }];
        [shisangeCD 添加开关:@"方框开关" 开启:^{
            方框开关=YES;
        } 关闭:^{
            方框开关=NO;
        }];
        [shisangeCD 添加开关:@"技能开关" 开启:^{
            技能开关=YES;
        } 关闭:^{
            技能开关=NO;
        }];
        
        [shisangeCD 添加开关:@"野怪绘制开关" 开启:^{
            野怪绘制开关=YES;
        } 关闭:^{
            野怪绘制开关=NO;
        }];
        
        //血圈滑条================
        UIView *父级视图=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];//这个尺寸为在单元格中的坐标系
        父级视图.backgroundColor=[UIColor clearColor];//随便设置个背景红色
        
        UISlider *slider1 = [[UISlider alloc] initWithFrame:CGRectMake(110, 5, 120, 30)];
        slider1.minimumValue = 0;
        slider1.maximumValue = 80;
        slider1.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"半径"];
        [slider1 setContinuous:YES];
        slider1.tag=1;
        [slider1 addTarget:self action:@selector(滑条调用:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        [父级视图 addSubview:slider1];
        
        UILabel*lab1=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 40)];
        lab1.text=@"血圈大小";
        lab1.textColor=[UIColor systemBlueColor];
        [父级视图 addSubview:lab1];
        
        [shisangeCD 添加自定义视图:父级视图];
        
        
        //地图框横轴滑条================
        UIView *父级视图2=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];//这个尺寸为在单元格中的坐标系
        父级视图2.backgroundColor=[UIColor clearColor];//随便设置个背景红色
        
        UISlider *slider2 = [[UISlider alloc] initWithFrame:CGRectMake(110, 5, 120, 30)];
        slider2.minimumValue = 0;
        slider2.maximumValue = 500;
        slider2.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"mapx"];
        [slider2 setContinuous:YES];
        slider2.tag=2;
        [slider2 addTarget:self action:@selector(滑条调用:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        [父级视图2 addSubview:slider2];
        
        UILabel*lab2=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 40)];
        lab2.text=@"左右矫正";
        lab2.textColor=[UIColor systemBlueColor];
        [父级视图2 addSubview:lab2];
        
        [shisangeCD 添加自定义视图:父级视图2];
        
        //地图框大小滑条================
        UIView *父级视图3=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];//这个尺寸为在单元格中的坐标系
        父级视图3.backgroundColor=[UIColor clearColor];//随便设置个背景红色
        
        UISlider *slider3 = [[UISlider alloc] initWithFrame:CGRectMake(110, 5, 120, 30)];
        slider3.minimumValue = 0;
        slider3.maximumValue = 400;
        slider3.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"mapy"];
        [slider3 setContinuous:YES];
        slider3.tag=3;
        [slider3 addTarget:self action:@selector(滑条调用:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        [父级视图3 addSubview:slider3];
        
        UILabel*lab3=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 40)];
        lab3.text=@"大小矫正";
        lab3.textColor=[UIColor systemBlueColor];
        [父级视图3 addSubview:lab3];
        
        [shisangeCD 添加自定义视图:父级视图3];
        
    }];
    
    
}
-(void)菜单
{
    NSLog(@"视图被点击了");
}
-(void)选项卡调用:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0) {
        NSLog(@"点击了第一个选项卡");
    }else if(sender.selectedSegmentIndex == 1){
        NSLog(@"点击了第2个选项卡");
    }else if(sender.selectedSegmentIndex == 2){
        NSLog(@"点击了第3个选项卡");
    }
    
}
-(void)滑条调用:(UISlider*)Slider
{
    if (Slider.tag==1) {
        半径=Slider.value;
        [[NSUserDefaults standardUserDefaults] setFloat:半径 forKey:@"半径"];
    }
    if (Slider.tag==2) {
        mapx=Slider.value;
        [[NSUserDefaults standardUserDefaults] setFloat:mapx forKey:@"mapx"];
    }
    if (Slider.tag==3) {
        mapy=Slider.value;
        [[NSUserDefaults standardUserDefaults] setFloat:mapy forKey:@"mapy"];
    }
    NSLog(@"当前滑动值=%.1f",Slider.value);
    
}
@end
