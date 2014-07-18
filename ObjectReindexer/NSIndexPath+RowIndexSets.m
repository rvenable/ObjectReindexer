//
//  NSIndexPath+RowIndexSets.m
//  StoryCollections
//
//  Created by Richard Venable on 5/22/12.
//  Copyright (c) 2012 Epicfox. All rights reserved.
//

#import "NSIndexPath+RowIndexSets.h"

@implementation NSIndexPath (RowIndexSets)

+ (NSArray *)indexPathsForRowIndexes:(NSIndexSet *)rowIndexes inSection:(NSUInteger)section
{
	return [NSArray arrayWithArray:[self mutableIndexPathsForRowIndexes:rowIndexes inSection:section]];
}

+ (NSMutableArray *)mutableIndexPathsForRowIndexes:(NSIndexSet *)rowIndexes inSection:(NSUInteger)section
{
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	[rowIndexes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop) {
		[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
	}];
	return indexPaths;
}

+ (NSIndexSet *)rowIndexesForIndexPaths:(NSArray *)indexPaths inSection:(NSUInteger)section
{
	NSMutableIndexSet *rowIndexes = [self mutableRowIndexesForIndexPaths:indexPaths inSection:section];
	return [[NSIndexSet alloc] initWithIndexSet:rowIndexes];
}

+ (NSMutableIndexSet *)mutableRowIndexesForIndexPaths:(NSArray *)indexPaths inSection:(NSUInteger)section
{
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	[indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger index, BOOL *stop) {
		if (section == indexPath.section) {
			[indexSet addIndex:indexPath.row];
		}
	}];
	return indexSet;
}

+ (NSIndexSet *)rowIndexesForIndexPaths:(NSArray *)indexPaths
{
	NSMutableIndexSet *rowIndexes = [self mutableRowIndexesForIndexPaths:indexPaths];
	return [[NSIndexSet alloc] initWithIndexSet:rowIndexes];
}

+ (NSMutableIndexSet *)mutableRowIndexesForIndexPaths:(NSArray *)indexPaths
{
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	[indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger index, BOOL *stop) {
		[indexSet addIndex:indexPath.row];
	}];
	return indexSet;
}

@end
