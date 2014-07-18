//
//  SCFixedIntervalReindexer.m
//  StoryCollections
//
//  Created by Richard Venable on 9/9/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import "SCFixedIntervalReindexer.h"
#import "NSIndexPath+RowIndexSets.h"

@implementation SCFixedIntervalReindexer

#pragma mark - SCObjectReindexer

#pragma mark - Indexing for initial object insertion

- (void)indexObject:(id)object asFirstObjectInSection:(NSUInteger)section
{
	NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:section];
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];

	[self indexObject:object insertingAtIndexPath:indexPath withSectionItemCount:itemCount];
}

- (void)indexObject:(id)object asLastObjectInSection:(NSUInteger)section
{
	NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:section];
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemCount inSection:section];

	[self indexObject:object insertingAtIndexPath:indexPath withSectionItemCount:itemCount];
}

- (void)indexObject:(id)object insertingAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = indexPath.section;
	NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:section];
	[self indexObject:object insertingAtIndexPath:indexPath withSectionItemCount:itemCount];
}

- (void)indexObject:(id)object insertingAtIndexPath:(NSIndexPath *)indexPath withSectionItemCount:(NSUInteger)itemCount
{
	// First get the index value from the existing object
	id indexValue = [self indexValueForIndexPath:indexPath withSectionItemCount:itemCount];

	// Then we can reindex the existing object (and any other collateral objects)
	[self reindexCollateralObjectsForAddingItemToSectionAtIndexPath:indexPath];

	// Finally update the target object
	[self.dataSource objectReindexer:self setIndexValue:indexValue forObject:object];
}

#pragma mark - Reindexing previously inserted objects

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	// Strategy: get any needed info from existing collateral objects, then move the collateral objects, then move the target object (using initial gathered info)

	NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:destinationIndexPath.section];
	id indexValue = [self indexValueForIndexPath:destinationIndexPath withSectionItemCount:itemCount];

	[self reindexCollateralObjectsForMovingObjectFromIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];

	id object = [self objectInDataSourceAtIndexPath:sourceIndexPath];

	if (sourceIndexPath.section != destinationIndexPath.section)
		[self.dataSource objectReindexer:self updateObject:object forSection:destinationIndexPath.section];

	[self.dataSource objectReindexer:self setIndexValue:indexValue forObject:object];
}

- (void)reindexObjectAtIndexPathForDeletion:(NSIndexPath *)indexPath
{
	id object = [self objectInDataSourceAtIndexPath:indexPath];
	[self.dataSource objectReindexer:self deleteSectionValueForObject:object];
	[self.dataSource objectReindexer:self setIndexValue:nil forObject:object];
	[self reindexCollateralObjectsForRemovingItemFromSectionAtIndexPath:indexPath];
}

#pragma mark - Helpers for adjusting the target object (not collateral objects)

- (id)indexValueForIndexPath:(NSIndexPath *)destinationIndexPath withSectionItemCount:(NSUInteger)sectionItemCount
{
	NSAssert(destinationIndexPath.item <= sectionItemCount, @"Index path out of range");

	if (destinationIndexPath.item == sectionItemCount) {
		if (sectionItemCount == 0)
			return [self.valueFactory objectReindexerOriginalIndexValue:self];

		id indexValue = [self indexValueForIndexPath:[NSIndexPath indexPathForItem:destinationIndexPath.item - 1 inSection:destinationIndexPath.section] withSectionItemCount:sectionItemCount];

		indexValue = [self.valueFactory objectReindexer:self nextFixedIntervalIndexValueAfterIndexValue:indexValue];
		return indexValue;
	}

	id existingObject = [self objectInDataSourceAtIndexPath:destinationIndexPath];
	NSParameterAssert(existingObject);

	id indexValue = [self.dataSource objectReindexer:self indexValueForObject:existingObject];
	NSParameterAssert(indexValue);

	return indexValue;
}

#pragma mark - Collateral Objects

- (void)reindexCollateralObjectsForMovingObjectFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	if (sourceIndexPath.section == destinationIndexPath.section) {
		[self reindexCollateralObjectsForMovingObjectFromItemIndex:sourceIndexPath.item toItemIndex:destinationIndexPath.item inSection:sourceIndexPath.section];
	}
	else {
		[self reindexCollateralObjectsForRemovingItemFromSectionAtIndexPath:sourceIndexPath];
		[self reindexCollateralObjectsForAddingItemToSectionAtIndexPath:destinationIndexPath];
	}
}

- (void)reindexCollateralObjectsForAddingItemToSectionAtIndexPath:(NSIndexPath *)indexPath
{
	NSRange collateralRange = [self collateralRangeForAddingOrRemovingItemFromSectionAtIndexPath:indexPath];
	[self reindexByAddingIntervalValueToCollateralObjectsInItemRange:collateralRange ofSection:indexPath.section];
}

- (void)reindexCollateralObjectsForRemovingItemFromSectionAtIndexPath:(NSIndexPath *)indexPath
{
	NSRange collateralRange = [self collateralRangeForAddingOrRemovingItemFromSectionAtIndexPath:indexPath];
	[self reindexBySubtractingIntervalValueFromCollateralObjectsInItemRange:collateralRange ofSection:indexPath.section];
}

- (NSRange)collateralRangeForAddingOrRemovingItemFromSectionAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.ascendingItemIndexes) {
		// If the item indexes are ascending, then all of the indexes from the target index to the last index are collaterally affected
		NSUInteger itemCount = [self.dataSource objectReindexer:self itemCountForSection:indexPath.section];
		return NSMakeRange(indexPath.item, itemCount - indexPath.item);
	}
	else {
		// If the item indexes are ascending, then all of the indexes from the first index to the target index are collaterally affected
		return NSMakeRange(0, indexPath.item);
	}
}

- (void)reindexCollateralObjectsForMovingObjectFromItemIndex:(NSInteger)sourceItemIndex toItemIndex:(NSInteger)destinationItemIndex inSection:(NSUInteger)section
{
	if (sourceItemIndex == destinationItemIndex)
		return;

	if (sourceItemIndex < destinationItemIndex) {
		NSRange collateralRange = NSMakeRange(sourceItemIndex + 1, destinationItemIndex - sourceItemIndex);

		// If the target object is moving toward the end, the collateral object move toward the beginning
		[self reindexByMovingObjectsInItemRange:collateralRange towardBeginningOfSection:section];
	}
	else {
		NSRange collateralRange = NSMakeRange(destinationItemIndex, sourceItemIndex - destinationItemIndex);

		// If the target object is moving toward the beginning, the collateral object move toward the end
		[self reindexByMovingObjectsInItemRange:collateralRange towardEndOfSection:section];
	}
}

- (void)reindexByMovingObjectsInItemRange:(NSRange)itemRange towardBeginningOfSection:(NSUInteger)section
{
	if (self.ascendingItemIndexes) {
		[self reindexBySubtractingIntervalValueFromCollateralObjectsInItemRange:itemRange ofSection:section];
	}
	else {
		[self reindexByAddingIntervalValueToCollateralObjectsInItemRange:itemRange ofSection:section];
	}
}

- (void)reindexByMovingObjectsInItemRange:(NSRange)itemRange towardEndOfSection:(NSUInteger)section
{
	if (self.ascendingItemIndexes) {
		[self reindexByAddingIntervalValueToCollateralObjectsInItemRange:itemRange ofSection:section];
	}
	else {
		[self reindexBySubtractingIntervalValueFromCollateralObjectsInItemRange:itemRange ofSection:section];
	}
}

- (void)reindexByAddingIntervalValueToCollateralObjectsInItemRange:(NSRange)collateralItemRange ofSection:(NSUInteger)section
{
	[self enumerateObjectsInItemRange:collateralItemRange ofSection:section usingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		id index = [self.dataSource objectReindexer:self indexValueForObject:object];
		index = [self.valueFactory objectReindexer:self nextFixedIntervalIndexValueAfterIndexValue:index];
		[self.dataSource objectReindexer:self setIndexValue:index forObject:object];
	}];
}

- (void)reindexBySubtractingIntervalValueFromCollateralObjectsInItemRange:(NSRange)collateralItemRange ofSection:(NSUInteger)section
{
	[self enumerateObjectsInItemRange:collateralItemRange ofSection:section usingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		id index = [self.dataSource objectReindexer:self indexValueForObject:object];
		index = [self.valueFactory objectReindexer:self previousFixedIntervalIndexValueBeforeIndexValue:index];
		[self.dataSource objectReindexer:self setIndexValue:index forObject:object];
	}];
}

- (void)enumerateObjectsInItemRange:(NSRange)itemRange ofSection:(NSUInteger)section usingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block
{
	if (itemRange.length <= 0)
		return;

	NSArray *indexPaths = [NSIndexPath indexPathsForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:itemRange] inSection:section];
	NSArray *objects = [self objectsInDataSourceAtIndexPaths:indexPaths];

	[objects enumerateObjectsUsingBlock:block];
}

@end
