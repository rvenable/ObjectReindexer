//
//  SCFloatingReindexerValueFactory.m
//  StoryCollections
//
//  Created by Richard Venable on 9/16/13.
//  Copyright (c) 2013 Epicfox. All rights reserved.
//

#import "SCFloatingReindexerValueFactory.h"

@implementation SCFloatingReindexerValueFactory

- (id)initWithFirstIndex:(double)firstIndex initialInterval:(double)initialInterval
{
	self = [super init];
	if (self) {
		_firstIndex = firstIndex;
		_initialInterval = initialInterval;
	}
	return self;
}

- (id)objectReindexerOriginalIndexValue:(SCObjectReindexer *)objectReindexer
{
	return [NSNumber numberWithDouble:self.firstIndex];
}

- (id)objectReindexer:(SCObjectReindexer *)objectReindexer nextFixedIntervalIndexValueAfterIndexValue:(NSNumber *)indexValue
{
	indexValue = [NSNumber numberWithDouble:indexValue.doubleValue + self.initialInterval];
	return indexValue;
}

- (id)objectReindexer:(SCObjectReindexer *)objectReindexer previousFixedIntervalIndexValueBeforeIndexValue:(NSNumber *)indexValue
{
	indexValue = [NSNumber numberWithDouble:indexValue.doubleValue - self.initialInterval];
	return indexValue;
}

- (id)objectReindexer:(SCObjectReindexer *)objectReindexer flexibleIntervalIndexValueBetweenValue:(NSNumber *)adjacentValue1 andValue:(NSNumber *)adjacentValue2
{
	NSNumber *newIndex = [NSNumber numberWithDouble:(adjacentValue1.doubleValue + adjacentValue2.doubleValue) / 2.0];
	return newIndex;
}

@end
