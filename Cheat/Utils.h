#ifndef UTILS_H
#define UTILS_H

#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

#import "Offsets.h"
#import "Globals.h"
#import "Structs.h"

ViewMatrix CreateViewMatrix(Vector3 Rotation);
bool W2S(CGPoint& Result, Vector3 Position, Vector3 CameraLocation, float CameraFOV, ViewMatrix ViewMatrix);
uintptr_t FindObject(NSString* Name, NSString* OuterName);
uintptr_t GetObjectFromGUObjectArray(int32_t Index);
bool IsAddressValid(uintptr_t Address);
uintptr_t GetBaseAddressOfLibrary(const char* LibraryName);

NSString* GetNameFromFName(int32_t Index);

uintptr_t FindObject(NSString* Name);
uintptr_t GetObjectFromGUObjectArray(int32_t Index);
bool vm_read_buffer(uintptr_t address, void* buffer, size_t size);
void UpdatePointersLoop();
#endif /* UTILS_H */