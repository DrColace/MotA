//
//  BCDataCollector.h
//  MotA
//
//  Created by Drew Colace on 5/1/17.
//  Copyright © 2017 Drew Colace. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef BCDataCollector_h
#define BCDataCollector_h

@interface BCDataCollector : NSObject

- (void)lookupAcronym:(NSString *)lookupString suceeded:(void (^)(NSArray *))suceeded failed:(void (^)(void))failed;

@end

#endif /* BCDataCollector_h */
