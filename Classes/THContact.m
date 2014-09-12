//
//  THContact.m
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import "THContact.h"

@interface THContact()

@property(nonatomic, strong) NSString *nameNoDiacritics;

@end

@implementation THContact

-(id)init{
    
    if(self = [super init]){
        self.name = @"";
        self.phoneNumbers = [[NSMutableArray alloc] init];
        self.nameNoDiacritics = @"";
    }
    
    return self;
}

-(void)setName:(NSString *)name{
    _name = name;
    self.nameNoDiacritics = [THContact removeDiacritics:self.name];
}

-(void)addPhoneNumber:(NSString*)number{
    [self.phoneNumbers addObject:number];
}

-(NSString *)phoneNumber{
    if(self.phoneNumbers.count>0){
        return [self.phoneNumbers objectAtIndex:0];
    }
    
    else return @"";
}

-(BOOL)matchesFilterString:(NSString *)filterString{
    
    if([self string:self.nameNoDiacritics containsSubstring:filterString]){
        return YES;
    }
    
    for(int i=0; i<[self.phoneNumbers count]; i++){
        if([self string:[self.phoneNumbers objectAtIndex:i] containsSubstring:filterString]){
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)string:(NSString*)string containsSubstring:(NSString *)substring{
    
    NSString *lowerCaseString = [string lowercaseString];
    NSString *lowerCaseSubstring = [substring lowercaseString];
    
    
    NSRange range = [lowerCaseString rangeOfString: lowerCaseSubstring];
    BOOL found = (range.location!=NSNotFound);
    return found;
}

+(NSString *)removeDiacritics:(NSString *)stringToRemove{
    NSString *newString = [[NSString alloc]
                           initWithData:
                           [stringToRemove dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                           encoding:NSASCIIStringEncoding];

    return newString;
}

@end
