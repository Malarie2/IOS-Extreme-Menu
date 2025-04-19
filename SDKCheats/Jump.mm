#import "Jump.h"
#import "Cheat/Pointers.h"
#import <UIKit/UIKit.h>
#import "NFramework.h"
extern "C" {

void LaunchPlayer(float launchForce, float angle) {
    if (!LocalPlayer) {
        ShowAlert(@"[NFramework] --> ", @"Local player not found");
        return;
    }
    
    struct {
        float JumpZ;
    } Parameters;
    Parameters.JumpZ = launchForce;
    
    static uintptr_t Jump_Function = FindObject(@"Jump");
    if (!Jump_Function) {
        ShowAlert(@"[NFramework] --> ", @"Jump function not found");
        return;
    }
    
    ProcessEvent(LocalPlayer, Jump_Function, (uintptr_t)&Parameters);
}

void JumpToHeight(float height) {
    if (!LocalPlayer) return;
    LaunchPlayer(500.0f, 0.0f);
}

} // extern "C"
