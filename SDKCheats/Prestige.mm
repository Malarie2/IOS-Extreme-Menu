#import "Prestige.h"
#import "../Cheat/SDK.h"
#import "../Cheat/Offsets.h"
#import "../Cheat/Pointers.h"

void SetPrestigeLevel(int prestige) {
    if (!OwningGameInstance) return;
    
    uintptr_t PlayerController = *(uintptr_t*)(*(uintptr_t*)(*(uintptr_t*)(OwningGameInstance + 
        Offsets::SDK::UGameInstanceToLocalPlayers)) + Offsets::SDK::UPlayerToPlayerController);
    if (!PlayerController) return;

    struct { int32_t characterLevel; int32_t prestigeLevel; bool callOnRep; } 
    Parameters = {50, prestige, true};

    static uintptr_t SetLevel = FindObject(@"Server_SetCharacterLevel");
    if (SetLevel) ProcessEvent(PlayerController, SetLevel, (uintptr_t)&Parameters);
}