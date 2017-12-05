//
//  MGTemplateEngine.m
//
//  Created by Matt Gemmell on 11/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import "MGTemplateEngine.h"
#import "MGTemplateStandardMarkers.h"
#import "MGTemplateStandardFilters.h"
#import "DeepMutableCopy.h"


#define DEFAULT_MARKER_START		@"{%"
#define DEFAULT_MARKER_END			@"%}"
#define DEFAULT_EXPRESSION_START	@"{{"	// should always be different from marker-start
#define DEFAULT_EXPRESSION_END		@"}}"
#define DEFAULT_FILTER_START		@"|"
#define DEFAULT_LITERAL_START		@"literal"
#define DEFAULT_LITERAL_END			@"/literal"
// example:	{% markername arg1 arg2|filter:arg1 arg2 %}

#define GLOBAL_ENGINE_GROUP			@"engine"		// name of dictionary in globals containing engine settings
#define GLOBAL_ENGINE_DELIMITERS	@"delimiters"	// name of dictionary in GLOBAL_ENGINE_GROUP containing delimiters
#define GLOBAL_DELIM_MARKER_START	@"markerStart"	// name of key in GLOBAL_ENGINE_DELIMITERS containing marker start delimiter
#define GLOBAL_DELIM_MARKER_END		@"markerEnd"
#define GLOBAL_DELIM_EXPR_START		@"expressionStart"
#define GLOBAL_DELIM_EXPR_END		@"expressionEnd"
#define GLOBAL_DELIM_FILTER			@"filter"

@interface MGTemplateEngine (PrivateMethods)

- (NSObject *)valueForVariable:(NSString *)var parent:(NSObject **)parent parentKey:(NSString **)parentKey;
- (void)setValue:(NSObject *)newValue forVariable:(NSString *)var forceCurrentStackFrame:(BOOL)inStackFrame;
- (void)reportError:(NSString *)errorStr code:(int)code continuing:(BOOL)continuing;
- (void)reportBlockBoundaryStarted:(BOOL)started;
- (void)reportTemplateProcessingFinished;

@end


@implementation MGTemplateEngine


#pragma mark Creation and destruction


+ (NSString *)version
{
	// 1.0.0	20 May 2008
	return @"1.0.0";
}


+ (MGTemplateEngine *)templateEngine
{
	return [[MGTemplateEngine alloc] init];
}


- (id)init
{
	if (self = [super init]) {
		_openBlocksStack = [[NSMutableArray alloc] init];
		_globals = [[NSMutableDictionary alloc] init];
		_markers = [[NSMutableDictionary alloc] init];
		_filters = [[NSMutableDictionary alloc] init];
		_templateVariables = [[NSMutableDictionary alloc] init];
		_outputDisabledCount = 0; // i.e. not disabled.
		self.markerStartDelimiter = DEFAULT_MARKER_START;
		self.markerEndDelimiter = DEFAULT_MARKER_END;
		self.expressionStartDelimiter = DEFAULT_EXPRESSION_START;
		self.expressionEndDelimiter = DEFAULT_EXPRESSION_END;
		self.filterDelimiter = DEFAULT_FILTER_START;
		self.literalStartMarker = DEFAULT_LITERAL_START;
		self.literalEndMarker = DEFAULT_LITERAL_END;
		
		// Load standard markers and filters.
		[self loadMarker:[[MGTemplateStandardMarkers alloc] initWithTemplateEngine:self]];
		[self loadFilter:[[MGTemplateStandardFilters alloc] init]];
	}
	
	return self;
}
 


#pragma mark Managing persistent values.


- (void)setObject:(id)anObject forKey:(id)aKey
{
	[_globals setObject:anObject forKey:aKey];
}


- (void)addEntriesFromDictionary:(NSDictionary *)dict
{
	[_globals addEntriesFromDictionary:dict];
}


- (id)objectForKey:(id)aKey
{
	return [_globals objectForKey:aKey];
}


#pragma mark Configuration and extensibility.


- (void)loadMarker:(NSObject <MGTemplateMarker> *)marker
{
	if (marker) {
		// Obtain claimed markers.
		NSArray *markers = [marker markers];
		if (markers) {
			for (NSString *markerName in markers) {
				NSObject *existingHandler = [_markers objectForKey:markerName];
				if (!existingHandler) {
					// Set this MGTemplateMaker instance as the handler for markerName.
					[_markers setObject:marker forKey:markerName];
				}
			}
		}
	}
}


- (void)loadFilter:(NSObject <MGTemplateFilter> *)filter
{
	if (filter) {
		// Obtain claimed filters.
		NSArray *filters = [filter filters];
		if (filters) {
			for (NSString *filterName in filters) {
				NSObject *existingHandler = [_filters objectForKey:filterName];
				if (!existingHandler) {
					// Set this MGTemplateFilter instance as the handler for filterName.
					[_filters setObject:filter forKey:filterName];
				}
			}
		}
	}
}


#pragma mark  Delegate


- (void)reportError:(NSString *)errorStr code:(int)code continuing:(BOOL)continuing
{
	if (delegate) {
		NSString *errStr = NSLocalizedString(errorStr, nil);
		if (!continuing) {
			errStr = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Fatal Error", nil), errStr];
		}
		SEL selector = @selector(templateEngine:encounteredError:isContinuing:);
		if ([(NSObject *)delegate respondsToSelector:selector]) {
			NSError *error = [NSError errorWithDomain:TEMPLATE_ENGINE_ERROR_DOMAIN 
												 code:code 
											 userInfo:[NSDictionary dictionaryWithObject:errStr 
																				  forKey:NSLocalizedDescriptionKey]];
			[(NSObject <MGTemplateEngineDelegate> *)delegate templateEngine:self 
														   encounteredError:error 
															   isContinuing:continuing];
		}
	}
}


- (void)reportBlockBoundaryStarted:(BOOL)started
{
	if (delegate) {
		SEL selector = (started) ? @selector(templateEngine:blockStarted:) : @selector(templateEngine:blockEnded:);
		if ([(NSObject *)delegate respondsToSelector:selector]) {
			[(NSObject *)delegate performSelector:selector withObject:self withObject:[_openBlocksStack lastObject]];
		}
	}
}


- (void)reportTemplateProcessingFinished
{
	if (delegate) {
		SEL selector = @selector(templateEngineFinishedProcessingTemplate:);
		if ([(NSObject *)delegate respondsToSelector:selector]) {
			[(NSObject *)delegate performSelector:selector withObject:self];
		}
	}
}


#pragma mark Utilities.


- (NSObject *)valueForVariable:(NSString *)var parent:(NSObject **)parent parentKey:(NSString **)parentKey
{
	// Returns value for given variable-path, and returns by reference the parent object the variable
	// is contained in, and the key used on that parent object to access the variable.
	// e.g. for var "thing.stuff.2", where thing = NSDictionary and stuff = NSArray,
	// parent would be a pointer to the "stuff" array, and parentKey would be "2".
	
	NSString *dot = @".";
	NSArray *dotBits = [var componentsSeparatedByString:dot];
	NSObject *result = nil;
	NSObject *currObj = nil;
	
	// Check to see if there's a top-level entry for first part of var in templateVariables.
	NSString *firstVar = [dotBits objectAtIndex:0];
	
	if ([_templateVariables objectForKey:firstVar]) {
		currObj = _templateVariables;
	} else if ([_globals objectForKey:firstVar]) {
		currObj = _globals;
	} else {
		// Attempt to find firstVar in stack variables.
		NSEnumerator *stack = [_openBlocksStack reverseObjectEnumerator];
		NSDictionary *stackFrame = nil;
		while (stackFrame = [stack nextObject]) {
			NSDictionary *vars = [stackFrame objectForKey:BLOCK_VARIABLES_KEY];
			if (vars && [vars objectForKey:firstVar]) {
				currObj = vars;
				break;
			}
		}
	}
	
	if (!currObj) {
		return nil;
	}
	
	// Try raw KVC.
	@try {
		result = [currObj valueForKeyPath:var];
	}
	@catch (NSException *exception) {
		// do nothing
	}
	
	if (result) {
		// Got it with regular KVC. Work out parent and parentKey if necessary.
		if (parent || parentKey) {
			if ([dotBits count] > 1) {
				if (parent) {
					*parent = [currObj valueForKeyPath:[[dotBits subarrayWithRange:NSMakeRange(0, [dotBits count] - 1)] 
													   componentsJoinedByString:dot]];
				}
				if (parentKey) {
					*parentKey = [dotBits lastObject];
				}
			} else {
				if (parent) {
					*parent = currObj;
				}
				if (parentKey) {
					*parentKey = var;
				}
			}
		}
	} else {
		// Try iterative checking for array indices.
		int numKeys = (int)[dotBits count];
		if (numKeys > 1) { // otherwise no point in checking
			NSObject *thisParent = currObj;
			NSString *thisKey = nil;
			for (int i = 0; i < numKeys; i++) {
				thisKey = [dotBits objectAtIndex:i];
				NSObject *newObj = nil;
				@try {
					newObj = [currObj valueForKeyPath:thisKey];
				}
				@catch (NSException *e) {
					// do nothing
				}
				// Check to see if this is an array which we can index into.
				if (!newObj && [currObj isKindOfClass:[NSArray class]]) {
					NSCharacterSet *numbersSet = [NSCharacterSet decimalDigitCharacterSet];
					NSScanner *scanner = [NSScanner scannerWithString:thisKey];
					NSString *digits;
					BOOL scanned = [scanner scanCharactersFromSet:numbersSet intoString:&digits];
					if (scanned && digits && [digits length] > 0) {
						int index = [digits intValue];
						if (index >= 0 && index < [((NSArray *)currObj) count]) {
							newObj = [((NSArray *)currObj) objectAtIndex:index];
						}
					}
				}
				thisParent = currObj;
				currObj = newObj;
				if (!currObj) {
					break;
				}
			}
			result = currObj;
			if (parent || parentKey) {
				if (parent) {
					*parent = thisParent;
				}
				if (parentKey) {
					*parentKey = thisKey;
				}
			}
		}
	}
	
	return result;
}


- (void)setValue:(NSObject *)newValue forVariable:(NSString *)var forceCurrentStackFrame:(BOOL)inStackFrame
{
	NSObject *parent = nil;
	NSString *parentKey = nil;
	NSObject *currValue;
	currValue = [self valueForVariable:var parent:&parent parentKey:&parentKey];
	if (!inStackFrame && currValue && (currValue != newValue)) {
		// Set new value appropriately.
		if ([parent isKindOfClass:[NSMutableArray class]]) {
			[(NSMutableArray *)parent replaceObjectAtIndex:[parentKey intValue] withObject:newValue];
		} else {
			// Try using setValue:forKey:
			@try {
				[parent setValue:newValue forKey:parentKey];
			}
			@catch (NSException *e) {
				// do nothing
			}
		}
	} else if (!currValue || inStackFrame) {
		// Put the variable into the current block-stack frame, or _templateVariables otherwise.
		NSMutableDictionary *vars;
		if ([_openBlocksStack count] > 0) {
			vars = [[_openBlocksStack lastObject] objectForKey:BLOCK_VARIABLES_KEY];
		} else {
			vars = _templateVariables;
		}
		if ([vars respondsToSelector:@selector(setValue:forKey:)]) {
			[vars setValue:newValue forKey:var];
		}
	}
}


- (NSObject *)resolveVariable:(NSString *)var
{
	NSObject *parent = nil;
	NSString *key = nil;
	NSObject *result = [self valueForVariable:var parent:&parent parentKey:&key];
	//NSLog(@"var: %@, parent: %@, key: %@, result: %@", var, parent, key, result);
	return result;
}


- (NSDictionary *)templateVariables
{
	return [NSDictionary dictionaryWithDictionary:_templateVariables];
}


#pragma mark Processing templates.

#pragma mark Properties


@synthesize markerStartDelimiter;
@synthesize markerEndDelimiter;
@synthesize expressionStartDelimiter;
@synthesize expressionEndDelimiter;
@synthesize filterDelimiter;
@synthesize literalStartMarker;
@synthesize literalEndMarker;
@synthesize remainingRange;
@synthesize delegate;
@synthesize matcher;
@synthesize templateContents;


@end
