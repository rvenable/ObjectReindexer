//
//  SCObjectReindexer.h
//  StoryCollections
//
//  Created by Richard Venable on 9/7/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCObjectReindexerDataSource, SCObjectReindexerValueFactory;

/**
 Abstract class for handling object reindexing. It supports sectioned data, so it uses length 2 index paths which have both an item and section index.
 */
@interface SCObjectReindexer : NSObject

@property (nonatomic, weak) id<SCObjectReindexerDataSource> dataSource;
@property (nonatomic, strong) id<SCObjectReindexerValueFactory> valueFactory;
@property (nonatomic) BOOL ascendingItemIndexes;

- (id)initWithValueFactory:(id<SCObjectReindexerValueFactory>)valueFactory ascendingItemIndexes:(BOOL)ascendingItemIndexes;

+ (id)objectReindexerForFlexibleFloatInterval:(double)interval withFirstIndex:(double)firstIndex andAscendingItemIndexes:(BOOL)ascendingItemIndexes;
+ (id)objectReindexerForFixedIntegerInterval:(NSUInteger)interval withFirstIndex:(NSInteger)firstIndex andAscendingItemIndexes:(BOOL)ascendingItemIndexes;

#pragma mark - Indexing for initial object insertion

- (void)indexObject:(id)object asFirstObjectInSection:(NSUInteger)section;
- (void)indexObject:(id)object asLastObjectInSection:(NSUInteger)section;
- (void)indexObject:(id)object insertingAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Reindexing previously inserted objects

- (void)reindexObjectFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

/// Reindexes an object and any associated objects for deletion. This is especially important for reindexers that maintain a fixed interval, since deleting an object may require reindexing other objects in the collection.
- (void)reindexObjectAtIndexPathForDeletion:(NSIndexPath *)indexPath;

#pragma mark - Retrieving Objects at Index Paths

- (id)objectInDataSourceAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)objectsInDataSourceAtIndexPaths:(NSArray *)indexPaths;
//- (id)indexValueOfObject:(id)object expectedClass:(Class)expectedClass;

@end

@protocol SCObjectReindexerDataSource <NSObject>

- (NSArray *)objectReindexer:(SCObjectReindexer *)objectReindexer objectsAtIndexPaths:(NSArray *)indexPaths;
- (NSUInteger)objectReindexer:(SCObjectReindexer *)objectReindexer itemCountForSection:(NSUInteger)section;
- (id)objectReindexer:(SCObjectReindexer *)objectReindexer indexValueForObject:(id)object;
- (void)objectReindexer:(SCObjectReindexer *)objectReindexer setIndexValue:(id)indexValue forObject:(id)object;
- (void)objectReindexer:(SCObjectReindexer *)objectReindexer updateObject:(id)object forSection:(NSUInteger)section;
- (void)objectReindexer:(SCObjectReindexer *)objectReindexer deleteSectionValueForObject:(id)object;

@end

@protocol SCObjectReindexerValueFactory <NSObject>

- (id)objectReindexerOriginalIndexValue:(SCObjectReindexer *)objectReindexer;
- (id)objectReindexer:(SCObjectReindexer *)objectReindexer nextFixedIntervalIndexValueAfterIndexValue:(id)indexValue;
- (id)objectReindexer:(SCObjectReindexer *)objectReindexer previousFixedIntervalIndexValueBeforeIndexValue:(id)indexValue;

@optional

- (id)objectReindexer:(SCObjectReindexer *)objectReindexer flexibleIntervalIndexValueBetweenValue:(id)adjacentValue1 andValue:(id)adjacentValue2;

@end
