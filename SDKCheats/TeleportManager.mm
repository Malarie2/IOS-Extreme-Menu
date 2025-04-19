#import <mach/mach.h>
#import "TeleportManager.h"
#import "Cheat/Pointers.h"
#import "Cheat/SDK.h"

// Zewnętrzne deklaracje
extern uintptr_t BaseAddress;
extern uintptr_t LocalPlayer;
extern uintptr_t OwningGameInstance;
extern uintptr_t(*ProcessEvent)(uintptr_t Instance, uintptr_t Function, uintptr_t Parameters);
extern void ShowAlert(NSString *title, NSString *message);
extern uintptr_t GetRootComponent(uintptr_t Actor);
extern uintptr_t FindObject(NSString *name);
extern void TeleportTo(const Vector3& location);
extern bool isAttachedToSurvivor;

// Globalne zmienne
NSMutableArray<NSValue*>* totemPositions = nil;
NSMutableArray<NSValue*>* hatchPositions = nil;
NSMutableArray<NSValue*>* gatePositions = nil;
NSMutableArray<NSValue*>* survivorPositions = nil;
NSMutableArray<NSValue*>* searchablePositions = nil;
NSMutableArray<NSValue*>* trapPositions = nil;
int currentTotemIndex = 0;
int currentHatchIndex = 0;
int currentGateIndex = 0;
int currentSurvivorIndex = 0;
int currentSearchableIndex = 0;
int currentTrapIndex = 0;

// Dodaj zmienną globalną do kontroli pętli
static bool isAttachedToKiller = false;
static dispatch_source_t attachTimer = nil;
bool isAttachedToSurvivor = false;
static dispatch_source_t survivorAttachTimer = nil;

// Na początku pliku dodaj zmienne globalne
static int currentAttachIndex = 0;
static int maxSurvivorCount = 4; // Maksymalna liczba survivorów w grze

// Dodaj na początku pliku nową zmienną do przechowywania znalezionych survivorów
NSMutableArray *foundSurvivors = nil;

// Funkcje teleportacji
extern "C" void TeleportToTotem(void) {
    UpdateTotemPositions();
    if (totemPositions.count == 0) {
        ShowAlert(@"Error", @"No totems found");
        return;
    }
    
    Vector3 position;
    [[totemPositions objectAtIndex:currentTotemIndex] getValue:&position];
    TeleportTo(position);
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to totem %d/%lu", 
        currentTotemIndex + 1, totemPositions.count]);
}


extern "C" void TeleportToHatch(void) {
    UpdateHatchPositions();
    if (hatchPositions.count == 0) {
        ShowAlert(@"Error", @"No hatches found");
        return;
    }
    
    // Najpierw teleportuj do aktualnej bramy
    Vector3 position;
    [[hatchPositions objectAtIndex:currentHatchIndex] getValue:&position];
    TeleportTo(position);
    
    // Następnie zaktualizuj indeks na następną bramę
    currentHatchIndex = (currentHatchIndex + 1) % hatchPositions.count;
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to hatch %d/%lu", 
        currentHatchIndex, hatchPositions.count]);
}



extern "C" void TeleportToGate(void) {
    UpdateGatePositions();
    if (gatePositions.count == 0) {
        ShowAlert(@"Error", @"No gates found");
        return;
    }
    
    // Najpierw teleportuj do aktualnej bramy
    Vector3 position;
    [[gatePositions objectAtIndex:currentGateIndex] getValue:&position];
    TeleportTo(position);
    
    // Następnie zaktualizuj indeks na następną bramę
    currentGateIndex = (currentGateIndex + 1) % gatePositions.count;
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to gate %d/%lu", 
        currentGateIndex, gatePositions.count]);
}

extern "C" void TeleportToKiller(void) {
    Vector3 position;
    UpdateKillerPosition(position);
    TeleportTo(position);
    ShowAlert(@"Success", @"Teleported to killer");
}

extern "C" void TeleportToSurvivor(void) {
    UpdateSurvivorPositions();
    if (survivorPositions.count == 0) {
        ShowAlert(@"Error", @"No survivors found");
        return;
    }
    
    Vector3 position;
    [[survivorPositions objectAtIndex:currentSurvivorIndex] getValue:&position];
    TeleportTo(position);
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to survivor %d/%lu", 
        currentSurvivorIndex + 1, survivorPositions.count]);
}

extern "C" void TeleportToChest(void) {
    UpdateSearchablePositions();
    if (searchablePositions.count == 0) {
        ShowAlert(@"Error", @"No chests found");
        return;
    }
    
    Vector3 position;
    [[searchablePositions objectAtIndex:currentSearchableIndex] getValue:&position];
    TeleportTo(position);
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to chest %d/%lu", 
        currentSearchableIndex + 1, searchablePositions.count]);
}

extern "C" void TeleportToHook(void) {
    ShowAlert(@"Info", @"Hook teleport not implemented yet");
}

extern "C" void AttachToKiller(void) {
    // Toggle attach state
    isAttachedToKiller = !isAttachedToKiller;
    
    if (isAttachedToKiller) {
        // Stwórz timer, który będzie aktualizował pozycję
        if (attachTimer == nil) {
            attachTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(attachTimer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
            
            dispatch_source_set_event_handler(attachTimer, ^{
                Vector3 killerPosition;
                UpdateKillerPosition(killerPosition);
                
                uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
                if (!World) return;
                
                uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
                if (!GameState) return;
                
                uintptr_t Killer = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateToSlasher);
                if (!Killer || Killer == LocalPlayer) {
                    isAttachedToKiller = false;
                    dispatch_source_cancel(attachTimer);
                    attachTimer = nil;
                    ShowAlert(@"Error", @"Lost killer connection");
                    return;
                }
                
                FRotator rotation = {0, 0, 0};
                



                struct {
                    bool snapPosition;
                    Vector3 Position;
                    float stopSnapDistance;
                    bool snapRotation;
                    FRotator Rotation;
                    float Time;
                    bool useZCoord;
                    bool sweepOnFinalSnap;
                    bool snapRoll;
                } params = {
                    true,           // snapPosition
                    killerPosition, // Position
                    0.0f,          // stopSnapDistance
                    false,          // snapRotation
                    rotation,       // Rotation
                    0.2f,          // Time
                    true,          // useZCoord
                    false,          // sweepOnFinalSnap
                    false          // snapRoll
                };
                
                ProcessEvent(LocalPlayer, FindObject(@"SnapCharacter"), (uintptr_t)&params);
            });
            
            dispatch_resume(attachTimer);
            ShowAlert(@"Success", @"Attached to killer");
        }
    } else {
        // Zatrzymaj timer jeśli istnieje
        if (attachTimer != nil) {
            dispatch_source_cancel(attachTimer);
            attachTimer = nil;
            ShowAlert(@"Success", @"Detached from killer");
        }
    }
}

extern "C" void AttachToSurvivor(void) {
    isAttachedToSurvivor = true;
    
    if (!foundSurvivors) {
        foundSurvivors = [NSMutableArray new];
    }
    currentAttachIndex = 0;
    
    if (survivorAttachTimer == nil) {
        survivorAttachTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(survivorAttachTimer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(survivorAttachTimer, ^{
            [foundSurvivors removeAllObjects];
            
            uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
            if (!World) return;
            
            uintptr_t PersistentLevel = *(uintptr_t*)(World + Offsets::SDK::UWorldToPersistentLevel);
            if (!PersistentLevel) return;

            uintptr_t ActorArray = *(uintptr_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray);
            if (!ActorArray) return;
            
            int32_t ActorCount = *(int32_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray + Offsets::Special::TArrayToCount);
            
            // Znajdź wszystkich survivorów
            for (int i = 0; i < ActorCount; i++) {
                uintptr_t Actor = *(uintptr_t*)(ActorArray + i * Offsets::Special::PointerSize);
                if (!Actor || Actor == LocalPlayer) continue;

                NSString* ActorName = GetNameFromFName(*(int32_t*)(Actor + Offsets::Special::UObjectToFNameOffset));
                if (!ActorName) continue;

                if ([ActorName hasPrefix:@"BP_CamperMale"] || [ActorName hasPrefix:@"BP_CamperFemale"]) {
                    [foundSurvivors addObject:@(Actor)];
                }
            }
            
            // Sprawdź czy mamy survivora o danym indeksie
            if (currentAttachIndex < foundSurvivors.count) {
                uintptr_t targetSurvivor = [foundSurvivors[currentAttachIndex] unsignedLongLongValue];
                uintptr_t RootComponent = GetRootComponent(targetSurvivor);
                if (RootComponent) {
                    Vector3 targetPosition = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
                    targetPosition.X -= 50.0f;
                    targetPosition.Z -= 85.0f;
                    
                    FRotator rotation = {0, 0, 0};
                    
                    struct {
                        bool snapPosition;
                        Vector3 Position;
                        float stopSnapDistance;
                        bool snapRotation;
                        FRotator Rotation;
                        float Time;
                        bool useZCoord;
                        bool sweepOnFinalSnap;
                        bool snapRoll;
                    } params = {
                        true,
                        targetPosition,
                        0.0f,
                        false,
                        rotation,
                        0.2f,
                        true,
                        false,
                        false
                    };
                    
                    ProcessEvent(LocalPlayer, FindObject(@"SnapCharacter"), (uintptr_t)&params);
                }
            }
        });
        
        dispatch_resume(survivorAttachTimer);
    }
}

extern "C" void NextAttachSurvivor(void) {
    if (!isAttachedToSurvivor) {
        ShowAlert(@"Error", @"First attach to survivor using Attach [S]");
        return;
    }
    
    // Aktualizuj listę survivorów
    [foundSurvivors removeAllObjects];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t PersistentLevel = *(uintptr_t*)(World + Offsets::SDK::UWorldToPersistentLevel);
    if (!PersistentLevel) return;

    uintptr_t ActorArray = *(uintptr_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray);
    if (!ActorArray) return;
    
    int32_t ActorCount = *(int32_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray + Offsets::Special::TArrayToCount);
    
    // Znajdź wszystkich survivorów
    for (int i = 0; i < ActorCount; i++) {
        uintptr_t Actor = *(uintptr_t*)(ActorArray + i * Offsets::Special::PointerSize);
        if (!Actor || Actor == LocalPlayer) continue;

        NSString* ActorName = GetNameFromFName(*(int32_t*)(Actor + Offsets::Special::UObjectToFNameOffset));
        if (!ActorName) continue;

        if ([ActorName hasPrefix:@"BP_CamperMale"] || [ActorName hasPrefix:@"BP_CamperFemale"]) {
            [foundSurvivors addObject:@(Actor)];
        }
    }
    
    if (foundSurvivors.count == 0) {
        ShowAlert(@"Error", @"No survivors found");
        return;
    }
    
    // Przełącz na następnego survivora
    currentAttachIndex = (currentAttachIndex + 1) % foundSurvivors.count;
    
    // Natychmiast teleportuj do nowego survivora
    uintptr_t targetSurvivor = [foundSurvivors[currentAttachIndex] unsignedLongLongValue];
    uintptr_t RootComponent = GetRootComponent(targetSurvivor);
    if (RootComponent) {
        Vector3 targetPosition = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
        targetPosition.X -= 50.0f;
        targetPosition.Z -= 85.0f;
        
        FRotator rotation = {0, 0, 0};
        
        struct {
            bool snapPosition;
            Vector3 Position;
            float stopSnapDistance;
            bool snapRotation;
            FRotator Rotation;
            float Time;
            bool useZCoord;
            bool sweepOnFinalSnap;
            bool snapRoll;
        } params = {
            true,
            targetPosition,
            0.0f,
            false,
            rotation,
            0.2f,
            true,
            false,
            false
        };
        
        ProcessEvent(LocalPlayer, FindObject(@"SnapCharacter"), (uintptr_t)&params);
        ShowAlert(@"Success", [NSString stringWithFormat:@"Switched to survivor %d/%lu", 
            currentAttachIndex + 1, foundSurvivors.count]);
    }
}

// Funkcje nawigacji
extern "C" void NextTotem(void) {
    if (totemPositions.count > 0) {
        currentTotemIndex = (currentTotemIndex + 1) % totemPositions.count;
        ShowAlert(@"Totem", [NSString stringWithFormat:@"Selected %d/%lu", 
            currentTotemIndex + 1, totemPositions.count]);
    }
}

extern "C" void PrevTotem(void) {
    if (totemPositions.count > 0) {
        currentTotemIndex = (currentTotemIndex - 1 + totemPositions.count) % totemPositions.count;
        ShowAlert(@"Totem", [NSString stringWithFormat:@"Selected %d/%lu", 
            currentTotemIndex + 1, totemPositions.count]);
    }
}

extern "C" void NextGate(void) {
    if (gatePositions.count > 0) {
        currentGateIndex = (currentGateIndex + 1) % gatePositions.count;
        ShowAlert(@"Gate", [NSString stringWithFormat:@"Selected %d/%lu", 
            currentGateIndex + 1, gatePositions.count]);
    }
}

extern "C" void PrevGate(void) {
    if (gatePositions.count > 0) {
        currentGateIndex = (currentGateIndex - 1 + gatePositions.count) % gatePositions.count;
        ShowAlert(@"Gate", [NSString stringWithFormat:@"Selected %d/%lu", 
            currentGateIndex + 1, gatePositions.count]);
    }
}

extern "C" void NextSurvivor(void) {
    if (survivorPositions.count > 0) {
        currentSurvivorIndex = (currentSurvivorIndex + 1) % survivorPositions.count;
        ShowAlert(@"Survivor", [NSString stringWithFormat:@"Selected %d/%lu", 
            currentSurvivorIndex + 1, survivorPositions.count]);
    }
}

extern "C" void PrevSurvivor(void) {
    if (survivorPositions.count > 0) {
        currentSurvivorIndex = (currentSurvivorIndex - 1 + survivorPositions.count) % survivorPositions.count;
        ShowAlert(@"Survivor", [NSString stringWithFormat:@"Selected %d/%lu", 
            currentSurvivorIndex + 1, survivorPositions.count]);
    }
}

// Funkcje aktualizacji pozycji
void UpdateSearchablePositions() {
    [searchablePositions removeAllObjects];
    if (!searchablePositions) searchablePositions = [NSMutableArray new];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t _searchables = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_searchables);
    int32_t _searchablesCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_searchables + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _searchablesCount && _searchables != 0; g++) {
        uintptr_t Searchable = *(uintptr_t*)(_searchables + g * Offsets::Special::PointerSize);
        if (!Searchable) continue;
        
        uintptr_t RootComponent = GetRootComponent(Searchable);
        if (!RootComponent) continue;
        
        Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
        position.Z += 100.0f;
        
        NSValue *positionValue = [NSValue valueWithBytes:&position objCType:@encode(Vector3)];
        [searchablePositions addObject:positionValue];
    }
}

void UpdateTotemPositions() {
    [totemPositions removeAllObjects];
    if (!totemPositions) totemPositions = [NSMutableArray new];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t _totems = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_totems);
    int32_t _totemsCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_totems + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _totemsCount && _totems != 0; g++) {
        uintptr_t Totem = *(uintptr_t*)(_totems + g * Offsets::Special::PointerSize);
        if (!Totem) continue;
        
        uintptr_t RootComponent = GetRootComponent(Totem);
        if (!RootComponent) continue;
        
        Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
        position.Z += 100.0f;
        
        NSValue *positionValue = [NSValue valueWithBytes:&position objCType:@encode(Vector3)];
        [totemPositions addObject:positionValue];
    }
}

void UpdateGatePositions() {
    [gatePositions removeAllObjects];
    if (!gatePositions) gatePositions = [NSMutableArray new];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t _gates = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_escapeDoors);
    int32_t _gatesCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_escapeDoors + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _gatesCount && _gates != 0; g++) {
        uintptr_t Gate = *(uintptr_t*)(_gates + g * Offsets::Special::PointerSize);
        if (!Gate) continue;
        
        uintptr_t RootComponent = GetRootComponent(Gate);
        if (!RootComponent) continue;
        
        Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
        position.Z += 100.0f;
        
        NSValue *positionValue = [NSValue valueWithBytes:&position objCType:@encode(Vector3)];
        [gatePositions addObject:positionValue];
    }
}

void UpdateHatchPositions() {
    [hatchPositions removeAllObjects];
    if (!hatchPositions) hatchPositions = [NSMutableArray new];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t _hatches = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_hatches);
    int32_t _hatchesCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_hatches + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _hatchesCount && _hatches != 0; g++) {
        uintptr_t Hatch = *(uintptr_t*)(_hatches + g * Offsets::Special::PointerSize);
        if (!Hatch) continue;
        
        uintptr_t RootComponent = GetRootComponent(Hatch);
        if (!RootComponent) continue;
        
        Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
        position.Z += 100.0f;
        
        NSValue *positionValue = [NSValue valueWithBytes:&position objCType:@encode(Vector3)];
        [hatchPositions addObject:positionValue];
    }
}

void UpdateKillerPosition(Vector3& position) {
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t Slasher = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateToSlasher);
    if (!Slasher || Slasher == LocalPlayer) return;
    
    uintptr_t RootComponent = GetRootComponent(Slasher);
    if (!RootComponent) return;
    
    position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
    position.Z += 100.0f;
}

void UpdateSurvivorPositions() {
    [survivorPositions removeAllObjects];
    if (!survivorPositions) survivorPositions = [NSMutableArray new];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t PersistentLevel = *(uintptr_t*)(World + Offsets::SDK::UWorldToPersistentLevel);
    if (!PersistentLevel) return;

    uintptr_t ActorArray = *(uintptr_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray);
    if (!ActorArray) return;
    
    int32_t ActorCount = *(int32_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray + Offsets::Special::TArrayToCount);
    int survivorsFound = 0;

    for (int i = 0; i < ActorCount && survivorsFound < 4; i++) {
        uintptr_t Actor = *(uintptr_t*)(ActorArray + i * Offsets::Special::PointerSize);
        if (!Actor) continue;

        NSString* ActorName = GetNameFromFName(*(int32_t*)(Actor + Offsets::Special::UObjectToFNameOffset));
        if (!ActorName) continue;

        if ([ActorName hasPrefix:@"BP_Camper"]) {
            if (Actor == LocalPlayer) continue;
            
            uintptr_t RootComponent = GetRootComponent(Actor);
            if (!RootComponent) continue;

            Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
            position.Z += 100.0f;
            
            NSValue *positionValue = [NSValue valueWithBytes:&position objCType:@encode(Vector3)];
            [survivorPositions addObject:positionValue];
            survivorsFound++;
        }
    }
}

// Dodaj implementację PrevAttachSurvivor
extern "C" void PrevAttachSurvivor(void) {
    if (!isAttachedToSurvivor) return;
    
    currentAttachIndex = (currentAttachIndex - 1 + maxSurvivorCount) % maxSurvivorCount;
}

// Dodaj funkcję do zatrzymywania timera
extern "C" void StopSurvivorAttach(void) {
    isAttachedToSurvivor = false;
    if (survivorAttachTimer != nil) {
        dispatch_source_cancel(survivorAttachTimer);
        survivorAttachTimer = nil;
    }
    [foundSurvivors removeAllObjects];
}