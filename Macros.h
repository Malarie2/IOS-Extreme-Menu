#ifndef Macros_h
#define Macros_h

//
//  Macros.h
//  ModMenu
//
//  Created by AlexZero.
//  Copyright © 2024 AlexZero. All rights reserved.
//



#import "KittyMemory/writeData.hpp"

#include <substrate.h>
#include <mach-o/dyld.h>



#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^
#define HOOK(offset, ptr, orig) MSHookFunction((void *)getRealOffset(offset), (void *)ptr, (void **)&orig)
#define HOOK_NO_ORIG(offset, ptr) MSHookFunction((void *)getRealOffset(offset), (void *)ptr, NULL)

#define HOOKSYM(sym, ptr, org) MSHookFunction((void*)dlsym((void *)RTLD_DEFAULT, sym), (void *)ptr, (void **)&org)
#define HOOKSYM_NO_ORIG(sym, ptr)  MSHookFunction((void*)dlsym((void *)RTLD_DEFAULT, sym), (void *)ptr, NULL)
#define getSym(symName) dlsym((void *)RTLD_DEFAULT, symName)


#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]

static uint64_t getRealOffset(uint64_t offset) {
    return KittyMemory::getAbsoluteAddress(NULL, offset);
}

#endif /* Macros_h */
