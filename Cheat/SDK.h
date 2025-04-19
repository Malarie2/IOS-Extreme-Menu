#pragma once

enum class EInteractionAnimation : uint8_t {
    VE_None = 0,
    VE_Generator = 1,
    VE_PullDownLeft = 2,
    VE_PullDownRight = 3,
    VE_Hiding = 4,
    VE_SearchCloset = 5,
    VE_HealingOther = 6,
    VE_OpenEscape = 7,
    VE_StruggleFree = 8,
    VE_HealOther = 9,
    VE_HealSelf = 10,
    VE_PickedUp = 11,
    VE_Unused01 = 12,
    VE_Dropped = 13,
    VE_Unused02 = 14,
    VE_BeingHooked = 15,
    VE_Sabotage = 16,
    VE_ChargeBlink = 17,
    VE_ThrowFirecracker = 18,
    VE_WakeUpOther = 19,
    VE_RemoveReverseBearTrap = 20,
    VE_DeadHard = 21,
    VE_DestroyPortal = 22,
    VE_OniDash = 23,
    VE_K34SliceAndDiceDash = 24,
    VE_PickUpAnniversaryCrown = 25,
    VE_InteractWithGlyph = 26,
    VE_OpenChest = 27,
    VE_MAX = 28
};

enum class EPlayerRole : uint8_t {
    VE_None = 0,
    VE_Slasher = 1,
    VE_Camper = 2,
    VE_Observer = 3,
    VE_MAX = 4
}; 
