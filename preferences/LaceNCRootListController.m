#import "LaceGroupRootListController.h"

@interface LaceNCRootListController : LaceGroupRootListController
@end

@implementation LaceNCRootListController

// Keys
- (NSString *)specifiersPlistFilename {
    return @"NC";
}

- (NSString *)kEnabled {
    return @"enabled";
}

- (NSString *)kDefaultSection {
    return @"DefaultSection";
}

- (NSString *)kDefaultSectionEnabled {
    return @"DefaultSectionEnabled";
}

- (NSString *)kCustomChevronIconEnabled {
    return @"CustomChevronIconEnabled";
}

- (NSString *)kAutomode {
    return @"Automode";
}

// Indexpaths
- (NSIndexPath *)hideSearchBarIndexPath {
    return [NSIndexPath indexPathForRow:1 inSection:0];
}

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

- (NSIndexPath *)chevronEnableSwitchIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:4];
}

- (NSIndexPath *)chevronIndexPath {
    return [NSIndexPath indexPathForRow:1 inSection:4];
}

@end
