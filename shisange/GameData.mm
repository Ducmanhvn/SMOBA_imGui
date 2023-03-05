#include <stdio.h>
#include "Class.h"
#import <mach-o/dyld.h>
#import <mach/mach.h>

#include <sys/sysctl.h>
#import <string.h>
#include <string>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
long Imageaddress,Game_Data,Game_Viewport;
Matrix ViewMatrix;
std::vector<SmobaMonsterData>野怪数据;

extern "C" kern_return_t mach_vm_region_recurse(
                                                vm_map_t                 map,
                                                mach_vm_address_t        *address,
                                                mach_vm_size_t           *size,
                                                uint32_t                 *depth,
                                                vm_region_recurse_info_t info,
                                                mach_msg_type_number_t   *infoCnt);
#pragma mark 读取get_task
mach_port_t task;
int get_Pid(NSString* GameName) {
    size_t length = 0;
    static const int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, NULL, &length, NULL, 0);
    if (err == -1) err = errno;
    if (err == 0) {
        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
        if(procBuffer == NULL) return -1;
        sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, procBuffer, &length, NULL, 0);
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            NSString *进程名字=[NSString stringWithFormat:@"%s",procname];
            pid_t pid = procBuffer[i].kp_proc.p_pid;
            //自己写判断进程名 和平精英
            if([进程名字 containsString:GameName])
            {
                NSLog(@"pid==%d   %@",pid,进程名字);
                return pid;
            }
        }
    }
    
    return  -1;
}
long get_base_address(NSString* GameName) {
    vm_map_offset_t vmoffset = 0;
    vm_map_size_t vmsize = 0;
    uint32_t nesting_depth = 0;
    struct vm_region_submap_info_64 vbr;
    mach_msg_type_number_t vbrcount = 16;
    pid_t pid =get_Pid(GameName);
    
    kern_return_t kret = task_for_pid(mach_task_self(), pid, &task);
    if (kret == KERN_SUCCESS) {
        NSLog(@"pid==task=%d   ",task);
        mach_vm_region_recurse(task, &vmoffset, &vmsize, &nesting_depth, (vm_region_recurse_info_t)&vbr, &vbrcount);
        return vmoffset;
    }
    return 0;
}
bool Read_Data(long Src,int Size,void* Dst)
{
//    vm_copy(mach_task_self(),(vm_address_t)Src,Size,(vm_address_t)Dst);
    vm_size_t size = 0;
    
    kern_return_t error = vm_read_overwrite(task, (vm_address_t)Src, Size, (vm_address_t)Dst, &size);
    if(error != KERN_SUCCESS || size != Size) {
        return false;
    }
    return true;
}

long Read_Long(long src)
{
    long Buff=0;
    Read_Data(src,8,&Buff);
    return Buff;
}

int Read_Int(long src)
{
    int Buff=0;
    Read_Data(src,4,&Buff);
    return Buff;
}

int Read_Short(long src)
{
    int Buff=0;
    Read_Data(src,2,&Buff);
    return Buff;
}

float Read_Float(long src)
{
    float Buff=0;
    Read_Data(src,4,&Buff);
    return Buff;
}

bool ToScreen(Vector2 GameCanvas,Vector2 HeroPos,Vector2* Screen)
{
    Screen->横轴x=0;Screen->大小=0;
    float ViewW;
    ViewW = ViewMatrix._13 * HeroPos.横轴x + ViewMatrix._33 * HeroPos.大小 + ViewMatrix._43;
    if (ViewW < 0.01) return false;
    ViewW = 1/ViewW;
    Screen->横轴x = (1+(ViewMatrix._11 * HeroPos.横轴x + ViewMatrix._31 * HeroPos.大小 + ViewMatrix._41) * ViewW)*GameCanvas.横轴x/2;
    Screen->大小 = (1-(ViewMatrix._12 * HeroPos.横轴x + ViewMatrix._32 * HeroPos.大小 + ViewMatrix._42) * ViewW)*GameCanvas.大小/2;
    return true;
}

Vector2 ToMiniMap(Vector2 MiniMap,Vector2 HeroPos)
{
    Vector2 Pos;
    float transformation = ViewMatrix._11>0?1:-1;
    Pos.横轴x = (50 + HeroPos.横轴x*transformation)/100;
    Pos.大小 = (50 - HeroPos.大小*transformation)/100;
    
    return {MiniMap.横轴x + Pos.横轴x*MiniMap.大小,Pos.大小*MiniMap.大小};
}

bool RefreshMatrix()
{
    long P_Level1 = Read_Long(Game_Viewport+0x18);
    long P_Level2 = Read_Long(P_Level1+0x4F8);
    long P_Level3 = Read_Long(P_Level2+0x18);
    long Ptr_View =Read_Long(Read_Long(P_Level3 + 0xA0));
    NSLog(@"Ptr_View=%ld Imageaddress=%ld",Ptr_View,Imageaddress);
    if (Ptr_View < Imageaddress) return false;
    long P_ViewMatrix = Read_Long(Ptr_View+0x10)+0x2C8;
    Read_Data(P_ViewMatrix,64,&ViewMatrix);
    return true;
}

Vector2 GetPlayerPos(long Target)
{
    long Target_P1 = Read_Long(Target+0x1B8);
    long Target_P2 = Read_Long(Target_P1+0x10);
    long Target_P3 = Read_Long(Target_P2);
    long Target_P4 = Read_Long(Target_P3 + 0x10);
    
    int x1 = Read_Short(Target_P4);
    int x2 = Read_Short(Target_P4+2);
    
    int y1 = Read_Short(Target_P4+8);
    int y2 = Read_Short(Target_P4+10);
    
    return {(float)(x1-x2)/(float)1000,(float)(y1-y2)/(float)1000};
}

bool GetKillActivate(long P_Skill)
{
    if (Read_Int(P_Skill+0x10)==0) return false;
    return Read_Int(P_Skill+0x34)==1;
}

void GetHeroSkill(long Target,bool *Skill1,bool *Skill2,bool *Skill3,bool *Skill4)
{
    long SkillList = Read_Long(Target+0xF8);
    long P_Skill1 = Read_Long(SkillList+0xD8);
    long P_Skill2 = Read_Long(SkillList+0xF0);
    long P_Skill3 = Read_Long(SkillList+0x108);
    long P_Skill4 = Read_Long(SkillList+0x150);
    
    
    *Skill1 = GetKillActivate(P_Skill1);
    *Skill2 = GetKillActivate(P_Skill2);
    *Skill3 = GetKillActivate(P_Skill3);
    *Skill4 = GetKillActivate(P_Skill4);
}

int GetPlayerTeam(long Target)
{
    return Read_Int(Target+0x2C);
}
bool GetPlayerDead(long Target)
{
    long PlayerHP = Read_Long(Target+0x110);
    return Read_Int(PlayerHP+0x98)==0;
}

float GetPlayerHP(long Target)
{
    long PlayerHP = Read_Long(Target + 0x110);
    int HP = Read_Int(PlayerHP + 0x98) / 8192;
    int MaxHP = Read_Int(PlayerHP + 0xA8);
    if (HP == 0 || MaxHP == 0) return 0;
    return (float)HP / MaxHP;
}

int32_t GetGameHP(long Target){
    long HeroHP = Read_Long(Target+0x110);
    int32_t HP = Read_Int(HeroHP+0xA0);
    return HP;
}

int32_t GetGameMaxHP(long Target){
    long MonsterMaxHP = Read_Long(Target+0x110);
    int32_t MaxHP = Read_Int(MonsterMaxHP+0xA8);
    return MaxHP;
}

int GetPlayerHero(long Target)
{
    return Read_Int(Target+0x20);
}
int GetPlayerHeroTalentTime(long Target){//召唤师偏移
    long PlayerTime1 = Read_Long(Target+ 0xF8);
    long PlayerTime2 = Read_Long(PlayerTime1+ 0x150);
    long PlayerTime3 = Read_Long(PlayerTime2+ 0xA0);
    int PlayerTime4 = Read_Int(PlayerTime3+ 0x38);
    return (PlayerTime4 / 8192000);
}
int GetPlayerHeroTalent(long Target){//
    long PlayerData1 = Read_Long(Target+ 0xF8);
    long PlayerData2 = Read_Long(PlayerData1+ 0x150);
    return Read_Int(PlayerData2+ 0x330);
}
int GetGetHeroSkillTime(long Target){//大招偏移
    long Target_P1 = Read_Long(Target + 0xF8);
    long Target_P2 = Read_Long(Target_P1 + 0x108);
    long Target_P3 = Read_Long(Target_P2 + 0xA0);
    int Target_P4 = Read_Int(Target_P3 + 0x38);
    int HeroSkillTime = Target_P4/8192000;
    return HeroSkillTime;
}
void GetPlayers(std::vector<SmobaHeroData> *Players)
{
    Players->clear();
    野怪数据.clear();
    long PDatas = Read_Long(Read_Long(Game_Data)+0x390);
    if (PDatas > Imageaddress)
    {
        
        int MyTeam = ViewMatrix._11>0?1:2;
        long Array = Read_Long(PDatas+0x60);
        int ArraySize = Read_Int(PDatas+0x7C);
        if (ArraySize > 0 && ArraySize <= 20)
        {
            
            for (int i=0; i < ArraySize; i++) {
                long P_player = Read_Long(Array+i*0x18);
                if (P_player > Imageaddress){
                    SmobaHeroData HeroData;
                    HeroData.英雄ID = GetPlayerHero(P_player);
                    HeroData.HeroTeam = GetPlayerTeam(P_player);
                    HeroData.Dead = GetPlayerDead(P_player);
                    HeroData.HeroHP = GetGameHP(P_player);
                    HeroData.HeroMaxHP = GetGameMaxHP(P_player);
                    HeroData.Pos = GetPlayerPos(P_player);
                    HeroData.HP = GetPlayerHP(P_player);
                    HeroData.大招倒计时 = GetGetHeroSkillTime(P_player);
                    HeroData.HeroTalent = GetPlayerHeroTalent(P_player);
                    HeroData.仅能倒计时 = GetPlayerHeroTalentTime(P_player);
                    GetHeroSkill(P_player,&HeroData.Skill1,&HeroData.Skill2,&HeroData.Skill3,&HeroData.Skill4);
                    if (HeroData.HeroTeam != MyTeam)Players->push_back(HeroData);;
                }
            }
        }
        long Monster_Data = Read_Long(PDatas+0x148);
        int Monster_Count = Read_Int(PDatas+0x164);
        for (int i=0; i < Monster_Count; i++) {
            SmobaMonsterData Monster;
            long P_Monster = Read_Long(Monster_Data+i*0x18);
            Monster.MonsterID = GetPlayerHero(P_Monster);
            Monster.野怪当前血量 = GetGameHP(P_Monster);
            Monster.野怪最大血量 = GetGameMaxHP(P_Monster);
            Monster.MonsterPos = GetPlayerPos(P_Monster);
            野怪数据.push_back(Monster);
        }
        
    }
}

bool Gameinitialization()
{
    Imageaddress = get_base_address(@"smoba");
    Game_Data = Read_Long(Imageaddress+0xB2EE128);
    Game_Viewport = Read_Long(Imageaddress+0xC6F9068);
    NSLog(@"vmm=Imageaddress=%ld  Game_Data=%ld",Imageaddress,Game_Data);
    return Game_Data > Imageaddress || Game_Viewport > Imageaddress;
}
