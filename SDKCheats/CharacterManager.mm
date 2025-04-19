#import "SDKCheats/CharacterManager.h"
#import "Cheat/SDK.h"
#import "Cheat/Pointers.h"
#import "SDKCheats/Sacrifice.h"

extern uintptr_t OwningGameInstance;
extern uintptr_t(*ProcessEvent)(uintptr_t, uintptr_t, uintptr_t);
extern uintptr_t FindObject(NSString*);
extern void ShowAlert(NSString*, NSString*);

void SelfSacrifice(void) {
    SetReadyToBeSacrificed(true);
}

@implementation CharacterManager

+ (void)changeCharacter:(int)characterId forRole:(EPlayerRole)role {
    if (!OwningGameInstance) {
        ShowAlert(@"Error", @"Game instance not found");
        return;
    }
    
    static uintptr_t GetLocalPlayerStateMenu_Function = FindObject(@"GetLocalPlayerStateMenu");
    static uintptr_t Server_SetSelectedCharacterId_Function = FindObject(@"Server_SetSelectedCharacterId");
    
    if (!GetLocalPlayerStateMenu_Function || !Server_SetSelectedCharacterId_Function) {
        ShowAlert(@"Error", @"Required functions not found");
        return;
    }
    
    struct { uintptr_t ReturnValue; } GetMenuStateParams = {0};
    struct { EPlayerRole forRole; int32_t ID; bool updateDisplayData; char padding[3]; } Parameters = {role, characterId, true, {0}};
    
    @try {
        ProcessEvent(OwningGameInstance, GetLocalPlayerStateMenu_Function, (uintptr_t)&GetMenuStateParams);
        if (GetMenuStateParams.ReturnValue) {
            ProcessEvent(GetMenuStateParams.ReturnValue, Server_SetSelectedCharacterId_Function, (uintptr_t)&Parameters);
        } else {
            ShowAlert(@"Error", @"PlayerState_Menu not found");
        }
    } @catch (NSException *e) {
        ShowAlert(@"Error", [NSString stringWithFormat:@"Failed to change character: %@", e.reason]);
    }
}

+ (void)changeCharacter:(int)characterId {
    [self changeCharacter:characterId forRole:EPlayerRole::VE_Camper];
}

+ (void)changeKillerCharacter:(int)characterId {
    [self changeCharacter:characterId forRole:EPlayerRole::VE_Slasher];
}

+ (void)resetCharacter {
    [self changeCharacter:0];
}

@end 