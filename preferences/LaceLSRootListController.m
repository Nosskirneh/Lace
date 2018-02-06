#import "LaceGroupRootListController.h"

@interface LaceLSRootListController : LaceGroupRootListController
@end

@implementation LaceLSRootListController

// Keys
- (NSString *)specifiersPlistFilename {
    return @"LS";
}

- (NSString *)kEnabled {
    return @"enabledLS";
}

- (NSString *)kDefaultSection {
    return @"DefaultSectionLS";
}

- (NSString *)kDefaultSectionEnabled {
    return @"DefaultSectionEnabledLS";
}

- (NSString *)kAutomode {
    return @"AutomodeLS";
}

// Indexpaths
- (NSIndexPath *)automodeIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath *)defaultSectionEnableSwitchIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:2];
}

- (NSIndexPath *)defaultSectionIndexPath {
    return [NSIndexPath indexPathForRow:1 inSection:2];
}

@end
