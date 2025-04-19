#ifndef GLOBALS_H
#define GLOBALS_H

#import <cstdint>

extern uintptr_t BaseAddress;

extern uintptr_t(*ProcessEvent)(uintptr_t Instance, uintptr_t Function, uintptr_t Parameters);

extern uintptr_t Server_SetImmobilized;

extern uintptr_t PersistentLevel;
extern uintptr_t OwningGameInstance;
extern uintptr_t Server_Launch;
extern uintptr_t LocalPlayer;
extern bool IsKiller;



#endif /* GLOBALS_H */