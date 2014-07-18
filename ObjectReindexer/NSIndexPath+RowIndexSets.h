//
//  NSIndexPath+RowIndexSets.h
//  StoryCollections
//
//  Created by Richard Venable on 5/22/12.
//  Copyright (c) 2012 Epicfox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSIndexPath (RowIndexSets)

+ (NSArray *)indexPathsForRowIndexes:(NSIndexSet *)rowIndexes inSection:(NSUInteger)section;
+ (NSMutableArray *)mutableIndexPathsForRowIndexes:(NSIndexSet *)rowIndexes inSection:(NSUInteger)section;

/**
 Iterates through the given index paths, creating an index set of all the row indexes for index paths with the given section index
 */
+ (NSIndexSet *)rowIndexesForIndexPaths:(NSArray *)indexPaths inSection:(NSUInteger)section;
+ (NSMutableIndexSet *)mutableRowIndexesForIndexPaths:(NSArray *)indexPaths inSection:(NSUInteger)section;

/**
 Iterates through the given index paths, creating an index set of all the row indexes
 */
+ (NSIndexSet *)rowIndexesForIndexPaths:(NSArray *)indexPaths;
+ (NSMutableIndexSet *)mutableRowIndexesForIndexPaths:(NSArray *)indexPaths;

@end
