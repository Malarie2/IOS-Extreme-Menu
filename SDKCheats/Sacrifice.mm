#import "Sacrifice.h"
#import "../Cheat/SDK.h"
#import "../Cheat/Offsets.h"
#import "../Cheat/Pointers.h"

void SetReadyToBeSacrificed(bool ready) {
    if (!LocalPlayer) {
        ShowAlert(@"[NFramework] --> ", @"Local player not found");
        return;
    }

    @try {
        // Sprawdź czy to Survivor
        static uintptr_t IsCamper_Function = FindObject(@"IsCamper");
        if (IsCamper_Function) {
            struct {
                bool ReturnValue;
            } Parameters;
            ProcessEvent(LocalPlayer, IsCamper_Function, (uintptr_t)&Parameters);
            if (!Parameters.ReturnValue) {
                ShowAlert(@"[NFramework] --> ", @"Must be a survivor");
                return;
            }
        }

        // Znajdź komponent
        uintptr_t endGameComponent = *(uintptr_t*)(LocalPlayer + 0x19c8);
        
        if (!endGameComponent) {
            static uintptr_t CamperEndGameComponent_Class = FindObject(@"CamperEndGameComponent");
            if (CamperEndGameComponent_Class) {
                struct {
                    uintptr_t ComponentClass;
                    uintptr_t ReturnValue;
                } Parameters;
                Parameters.ComponentClass = CamperEndGameComponent_Class;
                
                static uintptr_t GetComponentByClass = FindObject(@"GetComponentByClass");
                if (GetComponentByClass) {
                    ProcessEvent(LocalPlayer, GetComponentByClass, (uintptr_t)&Parameters);
                    endGameComponent = Parameters.ReturnValue;
                }
            }
        }

        if (!endGameComponent) {
            ShowAlert(@"[NFramework] --> ", @"End game component not found");
            return;
        }

        // Ustaw _readyToBeSacrificed
        *(bool*)(endGameComponent + 0x110) = ready;
        ShowAlert(@"Success", ready ? @"Sacrifice Enabled" : @"Sacrifice Disabled");

    } @catch (NSException *exception) {
        ShowAlert(@"[NFramework] --> ", @"Failed to set sacrifice state");
    }
}