//
//  SCFlexibleIntervalReindexer.m
//  StoryCollections
//
//  Created by Richard Venable on 9/16/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import "SCFlexibleIntervalReindexer.h"

@implementation SCFlexibleIntervalReindexer

#pragma mark - SCObjectReindexer

#pragma mark - Indexing for initial object insertion

- (void)indexObject:(id)object asFirstObjectInSection:(NSUInteger)section
{
	NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:section];
	if (itemCount == 0) {
		[self reindexObject:object asOnlyObjectInSection:section];
	}
	else {
		id existingFirstObject = [self objectInDataSourceAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
		[self reindexObject:object beforeFirstObject:existingFirstObject];
	}
}

- (void)indexObject:(id)object asLastObjectInSection:(NSUInteger)section
{
	NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:section];
	if (itemCount == 0) {
		[self reindexObject:object asOnlyObjectInSection:section];
	}
	else {
		id existingLastObject = [self objectInDataSourceAtIndexPath:[NSIndexPath indexPathForItem:itemCount - 1 inSection:section]];
		[self reindexObject:object afterLastObject:existingLastObject];
	}
}

- (void)indexObject:(id)object insertingAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = indexPath.section;

	NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:section];
	if (itemCount == 0) {
		[self reindexObject:object asOnlyObjectInSection:section];
	}
	else if (indexPath.item >= itemCount) {
		id existingLastObject = [self objectInDataSourceAtIndexPath:[NSIndexPath indexPathForItem:itemCount - 1 inSection:section]];
		[self reindexObject:object afterLastObject:existingLastObject];
	}
	else if (indexPath.item == 0) {
		id existingFirstObject = [self objectInDataSourceAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
		[self reindexObject:object beforeFirstObject:existingFirstObject];
	}
	else {
		[self indexObject:object betweenAdjacentIndexPath:[NSIndexPath indexPathForItem:indexPath.item - 1 inSection:section] andAdjacentIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:section]];
	}
}

#pragma mark - Reindexing previously inserted objects

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	NSUInteger destinationSectionItemCount = [self.dataSource objectReindexer:self itemCountForSection:destinationIndexPath.section];

	if (destinationIndexPath.item == 0) {
		[self reindexObjectFromIndexPath:sourceIndexPath beforeFirstObjectInSection:destinationIndexPath.section withItemCount:destinationSectionItemCount];
		return;
	}

	BOOL isMovingToSameSection = (destinationIndexPath.section == sourceIndexPath.section);

	// If we are moving to a different section, we can move to any index from 0 to the next index after the existing (destinationSectionItemCount), but if we are moving within one section the furthest we can move is the last existing index.
	NSUInteger lastValidDestinationIndex = isMovingToSameSection ? destinationSectionItemCount - 1 : destinationSectionItemCount;

	if (destinationIndexPath.item == lastValidDestinationIndex) {
		[self reindexObjectFromIndexPath:sourceIndexPath afterLastObjectInSection:destinationIndexPath.section withItemCount:destinationSectionItemCount];
	}
	else if (destinationIndexPath.item < lastValidDestinationIndex) {
		BOOL isMovingTowardEndInSameSection = (destinationIndexPath.item > sourceIndexPath.item) && (destinationIndexPath.section == sourceIndexPath.section);
		NSIndexPath *adjacentIndexPath1 = destinationIndexPath;
		NSIndexPath *adjacentIndexPath2 = [NSIndexPath indexPathForItem:destinationIndexPath.item + (isMovingTowardEndInSameSection ? 1 : -1) inSection:destinationIndexPath.section];
		[self reindexObjectFromIndexPath:sourceIndexPath betweenAdjacentIndexPath:adjacentIndexPath1 andAdjacentIndexPath:adjacentIndexPath2];
	}
	else {
		@throw [NSException exceptionWithName:NSRangeException reason:@"Destination index path is out of bounds" userInfo:nil];
	}
}

- (void)reindexObjectAtIndexPathForDeletion:(NSIndexPath *)indexPath
{
	id object = [self objectInDataSourceAtIndexPath:indexPath];
	[self.dataSource objectReindexer:self deleteSectionValueForObject:object];
	[self.dataSource objectReindexer:self setIndexValue:nil forObject:object];
}

#pragma mark - Helpers

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath asOnlyObjectInSection:(NSUInteger)section
{
	NSAssert(sourceIndexPath.section != section, @"How could the object become the first object in the section if it is already in the section and therefore the section already has objects? Source Index Path: %@ section: %@", sourceIndexPath, @(section));

	id object = [self objectInDataSourceAtIndexPath:sourceIndexPath];
	[self.dataSource objectReindexer:self updateObject:object forSection:section];

	[self reindexObject:object asOnlyObjectInSection:section];
}

- (void)reindexObject:(id)object asOnlyObjectInSection:(NSUInteger)section
{
	id originalIndexValue = [self.valueFactory objectReindexerOriginalIndexValue:self];
	[self.dataSource objectReindexer:self setIndexValue:originalIndexValue forObject:object];
}

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath betweenAdjacentIndexPath:(NSIndexPath *)adjacentIndexPath1 andAdjacentIndexPath:(NSIndexPath *)adjacentIndexPath2
{
	NSAssert(adjacentIndexPath1.section == adjacentIndexPath2.section, @"Adjacent index paths (%@ and %@) must have the same section", adjacentIndexPath1, adjacentIndexPath2);
	NSAssert(ABS(adjacentIndexPath2.item - adjacentIndexPath1.item) == 1, @"Adjacent index paths (%@ and %@) must have be adjacent to each other", adjacentIndexPath1, adjacentIndexPath2);
	NSAssert(![sourceIndexPath isEqual:adjacentIndexPath1], @"Object that is being reindexed should not be equal to either adjacent object");
	NSAssert(![sourceIndexPath isEqual:adjacentIndexPath2], @"Object that is being reindexed should not be equal to either adjacent object");

	NSArray *objects = [self objectsInDataSourceAtIndexPaths:@[sourceIndexPath, adjacentIndexPath1, adjacentIndexPath2]];

	id object = objects[0];
	id adjacentObject1 = objects[1];
	id adjacentObject2 = objects[2];

	if (sourceIndexPath.section != adjacentIndexPath1.section)
		[self.dataSource objectReindexer:self updateObject:object forSection:adjacentIndexPath1.section];

	[self reindexObject:object betweenAdjacentObject:adjacentObject1 andAdjacentObject:adjacentObject2];
}

- (void)indexObject:(id)object betweenAdjacentIndexPath:(NSIndexPath *)adjacentIndexPath1 andAdjacentIndexPath:(NSIndexPath *)adjacentIndexPath2
{
	NSAssert(adjacentIndexPath1.section == adjacentIndexPath2.section, @"Adjacent index paths (%@ and %@) must have the same section", adjacentIndexPath1, adjacentIndexPath2);
	NSAssert(ABS(adjacentIndexPath2.item - adjacentIndexPath1.item) == 1, @"Adjacent index paths (%@ and %@) must have be adjacent to each other", adjacentIndexPath1, adjacentIndexPath2);

	NSArray *objects = [self objectsInDataSourceAtIndexPaths:@[adjacentIndexPath1, adjacentIndexPath2]];

	id adjacentObject1 = objects[0];
	id adjacentObject2 = objects[1];

	[self reindexObject:object betweenAdjacentObject:adjacentObject1 andAdjacentObject:adjacentObject2];
}

- (void)reindexObject:(id)object betweenAdjacentObject:(id)adjacentObject1 andAdjacentObject:(id)adjacentObject2
{
	NSAssert(![object isEqual:adjacentObject1], @"Object that is being reindexed should not be equal to either adjacent object");
	NSAssert(![object isEqual:adjacentObject2], @"Object that is being reindexed should not be equal to either adjacent object");

	id adjacentIndexValue1 = [self.dataSource objectReindexer:self indexValueForObject:adjacentObject1];
	id adjacentIndexValue2 = [self.dataSource objectReindexer:self indexValueForObject:adjacentObject2];

	id newIndexValue = [self.valueFactory objectReindexer:self flexibleIntervalIndexValueBetweenValue:adjacentIndexValue1 andValue:adjacentIndexValue2];

	[self.dataSource objectReindexer:self setIndexValue:newIndexValue forObject:object];
}

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath beforeFirstObjectInSection:(NSUInteger)destinationSection withItemCount:(NSUInteger)sectionItemCount
{
	if (sectionItemCount == 0) {
		[self reindexObjectFromIndexPath:sourceIndexPath asOnlyObjectInSection:destinationSection];
		return;
	}

	NSArray *objects = [self objectsInDataSourceAtIndexPaths:@[sourceIndexPath, [NSIndexPath indexPathForItem:0 inSection:destinationSection]]];
	id object = objects[0];
	id existingFirstObject = objects[1];

	if (sourceIndexPath.section != destinationSection)
		[self.dataSource objectReindexer:self updateObject:object forSection:destinationSection];

	[self reindexObject:object beforeFirstObject:existingFirstObject];
}

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath afterLastObjectInSection:(NSUInteger)destinationSection withItemCount:(NSUInteger)sectionItemCount
{
	if (sectionItemCount == 0) {
		[self reindexObjectFromIndexPath:sourceIndexPath asOnlyObjectInSection:destinationSection];
		return;
	}

	NSArray *objects = [self objectsInDataSourceAtIndexPaths:@[sourceIndexPath, [NSIndexPath indexPathForItem:sectionItemCount - 1 inSection:destinationSection]]];
	id object = objects[0];
	id existingLastObject = objects[1];

	if (sourceIndexPath.section != destinationSection)
		[self.dataSource objectReindexer:self updateObject:object forSection:destinationSection];

	[self reindexObject:object afterLastObject:existingLastObject];
}

- (void)reindexObject:(id)object beforeFirstObject:(id)existingFirstObject
{
	id indexValue = [self.dataSource objectReindexer:self indexValueForObject:existingFirstObject];
	if (self.ascendingItemIndexes) {
		// If the item indexes are ascending, then to be the first object, we have to be less than the existing first object, so subtract the interval from the existing first object index to get one that is less
		indexValue = [self.valueFactory objectReindexer:self previousFixedIntervalIndexValueBeforeIndexValue:indexValue];
	}
	else {
		// If the item indexes are descending, then to be the first object, we have to be greater than the existing first object, so add the interval to the existing first object index to get one that is greater
		indexValue = [self.valueFactory objectReindexer:self nextFixedIntervalIndexValueAfterIndexValue:indexValue];
	}

	[self.dataSource objectReindexer:self setIndexValue:indexValue forObject:object];
}

- (void)reindexObject:(id)object afterLastObject:(id)existingLastObject
{
	id indexValue = [self.dataSource objectReindexer:self indexValueForObject:existingLastObject];
	if (self.ascendingItemIndexes) {
		// If the item indexes are ascending, then to be the last object, we have to be greater than the existing last object, so add the interval to the existing last object index to get one that is greater
		indexValue = [self.valueFactory objectReindexer:self nextFixedIntervalIndexValueAfterIndexValue:indexValue];
	}
	else {
		// If the item indexes are descending, then to be the last object, we have to be less than the existing last object, so subtract the interval from the existing last object index to get one that is less
		indexValue = [self.valueFactory objectReindexer:self previousFixedIntervalIndexValueBeforeIndexValue:indexValue];
	}

	[self.dataSource objectReindexer:self setIndexValue:indexValue forObject:object];
}

@end
