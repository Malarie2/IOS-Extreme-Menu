#import "NFToggles.h"
#import "Utils/NFPatch.h"

#import "Utils/NakanoItsuki.h"
#import "Utils/NakanoIchika.h"
#import "Utils/NakanoNino.h"
#import "Utils/NakanoMiku.h"
#import "Cheat/Offsets.h"
#import "Utils/NakanoItsuki.h"

#import "Magicolors/ColorPicker.h"


@implementation NFToggles

#pragma mark - Toggle Configurations

+ (NSArray *)toggleTitlesForGroup:(NFToggleGroup)group {
    switch (group) {
        case NFToggleGroupAuraActors:
            return @[@"Aura Killer", @"Aura Spirit (Ghost)", @"Aura Spirit (Survivors)", 
                    @"Aura Survivors", @"Aura Survivors (Red)"];
            
        case NFToggleGroupAuraObjects:
            return @[@"Aura Generator", @"Aura Generator (Blue)", @"Aura Generator (Percentage)",
                    @"Aura Hooks", @"Aura Lockers", @"Aura Breakable Doors", 
                    @"Aura Pallets/Windows", @"Aura Pallets", @"Aura Totems", @"Aura Chest",
                    @"Aura Items", @"Aura Killer Objects", @"Aura Hatch", @"Aura Exit Gates"];
    }
    return @[];
}

+ (NSDictionary *)toggleConfigForGroup:(NFToggleGroup)group {
    NSDictionary *configs = @{
        @(NFToggleGroupAuraActors): @{
            @"Aura Killer": @{@"selector": @"auraKiller:", @"symbol": @"person.crop.circle.fill.badge.xmark"},
            @"Aura Spirit (Ghost)": @{@"selector": @"auraSpirit:", @"symbol": @"person.crop.circle.fill.badge.questionmark"},
            @"Aura Spirit (Survivors)": @{@"selector": @"auraSurvivorsSpirit:", @"symbol": @"person.3.sequence.fill"},
            @"Aura Survivors": @{@"selector": @"auraSurvivors:", @"symbol": @"person.2.circle.fill"},
            @"Aura Survivors (Red)": @{@"selector": @"auraSurvivorsRed:", @"symbol": @"person.2.wave.2.fill"}
        },
        @(NFToggleGroupAuraObjects): @{
            @"Aura Generator": @{@"selector": @"auraGenerator:", @"symbol": @"bolt.circle.fill"},
            @"Aura Generator (Blue)": @{@"selector": @"auraGeneratorsBlue:", @"symbol": @"bolt.badge.a.fill"},
            @"Aura Generator (Percentage)": @{@"selector": @"auraGeneratorsPercentage:", @"symbol": @"chart.bar.fill"},
            @"Aura Hooks": @{@"selector": @"auraHooks:", @"symbol": @"link.circle.fill"},
            @"Aura Lockers": @{@"selector": @"auraLockers:", @"symbol": @"cabinet.fill"},
            @"Aura Breakable Doors": @{@"selector": @"auraBreakableDoors:", @"symbol": @"door.left.hand.closed"},
            @"Aura Pallets/Windows": @{@"selector": @"auraPalletsWindows:", @"symbol": @"square.stack.3d.up.fill"},
            @"Aura Pallets": @{@"selector": @"auraPallets:", @"symbol": @"hammer.circle.fill"},
            @"Aura Totems": @{@"selector": @"auraTotems:", @"symbol": @"flame.circle.fill"},
            @"Aura Chest": @{@"selector": @"auraChest:", @"symbol": @"shippingbox.fill"},
            @"Aura Items": @{@"selector": @"auraItems:", @"symbol": @"gift.circle.fill"},
            @"Aura Killer Objects": @{@"selector": @"auraKillerObjects:", @"symbol": @"scissors.circle.fill"},
            @"Aura Hatch": @{@"selector": @"auraHatch:", @"symbol": @"circle.dotted"},
            @"Aura Exit Gates": @{@"selector": @"auraExitGates:", @"symbol": @"door.right.hand.open"}
        }
    };
    return configs[@(group)] ?: @{};
}

















#pragma mark - Aura Actors Methods
// Aura Killer
+ (void)auraKiller:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10353AD2C"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10353AD2C"), strtoul(ENCRYPTHEX("0xD3000094"), nullptr, 0));
    }
}

// Aura Spirit (Ghost)
+ (void)auraSpirit:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1041D3164"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1041D3164"), strtoul(ENCRYPTHEX("0xB4ABD717"), nullptr, 0));
    }
}

// Aura Spirit (Survivors)
+ (void)auraSurvivorsSpirit:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1041D31DC"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1041D31DC"), strtoul(ENCRYPTHEX("0x37A3D797"), nullptr, 0));
    }
}

// Aura Survivors
+ (void)auraSurvivors:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10353FAEC"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10353FAEC"), strtoul(ENCRYPTHEX("0x15030094"), nullptr, 0));
    }
}

// Aura Survivors (Red) ////not found
+ (void)auraSurvivorsRed:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103541A34"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103541A34"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

#pragma mark - Aura Objects - Generator Related Methods
// Aura Generator
+ (void)auraGenerator:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506A90"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506A90"), strtoul(ENCRYPTHEX("0x3607F280"), nullptr, 0));
    }
}

// Aura Generator (Blue) ///notfound
+ (void)auraGeneratorsBlue:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Aura Generator (Percentage)
+ (void)auraGeneratorsPercentage:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506674"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506674"), strtoul(ENCRYPTHEX("0x20010034"), nullptr, 0));
    }
}

#pragma mark - Aura Objects - Interactive Elements Methods
// Aura Hooks
+ (void)auraHooks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B79C"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B79C"), strtoul(ENCRYPTHEX("0x51000094"), nullptr, 0));
    }
}

// Aura Lockers
+ (void)auraLockers:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B0B4"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B0B4"), strtoul(ENCRYPTHEX("0x2E000094"), nullptr, 0));
    }
}

// Aura Breakable Doors
+ (void)auraBreakableDoors:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103502FDC"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103502FDC"), strtoul(ENCRYPTHEX("0x86E10094"), nullptr, 0));
    }
}

#pragma mark - Aura Objects - Navigation Elements Methods
// Aura Pallets/Windows
+ (void)auraPalletsWindows:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035421C4"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035421C4"), strtoul(ENCRYPTHEX("0x60010036"), nullptr, 0));
    }
}

// Aura Pallets  //notfound
+ (void)auraPallets:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103504C78"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103504C78"), strtoul(ENCRYPTHEX("0xDC260094"), nullptr, 0));
    }
}

// Aura Totems
+ (void)auraTotems:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103541F80"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103541F80"), strtoul(ENCRYPTHEX("0xC0010036"), nullptr, 0));
    }
}

#pragma mark - Aura Objects - Collectible Elements Methods
// Aura Chest
+ (void)auraChest:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10353AB80"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10353AB80"), strtoul(ENCRYPTHEX("0xE0000036"), nullptr, 0));
    }
}

// Aura Items GG
+ (void)auraItems:(UISwitch *)SW {
    if ([SW isOn]) {
        // Aura Items
        vm(ENCRYPTOFFSET("0x10353E820"), strtoul(ENCRYPTHEX("0x1F2003D5"), nullptr, 0)); // NOP (original: 0x20 21 28 1E)
        vm(ENCRYPTOFFSET("0x10353E824"), strtoul(ENCRYPTHEX("0x1F2003D5"), nullptr, 0)); // NOP (original: 0xED 00 00 54)
        vm(ENCRYPTOFFSET("0x10353E828"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0)); // MOV W0, #1
    } else {
        // Restore original bytes
        vm(ENCRYPTOFFSET("0x10353E820"), strtoul(ENCRYPTHEX("0x2021281E"), nullptr, 0)); // FCMP S9, S8
        vm(ENCRYPTOFFSET("0x10353E824"), strtoul(ENCRYPTHEX("0xED000054"), nullptr, 0)); // B.LE loc_10353E840
        vm(ENCRYPTOFFSET("0x10353E828"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0)); // MOV W0, #1
    }
}

// Aura Killer Objects
+ (void)auraKillerObjects:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1034FEFDC"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1034FEFDC"), strtoul(ENCRYPTHEX("0x59000094"), nullptr, 0));
    }
}

#pragma mark - Aura Objects - Escape Related Methods
// Aura Hatch
+ (void)auraHatch:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506CF0"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506CF0"), strtoul(ENCRYPTHEX("0x0A000094"), nullptr, 0));
    }
}

// Aura Exit Gates
+ (void)auraExitGates:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103504FC8"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103504FC8"), strtoul(ENCRYPTHEX("0x6AE4FF97"), nullptr, 0));
    }
}


+ (void)DBDUIThemeRed:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1068975D0"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1068975D0"), strtoul(ENCRYPTHEX("0x0101271E"), nullptr, 0));
    }
}

+ (void)DBDUIThemeBlue:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1068976B8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1068976B8"), strtoul(ENCRYPTHEX("0x0101271E"), nullptr, 0));
    }
}
+ (void)DBDUIThemeGreen:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x106897658"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x106897658"), strtoul(ENCRYPTHEX("0x0104021F"), nullptr, 0));
    }
}

+ (void)DBDUIThemeOrange:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1068976DC"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x1068975FC"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1068976DC"), strtoul(ENCRYPTHEX("0x0804021F"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x1068975FC"), strtoul(ENCRYPTHEX("0x0004021F"), nullptr, 0));
    }
}

+ (void)DBDUIThemePink:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1068975D0"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x1068976B8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1068975D0"), strtoul(ENCRYPTHEX("0x0101271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x1068976B8"), strtoul(ENCRYPTHEX("0x0101271E"), nullptr, 0));
    }
}

+ (void)DBDUIThemeRainbow:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x106897594"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x106897594"), strtoul(ENCRYPTHEX("0x031C610E"), nullptr, 0));
    }
}

+ (void)DBDUIThemeCutie:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1068976E8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1068976E8"), strtoul(ENCRYPTHEX("0x0340601E"), nullptr, 0));
    }
}

+ (void)DBDUIThemeWarriorGreen:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1068976DC"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1068976DC"), strtoul(ENCRYPTHEX("0x0804021F"), nullptr, 0));
    }
}

+ (void)DBDUIThemeUltraBlue:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1068976D8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1068976D8"), strtoul(ENCRYPTHEX("0x0201271E"), nullptr, 0));
    }
}



// Quiet Rush Vault
+ (void)quietRushValut:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103D90B40"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103D90B40"), strtoul(ENCRYPTHEX("0xE02FE697"), nullptr, 0));
    }
}

// Max Crouch Speed
+ (void)maxCrouchSpeed:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10370F638"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10370F638"), strtoul(ENCRYPTHEX("0x0028211E"), nullptr, 0));
    }
}

// Balanced Landing
+ (void)balancedLanding:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10371F2DC"), strtoul(ENCRYPTHEX("0x00008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10371F2DC"), strtoul(ENCRYPTHEX("0x0840201E"), nullptr, 0));
    }
}

// Max Beam Flashlight
+ (void)maxBeamFlashlight:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103595F04"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103595F04"), strtoul(ENCRYPTHEX("0x982497FF"), nullptr, 0));
    }
}

// Extra Flashlight
+ (void)extraFlashlight:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103595110"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103595110"), strtoul(ENCRYPTHEX("0xB9080094"), nullptr, 0));
    }
}

// Strong Flashlight
+ (void)strongFlashlight:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x104035B28"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x104035B28"), strtoul(ENCRYPTHEX("0x9780D5C9"), nullptr, 0));
    }
}

// Sniper Flashlight
+ (void)sniperFlashlight:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103594D7C"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103594D7C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Infinite Diversion
+ (void)infiniteDiversion:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BBE80"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BBE80"), strtoul(ENCRYPTHEX("0xFF0302D1FA6703A9"), nullptr, 0));
    }
}

// Anti Pick Up
+ (void)antiPickUp:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103C7D334"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103C7D334"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Anti Trap
+ (void)antiTrap:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103F4325C"), strtoul(ENCRYPTHEX("0x20000052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103F4325C"), strtoul(ENCRYPTHEX("0x68D2E297"), nullptr, 0));
    }
}

// Early Vault Windows
+ (void)earlyValutWindows:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BF4A4"), strtoul(ENCRYPTHEX("0x00000052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BF4A4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fake Vault/Turn Back
+ (void)fakeValutTurnBack:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BF480"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BF480"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Invisible Gen Repair
+ (void)invisibleGenRepair:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BF480"), strtoul(ENCRYPTHEX("0x00F0271E0008201EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BF480"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Action From Any Angle
+ (void)actionFromAnyAngle:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BF480"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BF480"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

#pragma mark - Killer Features Methods

// Max Turn Speed
+ (void)maxTurnSpeed:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1037F6940"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1037F6940"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Extra Bleeding Survivors
+ (void)extraBleedingSurvivors:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10375F46C"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10375F46C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Block Players Move
+ (void)blockPlayersMove:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BBE80"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BBE80"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Mayers Insta Kill
+ (void)mayersInstaKill:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BBE80"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BBE80"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Infinity Phase Walk
+ (void)infinityPhaseWalk:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103C7D59C"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103C7D59C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Back Position (Spirit)
+ (void)backPositionSpirit:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1038803BC"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1038803BC"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Disable Survivor Wiggle
+ (void)disableSurvivorWiggle:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10387F8A8"), strtoul(ENCRYPTHEX("0x00008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10387F8A8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// No Hit Cooldown
+ (void)noHitCooldown:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103BD755C"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103BD755C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// No Speed Cooldown Hit
+ (void)noSpeedCooldownHit:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1037DA74C"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1037DA74C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Infinity Buba Chainsaw
+ (void)infinityBubaChainsaw:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103C7D334"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103C7D334"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Infinity Hit Duration + Auto Hit
+ (void)infinityHitDurationAutoHit:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1038974AC"), strtoul(ENCRYPTHEX("0x00f0271eC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1038974AC"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fast Knife x1
+ (void)fastKnifeX1:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0x0010381EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fast Knife x2
+ (void)fastKnifeX2:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0x0010391EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fast Knife x3
+ (void)fastKnifeX3:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0x00103A1EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fast Knife x4
+ (void)fastKnifeX4:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0x00103B1EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fast Knife x5
+ (void)fastKnifeX5:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0x00103E1EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10387A5E4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

#pragma mark - Skill Checks Methods

// Griefing Mode
+ (void)griefingMode:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xE8031F2A"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B58"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B58"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Griefing SkillChecks
+ (void)grifiernigSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xE8031F2A"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BA8"), strtoul(ENCRYPTHEX("0x00f0271e"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BA8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Griefing Mode (Fake)
+ (void)griefieringModeFake:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1036025B8"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1036025B8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Remote SkillChecks
+ (void)remoteSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103603800"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103603800"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// OG Insta Action
+ (void)ogInstaAction:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10388DFE4"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10388DFE4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// OG SkillChecks
+ (void)ogSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xE8031F2A"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601AB0"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x10388B7E4"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BB4"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BC8"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103602614"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103603A40"), strtoul(ENCRYPTHEX("0x20008052"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601AB0"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x10388B7E4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BB4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BC8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103602614"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103603A40"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// OG Wiggles SkillChecks
+ (void)ogWigglesSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601C54"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601DF8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600A50"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601C54"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601DF8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600A50"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// OG Spam Score
+ (void)ogSpamScore:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BC8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xE8031F2A"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BC8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Full Good SkillChecks
+ (void)fullGoodSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Full Great SkillChecks
+ (void)fullGreatSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Full Wiggle SkillChecks
+ (void)fullWiggleSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601C24"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601C24"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Auto Wiggle SkillChecks
+ (void)autoWiggleSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601CB0"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601CB0"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Auto Good SkillCheck
+ (void)autoGoodSkillCheck:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xE003271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xE003271EC0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BC8"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xE8031F2A"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601B84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BE4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BFC"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103C32794"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601BC8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// No Explode SkillChecks
+ (void)noExplodeSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1036011D8"), strtoul(ENCRYPTHEX("0x00008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1036011D8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// No Fail SkillCheck Hint
+ (void)noFailSkillCheckHint:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103DD4A88"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103DD4A88"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Block SkillCheck Pointer
+ (void)blockSkillCheckPointer:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601AB0"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601AB0"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Continuous SkillChecks
+ (void)continuousSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xE8031F2A"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601A84"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Always SkillChecks Button
+ (void)alwaysSkillChecksButton:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103602614"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103602614"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fail SkillCheck Counted As Good
+ (void)failSkillCheckCountedAsGood:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103600F24"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Fast SkillChecks
+ (void)fastSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10389015C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Hide SkillChecks
+ (void)hideSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103601A3C"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103601A3C"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Better SkillCheck Sound
+ (void)betterSkillCheckSound:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x100B0D824"), strtoul(ENCRYPTHEX("0x00F0271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x100B0D824"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Red SkillChecks
+ (void)redSkillChecks:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103604E74"), strtoul(ENCRYPTHEX("0x00F0271EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103604E74"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

#pragma mark - States Methods

// Killed
+ (void)stateKilled:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10376BF60"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10376BF60"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Injured
+ (void)stateInjured:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10376AE44"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10376AE44"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Crawling
+ (void)stateCrawling:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10370EDC8"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10370EDC8"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Hooked
+ (void)stateHooked:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1037064E4"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1037064E4"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Death Bed
+ (void)stateDeathBed:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10370F138"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10370F138"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Trapped
+ (void)stateTrapped:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10371C240"), strtoul(ENCRYPTHEX("0x20008052C0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10371C240"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Interactions x1.25
+ (void)interactionsX125:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BF844"), strtoul(ENCRYPTHEX("0x00902E1EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BF844"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Interactions x2
+ (void)interactionsX2:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BF844"), strtoul(ENCRYPTHEX("0x0010201EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BF844"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}

// Interactions x3
+ (void)interactionsX3:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x1035BF844"), strtoul(ENCRYPTHEX("0x0010211EC0035FD6"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x1035BF844"), strtoul(ENCRYPTHEX("0xF60302AA"), nullptr, 0));
    }
}






+ (void)HookPurple:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x00102E1EE103271E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)HookCyan:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0xE003271E01102E1E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)HookBlue:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0xE003271EE103271E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)HookYellow:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x00102E1E01102E1EE203271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)HookLightPink:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x00102E1E01102C1E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)HookYellowGold:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x00102E1E01102C1EE203271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)HookOrange:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x00102E1E01102A1EE203271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)HookWhite:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x00102D1E01102D1E02102D1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x10350B820"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorPurple:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x00102E1EE103271E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorCyan:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0xE003271E01102E1E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorBlue:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0xE003271EE103271E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorYellow:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x00102E1E01102E1EE203271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorLightPink:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x00102E1E01102C1E02102E1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorYellowGold:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x00102E1E01102C1EE203271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorOrange:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x00102E1E01102A1EE203271E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}

+ (void)GeneratorWhite:(UISwitch *)SW {
    if ([SW isOn]) {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x00102D1E01102D1E02102D1E"), nullptr, 0));
    } else {
        vm(ENCRYPTOFFSET("0x103506434"), strtoul(ENCRYPTHEX("0x606A41BD616E41BD627241BD"), nullptr, 0));
    }
}


@end





 































