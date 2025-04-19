#ifndef TELEPORTMANAGER_H
#define TELEPORTMANAGER_H

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Cheat/SDK.h"

#ifdef __cplusplus
extern "C" {
#endif

// Teleport functions
extern void TeleportToTotem(void);
extern void TeleportToHatch(void);
extern void TeleportToGate(void);
extern void TeleportToKiller(void);
extern void TeleportToSurvivor(void);
extern void TeleportToChest(void);
extern void TeleportToTrap(void);
extern void AttachToKiller(void);
extern void AttachToSurvivor(void);
extern void TeleportToNearestGenerator(void);

// Navigation
extern void NextTotem(void);
extern void PrevTotem(void);
extern void NextGate(void);
extern void PrevGate(void);
extern void NextSurvivor(void);
extern void PrevSurvivor(void);

// Position arrays for teleport
extern NSMutableArray<NSValue*>* totemPositions;
extern NSMutableArray<NSValue*>* hatchPositions;
extern NSMutableArray<NSValue*>* gatePositions;
extern NSMutableArray<NSValue*>* survivorPositions;
extern NSMutableArray<NSValue*>* searchablePositions;
extern NSMutableArray<NSValue*>* trapPositions;

// Current indices
extern int currentTotemIndex;
extern int currentHatchIndex;
extern int currentGateIndex;
extern int currentSurvivorIndex;
extern int currentSearchableIndex;
extern int currentTrapIndex;

// Update functions
extern void UpdateTotemPositions(void);
extern void UpdateHatchPositions(void);
extern void UpdateGatePositions(void);
extern void UpdateSurvivorPositions(void);
extern void UpdateSearchablePositions(void);
extern void UpdateTrapPositions(void);
extern void UpdateKillerPosition(struct Vector3& position);
extern void TeleportTo(const struct Vector3& location);

extern "C" void PrevAttachSurvivor(void);
extern "C" void NextAttachSurvivor(void);

extern void StopSurvivorAttach(void);

extern NSMutableArray *foundSurvivors;

#ifdef __cplusplus
}
#endif

#endif /* TELEPORTMANAGER_H */