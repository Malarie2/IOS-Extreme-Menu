#import <Foundation/Foundation.h>

@interface CharacterManager : NSObject
+ (void)changeKillerCharacter:(int)characterId;

+ (void)changeCharacter:(int)characterId;
+ (void)resetCharacter;

@end 