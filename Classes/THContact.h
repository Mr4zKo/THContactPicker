//
//  THContact.h
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import <Foundation/Foundation.h>

@interface THContact : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSMutableArray *phoneNumbers;

-(void)addPhoneNumber:(NSString*)number;
-(BOOL)matchesFilterString:(NSString *)filterString;

@end
