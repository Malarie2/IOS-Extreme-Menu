#ifndef OFFSETS_H
#define OFFSETS_H

#import <cstdint>


namespace Offsets {
    struct Globals {
        const static uintptr_t GUObjectArrayOffset = 0xDFD8A90;
        const static uintptr_t FNamePoolOffset = 0xDBCAF00;
        const static uintptr_t GWorldOffset = 0xE0559D0;
        const static uintptr_t ProcessEventOffset = 0x6B0503C;
    };

    struct SDK {
        const static uintptr_t GetCapsuleTopPosition = 0x1037F1710;    
        const static uintptr_t GetCapsuleBottomPosition = 0x1037F1698; 
const static uintptr_t Function_GetActorBounds = 0x105dfb2a8; // Dostosuj ten offset do swojej gry

        // UEngine
        const static uintptr_t UEngineToGameViewportClientClass = 0x148;
        const static uintptr_t ACamperToEndGameComponent = 0x19c8;
        const static uintptr_t ACharacterToCharacterMovement = 0x298;
        const static uintptr_t PlayerStatusOffset = 0x70;  // EGameState PlayerStatus offset
        // UGameViewportClient 
        const static uintptr_t UGameViewportClientToWorld = 0x78;
        const static uintptr_t ACamperToReadyToBeSacrificed = 0x110;
        
        // UWorld
        const static uintptr_t UWorldToPersistentLevel = 0x38;
        const static uintptr_t UWorldToOwningGameInstance = 0x410;

        // UGameInstance
        const static uintptr_t UGameInstanceToLocalPlayers = 0x40;
        const static uintptr_t ActorToOutlineComponent = 0x5A8;
        const static uintptr_t OutlineComponentToStrategy = 0x2B8;
        const static uintptr_t UObjectToClass = 0x10;
        const static uintptr_t UClassToSuperClass = 0x40;
        const static uintptr_t ULevelToAActors = 0x98;
        const static uintptr_t ULevelToAActorsCount = 0xA0;
        const static uintptr_t UWorldToGameState = 0x3b0;
        const static uintptr_t APawnToPlayerState = 0x298;
        // UPlayer
        const static uintptr_t UPlayerToPlayerController = 0x38;

        // AActor
        const static uintptr_t AActorToRootComponent = 0x140;
        const static uintptr_t ACharacterToCapsuleComponent = 0x2a0;
        // USceneComponent
        const static uintptr_t USceneComponentToRelativeLocation = 0x134;
        const static uintptr_t USceneComponentToRelativeRotation = 0x140;
        
        // APlayerController
        const static uintptr_t APlayerControllerToAcknowledgedPawn = 0x2B8;
        const static uintptr_t APlayerControllerToPlayerCameraManager = 0x2D0;

        // APlayerCameraManager
        const static uintptr_t APlayerCameraManagerToCameraCachePrivate = 0x1AF0;

        // FCameraCacheEntry
        const static uintptr_t FCameraCacheEntryToPOV = 0x10;

        // FMinimalViewInfo
        const static uintptr_t FMinimalViewInfoToLocation = 0x0;
        const static uintptr_t FMinimalViewInfoToRotation = 0xC;
        const static uintptr_t FMinimalViewInfoToFOV = 0x18;

        // ADBDPlayer
        const static uintptr_t ADBDPlayerTo_associatedPlayerStateCache = 0x1410;
        const static uintptr_t ADBDPlayerTo_perkManager = 0xA98;

        // UPerkManager
        const static uintptr_t UPerkManagerTo_perks = 0xE0;
        
        // AGenerator
        const static uintptr_t AGeneratorToactivated = 0x368;

        const static uintptr_t FLegacyPlayerSavedProfileDataShared = 0x40;
        

        // ACharacter
        const static uintptr_t ACharacterToMesh = 0x290;
        const static uintptr_t USkinnedMeshComponentToSkeletalMesh = 0x4d0;








        // ADBDGameState
        const static uintptr_t ADBDGameStateToSlasher = 0x4f8;
        const static uintptr_t ADBDGameStateTo_generators = 0x660;
        const static uintptr_t ADBDGameStateTo_hatches = 0x680;
        const static uintptr_t ADBDGameStateTo_escapeDoors = 0x670;
        const static uintptr_t ADBDGameStateTo_totems = 0x6f0;
        const static uintptr_t ADBDGameStateTo_searchables = 0x650;
        const static uintptr_t ADBDGameStateTo_traps = 0x748;
        const static uintptr_t ADBDGameStateTo_collectableManager = 0x738;
        const static uintptr_t ADBDGameStateTo_pallets = 0x6b0;
        const static uintptr_t ADBDGameStateTo_meatHooks = 0x640;

        // UPerkCollectionComponent
        const static uintptr_t UPerkCollectionComponentTo_array = 0xB8;

        // ADBDPlayerState
        const static uintptr_t ADBDPlayerStateToPlayerData = 0x430;

        // FPlayerStateData
        const static uintptr_t FPlayerStateDataTo_playerGameState = 0x58;

        // ASlasher
        const static uintptr_t ASlasherTo_onryoPower = 0x1238;
        
        // AOnryoPower
        const static uintptr_t AOnryoPowerTo_televisions = 0x5f0;
        
        // UCollectableManager
        const static uintptr_t UCollectableManagerTo_collectables = 0xb8;

        // Dodaj nowe offsety
        const static uintptr_t APawnToPlayerController = 0x298;  // Offset od Pawn do PlayerController
        const static uintptr_t APlayerControllerToHUD = 0x2C8;   // Offset od PlayerController do HUD
    };

    struct Special {
        const static uintptr_t ULevelToActorArray = 0xA0;
        const static uintptr_t UObjectToFNameOffset = 0x18;
        const static uintptr_t ProcessEventVTableToFunctionAddress = 0x230;
        const static uintptr_t TArrayToCount = 0x8;
        const static uintptr_t PointerSize = 0x8;

        const static uintptr_t TUObjectArrayToElementCount = 0x14;
        const static uintptr_t FUObjectItemSize = 0x18;

        const static uintptr_t FNameStride = 4;
        const static uintptr_t FNamePoolBlocks = 0xD0;
        const static uintptr_t FNameHeader = 4;
        const static uintptr_t FNameLengthBit = 1;
        const static uintptr_t FNameMaxSize = 0xFF;
        const static uintptr_t FNameHeaderSize = 6;
    };
};

#endif /* OFFSETS_H */