#import "LaceGroupRootListController.h"

@interface LaceCCRootListController : LaceGroupRootListController
@end

@implementation LaceCCRootListController

// Keys
- (NSString *)specifiersPlistFilename {
    return @"CC";
}

- (NSString *)kEnabled {
    return @"enabledCC";
}

- (NSString *)kDefaultSection {
    return @"DefaultSectionCC";
}

- (NSString *)kDefaultSectionEnabled {
    return @"DefaultSectionEnabledCC";
}

- (NSString *)kAutomode {
    return @"AutomodeCC";
}

// Indexpaths
- (NSIndexPath *)changeWhileDraggingIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath *)automodeIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:2];
}

- (NSIndexPath *)defaultSectionEnableSwitchIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:3];
}

- (NSIndexPath *)defaultSectionIndexPath {
    return [NSIndexPath indexPathForRow:1 inSection:3];
}

@end
