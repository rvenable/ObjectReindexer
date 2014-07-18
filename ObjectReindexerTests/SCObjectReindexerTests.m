//
//  SCObjectReindexerTests.m
//  StoryCollections
//
//  Created by Richard Venable on 9/7/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SCObjectReindexer.h"

@interface SCObjectReindexerTests : XCTestCase// <SCObjectReindexerDelegate>

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSArray *originalSectionedObjects;
@property (nonatomic, strong) SCObjectReindexer *itemReindexer;

@end

@implementation SCObjectReindexerTests

/*
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	self.objects = [self mutableObjectsWithNumSections:3 numRowsPerSection:10];
	self.originalSectionedObjects = [self sectionedAndSortedObjects:objects];
	self.itemReindexer = [[SCObjectReindexer alloc] init];
	self.itemReindexer.dataSource = self;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSArray *)objectReindexer:(SCObjectReindexer *)objectReindexer objectsAtIndexPaths:(NSArray *)indexPaths
{
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:indexPaths.count];
	[indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
		id object = self.originalSectionedObjects[indexPath.section][indexPath.item];
		[objects addObject:object];
	}];
	return objects;
}

- (NSArray *)sectionedAndSortedObjects:(NSArray *)objects
{
	NSArray *sortedObjects = [objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"section" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES]]];

	NSMutableArray *sectionedObjects = [NSMutableArray arrayWithCapacity:sortedObjects.count];
	id currentSection = nil;
	__block NSMutableArray *currentSectionObjects = [NSMutableArray arrayWithCapacity:sortedObjects.count];

	[sortedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id section = [obj valueForKey:@"section"];

		if (!currentSection)
			currentSection = section;

		if (currentSection != section) {
			[sectionedObjects addObject:[currentSectionObjects copy]];

			currentSection = section;
			currentSectionObjects = [NSMutableArray arrayWithCapacity:sortedObjects.count];
		}

		[currentSectionObjects addObject:obj];
	}];
	[sectionedObjects addObject:[currentSectionObjects copy]];

	return [sectionedObjects copy];
}

- (NSMutableArray *)mutableObjectsWithNumSections:(NSUInteger)numSections numRowsPerSection:(NSUInteger)numRowsPerSection
{
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:10];
	for (NSUInteger section = 0; section < numSections; section++) {
		for (NSUInteger row = 0; row < numRowsPerSection; row++) {
			NSDictionary *object = @{
									 @"section": [NSNumber numberWithUnsignedInteger:section],
									 @"row" : [NSNumber numberWithUnsignedInteger:row],
									 };
			[objects addObject:[NSMutableDictionary dictionaryWithDictionary:object]];
		}
	}
}

- (void)moveSourceIndexPath:(NSIndexPath *)sourceIndexPath toDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
	// Move

	// Verify
	NSArray *alteredSectionedObjects = [self sectionedAndSortedObjects:self.objects];
	XCTAssertEqualObjects(alteredSectionedObjects, self.originalSectionedObjects, @"Move from %@ to %@ failed with original %@ and altered %@", sourceIndexPath, destinationIndexPath, self.originalSectionedObjects, alteredSectionedObjects);
}

- (void)testShouldMoveItemUpInSameSection
{
	// Move from bottom / Move from top
	// Move to bottom / Move to top
	// Move to different section
	// moving row, collateral rows (destination to source)


	// Move up / Move down
	[self moveSourceIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] toDestinationIndexPath:[NSIndexPath indexPathForItem:4 inSection:0]];
	[self moveSourceIndexPath:[NSIndexPath indexPathForItem:4 inSection:0] toDestinationIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];

	NSIndexPath *firstIndexPath

    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
 */

@end
