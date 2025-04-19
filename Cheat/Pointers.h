#ifndef POINTERS_H
#define POINTERS_H

#include <chrono>
#include <thread>
#include <stdint.h>

#import "Utils.h"
#import <Foundation/Foundation.h>
#import "SDK.h"
#import "SDKCheats/TeleportManager.h"
#import "Structs.h"

// Dodaj deklarację ShowAlert
void ShowAlert(NSString *title, NSString *message);

uintptr_t GetRootComponent(uintptr_t Actor);
Vector3 GetActorPosition(uintptr_t RootComponent);

uintptr_t GetLocalPlayer();
uintptr_t GetLocalPlayerCameraManager();

void UpdatePointersLoop();

#ifdef __cplusplus
extern "C" {
#endif

void SetCustomFOV(float fov);
void SetPlayerAnimation(EInteractionAnimation animation);
BOOL getFloatIconEnabled(void);
void setFloatIconEnabled(BOOL value);

#ifdef __cplusplus
}
#endif

// Dodaj enum z powodami zakończenia gry
enum class EEndGameReason : uint8_t {
    None = 0,
    Normal = 1,
    KillerLeft = 2,
    PlayerLeftDuringLoading = 3,
    KillerLeftEarly = 4,
    InvalidPlayerRoles = 5,
    EEndGameReason_MAX = 6
};

// Dodaj deklarację funkcji
void ForceEndGame(EEndGameReason reason);

// Na początku pliku, po innych deklaracjach
extern NSMutableArray<NSValue*>* generatorPositions;
extern int currentGeneratorIndex;

// Dodaj deklaracje funkcji
void TeleportToNearestGenerator(void);
void UpdateGeneratorPositions(void);

// Dodaj tę deklarację w pliku Pointers.h
void TeleportTo(const Vector3& location);

// Wersja C
typedef struct {
    float Pitch;
    float Yaw;
    float Roll;
} FRotator;

#define MAKE_ROTATOR(p, y, r) ((FRotator){(p), (y), (r)})

// Dodaj przed innymi deklaracjami funkcji
FRotator MakeRotator(float pitch, float yaw, float roll);

// Dodaj te deklaracje na początku pliku
extern int ActorCount;
extern uintptr_t ActorArray;

void GetActorPos(uintptr_t Actor, Vector3* OutPosition);

#endif /* POINTERS_H */