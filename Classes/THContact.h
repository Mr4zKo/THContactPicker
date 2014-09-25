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
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSMutableArray *phoneNumbers;
@property(nonatomic, strong) NSMutableAttributedString *attributedNameLabel;
@property(nonatomic, strong) NSMutableAttributedString *attributedNumberLabel;

-(void)addPhoneNumber:(NSString*)number;
-(BOOL)matchesFilterString:(NSString *)filterString;

-(NSString *)phoneNumber;

+(NSString *)removeDiacritics:(NSString *)stringToRemove;

@end
