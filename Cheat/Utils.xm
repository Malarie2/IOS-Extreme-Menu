#import "Utils.h"
#import <mach/mach.h>
#import <mach/mach_traps.h>

extern float currentFOV;

ViewMatrix CreateViewMatrix(Vector3 Rotation) {
    ViewMatrix Result;
    Vector3 NewRotation = Rotation * static_cast<float>(M_PI) / 180.0f;

    float sin_pitch = sinf(NewRotation.X);
	float cos_pitch = cosf(NewRotation.X);
	float sin_yaw = sinf(NewRotation.Y);
	float cos_yaw = cosf(NewRotation.Y);
	float sin_roll = sinf(NewRotation.Z);
	float cos_roll = cosf(NewRotation.Z);

    Result.Matrix[0][0] = cos_pitch * cos_yaw;
	Result.Matrix[0][1] = cos_pitch * sin_yaw;
	Result.Matrix[0][2] = sin_pitch;

	Result.Matrix[1][0] = sin_roll * sin_pitch * cos_yaw - cos_roll * sin_yaw;
	Result.Matrix[1][1] = sin_roll * sin_pitch * sin_yaw + cos_roll * cos_yaw;
	Result.Matrix[1][2] = -sin_roll * cos_pitch;

	Result.Matrix[2][0] = -(cos_roll * sin_pitch * cos_yaw + sin_roll * sin_yaw);
	Result.Matrix[2][1] = cos_yaw * sin_roll - cos_roll * sin_pitch * sin_yaw;
	Result.Matrix[2][2] = cos_roll * cos_pitch;

    return Result;
}

bool W2S(CGPoint &point, Vector3 location, Vector3 cameraLocation, float cameraFOV, ViewMatrix viewMatrix) {
    Vector3 XAxis;
    XAxis.X = viewMatrix.Matrix[0][0];
    XAxis.Y = viewMatrix.Matrix[0][1];
    XAxis.Z = viewMatrix.Matrix[0][2];

    Vector3 YAxis;
    YAxis.X = viewMatrix.Matrix[1][0];
    YAxis.Y = viewMatrix.Matrix[1][1];
    YAxis.Z = viewMatrix.Matrix[1][2];

    Vector3 ZAxis;
    ZAxis.X = viewMatrix.Matrix[2][0];
    ZAxis.Y = viewMatrix.Matrix[2][1];
    ZAxis.Z = viewMatrix.Matrix[2][2];

    Vector3 Delta = location - cameraLocation;

    Vector3 DotProducts;
    DotProducts.X = Delta.Dot(YAxis);
    DotProducts.Y = Delta.Dot(ZAxis);
    DotProducts.Z = Delta.Dot(XAxis);
    if (DotProducts.Z < 1.0f) return false;

    float Magic = [UIScreen mainScreen].bounds.size.width / 2 / tanf(cameraFOV * static_cast<float>(M_PI) / 360.0f) / DotProducts.Z;
    point.x = [UIScreen mainScreen].bounds.size.width / 2 + DotProducts.X * Magic;
    point.y = [UIScreen mainScreen].bounds.size.height / 2 - DotProducts.Y * Magic;

    return true;
}

uintptr_t GetBaseAddressOfLibrary(const char* LibraryName) {
    uint32_t ImageCount = _dyld_image_count();
    for (uint32_t i = 0; i < ImageCount; ++i) {
        const char* ImageName = _dyld_get_image_name(i);
        if (strstr(ImageName, LibraryName) != NULL) {
            const struct mach_header* ImageHeader = _dyld_get_image_header(i);
            return (uintptr_t)ImageHeader;
        }
    }
    
    return 0;
}

NSString* GetNameFromFName(int32_t Index) {
	NSString* Name = @"";

	if (Index < 1) return Name;

	int32_t BlockOffset = ((Index >> 16) * Offsets::Special::PointerSize);
    int32_t ChunkOffset = ((Index & 0xFFFF) * Offsets::Special::FNameStride);

    uintptr_t Chunk = *(uintptr_t*)(BaseAddress + Offsets::Globals::FNamePoolOffset + Offsets::Special::FNamePoolBlocks + BlockOffset);
    if (!Chunk) return Name;

    int16_t NameHeader = *(int16_t*)(Chunk + ChunkOffset + Offsets::Special::FNameHeader);

    if (!(NameHeader & 0x1)) { // Isn't wide
        int16_t Length = (NameHeader >> Offsets::Special::FNameLengthBit);
        if (Length > 0 && Length <= Offsets::Special::FNameMaxSize) Name = [[NSString alloc] initWithBytes:(void*)(Chunk + ChunkOffset + Offsets::Special::FNameHeaderSize) length:Length encoding:NSUTF8StringEncoding];
    }
	
	return Name;
}

uintptr_t GetObjectFromGUObjectArray(int32_t Index) {
    int32_t ElementCount = *(int32_t*)(BaseAddress + Offsets::Globals::GUObjectArrayOffset + Offsets::Special::TUObjectArrayToElementCount);
    if (Index < 0 || Index >= ElementCount) return 0x0;

    int32_t ElementsPerChunk = 64 * 1024;
    int32_t ChunkIndex = Index / ElementsPerChunk;
    int32_t InsideChunkIndex = Index % ElementsPerChunk;

    uintptr_t Objects = *(uintptr_t*)(BaseAddress + Offsets::Globals::GUObjectArrayOffset);
    if (!Objects) return 0x0;
    uintptr_t Chunk = *(uintptr_t*)(Objects + ChunkIndex);
    if (!Chunk) return 0x0;
    uintptr_t Object = *(uintptr_t*)(Chunk + (InsideChunkIndex * Offsets::Special::FUObjectItemSize));
    return Object ?: 0x0;
}

uintptr_t FindObject(NSString* Name) {
    int32_t ElementCount = *(int32_t*)(BaseAddress + Offsets::Globals::GUObjectArrayOffset + Offsets::Special::TUObjectArrayToElementCount);

    for (int32_t i = 0; i < ElementCount; i++) {
        uintptr_t Object = GetObjectFromGUObjectArray(i);
        if (!Object) continue;

        int32_t ObjectFName = *(int32_t*)(Object + Offsets::Special::UObjectToFNameOffset);
        NSString* ObjectName = GetNameFromFName(ObjectFName);
        if ([ObjectName isEqualToString:Name]) return Object;
    }

    return 0x0;
}



bool IsAddressValid(uintptr_t Address) {
    uint8_t Data = 0;
    size_t Size = 0;
    int KR = vm_read_overwrite(mach_task_self(), (vm_address_t)Address, 1, (vm_address_t)&Data, &Size);
    return !(KR == KERN_INVALID_ADDRESS || KR == KERN_MEMORY_FAILURE || KR == KERN_MEMORY_ERROR);
}


void DumpNames() {
    NSArray* Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DocumentsDirectory = [Paths firstObject];
    NSString* FilePath = [DocumentsDirectory stringByAppendingPathComponent:@"NameDump.txt"];
    NSFileHandle* FileHandle = [NSFileHandle fileHandleForWritingAtPath:FilePath];

    if (!FileHandle) {
        NSError* Error = nil;
        BOOL Success = [[NSFileManager defaultManager] createFileAtPath:FilePath contents:nil attributes:nil];
        if (!Success) {
            NSLog(@"Failed to create file at path: %@", FilePath);
            return;
        }

        FileHandle = [NSFileHandle fileHandleForWritingAtPath:FilePath];
        if (!FileHandle) {
            NSLog(@"Failed to open file for writing at path: %@", FilePath);
            return;
        }
    }

    NSDate* LastNonEmptyNameTime = [NSDate date];
    NSTimeInterval Timeout = 10.0f;
    BOOL ShouldContinue = YES;
    int NameIndex = 0;

    NSLog(@"Started Name-Dump!");
    while (ShouldContinue) {
        NSString* Name = GetNameFromFName(NameIndex);
        if ([Name length] > 0) {
            NSString* LogEntry = [NSString stringWithFormat:@"%d %@\n", NameIndex, Name];
            
            @try {
                [FileHandle seekToEndOfFile];
                [FileHandle writeData:[LogEntry dataUsingEncoding:NSUTF8StringEncoding]];
                [FileHandle synchronizeFile];
            } @catch (NSException* Exception) {
                NSLog(@"Exception while writing to file: %@", Exception);
                ShouldContinue = NO;
            }
            
            LastNonEmptyNameTime = [NSDate date];
        }

        if ([[NSDate date] timeIntervalSinceDate:LastNonEmptyNameTime] > Timeout) ShouldContinue = NO;
        NameIndex++;
    }

    @try {[FileHandle closeFile];}
    @catch (NSException* Exception) {NSLog(@"Exception while closing file: %@", Exception);}
    NSLog(@"Done!");
}

int32_t FindFName(NSString* Name) {
    NSDate* LastNonEmptyNameTime = [NSDate date];
    NSTimeInterval Timeout = 1.0f;
    BOOL ShouldContinue = YES;
    int NameIndex = 0;

    while (ShouldContinue) {
        NSString* CurrentName = GetNameFromFName(NameIndex);
        if ([CurrentName length] > 0) {
            LastNonEmptyNameTime = [NSDate date];
            if ([CurrentName isEqualToString:Name]) {
				NSLog(@"Found FName %@", CurrentName);
				return NameIndex;
			}
        }

        if ([[NSDate date] timeIntervalSinceDate:LastNonEmptyNameTime] > Timeout) ShouldContinue = NO;
        NameIndex++;
    }

    return 0;
}

