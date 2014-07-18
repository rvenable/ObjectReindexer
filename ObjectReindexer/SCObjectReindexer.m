//
//  SCObjectReindexer.m
//  StoryCollections
//
//  Created by Richard Venable on 9/7/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import "SCObjectReindexer.h"

#import "SCFlexibleIntervalReindexer.h"
#import "SCFixedIntervalReindexer.h"

#import "SCFloatingReindexerValueFactory.h"
#import "SCIntegerReindexerValueFactory.h"

@implementation SCObjectReindexer

- (id)initWithValueFactory:(id<SCObjectReindexerValueFactory>)valueFactory ascendingItemIndexes:(BOOL)ascendingItemIndexes
{
	NSParameterAssert(valueFactory);

	self = [super init];
	if (self) {
		_valueFactory = valueFactory;
		_ascendingItemIndexes = ascendingItemIndexes;
	}
	return self;
}

+ (id)objectReindexerForFlexibleFloatInterval:(double)interval withFirstIndex:(double)firstIndex andAscendingItemIndexes:(BOOL)ascendingItemIndexes
{
	SCFloatingReindexerValueFactory *delegate = [[SCFloatingReindexerValueFactory alloc] initWithFirstIndex:firstIndex initialInterval:interval];

	return [[SCFlexibleIntervalReindexer alloc] initWithValueFactory:delegate ascendingItemIndexes:ascendingItemIndexes];
}

+ (id)objectReindexerForFixedIntegerInterval:(NSUInteger)interval withFirstIndex:(NSInteger)firstIndex andAscendingItemIndexes:(BOOL)ascendingItemIndexes
{
	SCIntegerReindexerValueFactory *delegate = [[SCIntegerReindexerValueFactory alloc] initWithFirstIndex:firstIndex interval:interval];

	return [[SCFixedIntervalReindexer alloc] initWithValueFactory:delegate ascendingItemIndexes:ascendingItemIndexes];
}

#pragma mark - Indexing for initial object insertion

- (void)indexObject:(id)object asFirstObjectInSection:(NSUInteger)section
{
	[self doesNotRecognizeSelector:_cmd];
}

- (void)indexObject:(id)object asLastObjectInSection:(NSUInteger)section
{
	[self doesNotRecognizeSelector:_cmd];
}

- (void)indexObject:(id)object insertingAtIndexPath:(NSIndexPath *)indexPath
{
	[self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Reindexing previously inserted objects

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	// Subclasses must override
	[self doesNotRecognizeSelector:_cmd];
}

- (void)reindexObjectAtIndexPathForDeletion:(NSIndexPath *)indexPath
{
	[self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Retrieving Objects at Index Paths

- (id)objectInDataSourceAtIndexPath:(NSIndexPath *)indexPath
{
	if (!indexPath)
		return nil;

	NSArray *objects = [self objectsInDataSourceAtIndexPaths:@[indexPath]];
	return objects.lastObject;
}

- (NSArray *)objectsInDataSourceAtIndexPaths:(NSArray *)indexPaths
{
	if (!indexPaths)
		return nil;
	if (!indexPaths.count)
		return @[];

	NSArray *objects = [self.dataSource objectReindexer:self objectsAtIndexPaths:indexPaths];
	NSAssert(objects.count == indexPaths.count, @"Data source must return the same number of objects as the number of index paths that were requested.\nIndex Paths requested: %@\nObjects returned: %@", indexPaths, objects);
	return objects;
}

- (id)indexValueOfObject:(id)object expectedClass:(Class)expectedClass
{
	id indexValue = [self.dataSource objectReindexer:self indexValueForObject:object];
	if (![indexValue isKindOfClass:expectedClass])
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Expected index value of object to be of class %@ but found class %@. Object %@", NSStringFromClass(expectedClass), NSStringFromClass([indexValue class]), object] userInfo:nil];
	return indexValue;
}

@end
