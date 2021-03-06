//
//  FLManagedTag.h
//  
//
//  Created by CPU124C41 on 27/06/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class FLManagedFreelancer, FLManagedTask;


@interface FLManagedTag : NSManagedObject

@property (nonatomic, retain) NSString				*value;
@property (nonatomic, retain) FLManagedFreelancer	*freelancer;
@property (nonatomic, retain) FLManagedTask			*task;

@end
