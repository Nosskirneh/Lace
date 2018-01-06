#import <Preferences/PSControlTableCell.h>
#import <Preferences/PSSpecifier.h>
#import "LaceGroupRootListController.h"

#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"se.nosskirneh.lace.plist"]
#define LaceColor [UIColor colorWithRed:0.73 green:0.06 blue:0.58 alpha:1.0]

@implementation LaceGroupRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:[self specifiersPlistFilename] target:self] retain];
    }

    return _specifiers;
}

- (NSString *)specifiersPlistFilename {
    return nil;
}

- (NSString *)kEnabled {
    return nil;
}

- (NSString *)kDefaultSection {
    return nil;
}

- (NSString *)kCustomChevronIconEnabled {
    return nil;
}

- (NSString *)kDefaultSectionEnabled {
    return nil;
}

- (NSString *)kAutomode {
    return nil;
}

// Indexpaths
- (NSIndexPath *)hideSearchBarIndexPath {
    return nil;
}

- (NSIndexPath *)changeWhileDraggingIndexPath {
    return nil;
}

- (NSIndexPath *)automodeIndexPath {
    return nil;
}

- (NSIndexPath *)defaultSectionEnableSwitchIndexPath {
    return nil;
}

- (NSIndexPath *)defaultSectionIndexPath {
    return nil;
}

- (NSIndexPath *)chevronEnableSwitchIndexPath {
    return nil;
}

- (NSIndexPath *)chevronIndexPath {
    return nil;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = LaceColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Restore tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = nil;
}

- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {
    if (!indexPath) {
        return;
    }

    UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        
        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control) {
                controlCell.control.enabled = enabled;
            }
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:prefPath];

    NSString *key = [specifier propertyForKey:@"key"];
    BOOL enableCell = [preferences[key] boolValue];

    if ([key isEqualToString:[self kEnabled]]) {
        enableCell = preferences[key] ? enableCell : YES;
        // Hide Search Bar
        [self setCellForRowAtIndexPath:[self hideSearchBarIndexPath] enabled:enableCell];

        // Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:enableCell];

        // Automode
        [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:enableCell];

        // Default Section
        [self setCellForRowAtIndexPath:[self defaultSectionEnableSwitchIndexPath] enabled:enableCell];

        // Only reenable DefaultSection cell if DefaultSectionEnabled is enabled
        if (![preferences[[self kDefaultSectionEnabled]] boolValue]) {
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:enableCell];
        }

        // Chevron
        [self setCellForRowAtIndexPath:[self chevronEnableSwitchIndexPath] enabled:enableCell];

        // Only reenable Chevron cell if CustomChevronIconEnabled is enabled
        if (![preferences[[self kCustomChevronIconEnabled]] boolValue]) {
            [self setCellForRowAtIndexPath:[self chevronIndexPath] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[self chevronIndexPath] enabled:enableCell];
        }

    } else if (!preferences[[self kEnabled]] || [preferences[[self kEnabled]] boolValue]) {
        if ([key isEqualToString:[self kAutomode]]) {
            if ([preferences[[self kDefaultSectionEnabled]] boolValue]) {
                [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:NO];
            } else {
                [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:!enableCell];   
            }

        } else if ([key isEqualToString:[self kDefaultSectionEnabled]]) {
            // Disable Change While Dragging
            [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:!enableCell];
            // Disable Automode
            [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:!enableCell];
            // Enable DefaultSection cell
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:enableCell];

        } else if ([key isEqualToString:[self kCustomChevronIconEnabled]]) {
            // Enable Chevron icon cell
            [self setCellForRowAtIndexPath:[self chevronIndexPath] enabled:enableCell];
        }
    }

    if (!preferences[key]) {
        return specifier.properties[@"default"];
    }
    return preferences[key];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    NSString *key = [specifier propertyForKey:@"key"];

    [preferences setObject:value forKey:key];
    [preferences writeToFile:prefPath atomically:YES];

    if ([key isEqualToString:[self kEnabled]]) {
        // Hide Search Bar
        [self setCellForRowAtIndexPath:[self hideSearchBarIndexPath] enabled:[value boolValue]];

        // Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:[value boolValue]];

        // Automode
        [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:[value boolValue]];

        // Default Section enable
        [self setCellForRowAtIndexPath:[self defaultSectionEnableSwitchIndexPath] enabled:[value boolValue]];

        // Only reenable Section cell if DefaultSectionEnabled is enabled
        if (![preferences[[self kDefaultSectionEnabled]] boolValue]) {
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:[value boolValue]];
        }

        // Chevron enable
        [self setCellForRowAtIndexPath:[self chevronEnableSwitchIndexPath] enabled:[value boolValue]];

        // Only reenable Chevron cell if CustomChevronIconEnabled is enabled
        if (![preferences[[self kCustomChevronIconEnabled]] boolValue]) {
            [self setCellForRowAtIndexPath:[self chevronIndexPath] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[self chevronIndexPath] enabled:[value boolValue]];
        }
    } else if ([key isEqualToString:[self kAutomode]]) {
        // Disable Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:![value boolValue]];

    } else if ([key isEqualToString:[self kDefaultSectionEnabled]]) {
        // Disable Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:![value boolValue]];
        // Disable Automode
        [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:![value boolValue]];
        // Enable DefaultSection cell
        [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:[value boolValue]];
        
    } else if ([key isEqualToString:[self kCustomChevronIconEnabled]]) {
        // Enable Chevron icon cell
        [self setCellForRowAtIndexPath:[self chevronIndexPath] enabled:[value boolValue]];
    }

    [preferences writeToFile:prefPath atomically:YES];

    CFStringRef post = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
}

@end
