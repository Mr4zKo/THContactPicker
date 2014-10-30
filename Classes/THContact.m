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
    NSString *trimed = filterString;
    
    if([trimed hasPrefix:@" "]){
        trimed = [trimed substringFromIndex:1];
    }
    
    if([self string:self.nameNoDiacritics containsSubstring:trimed oneMatchEnough:NO]){
        
        [self generateSpannableStringsForSubstring:trimed];
        
        return YES;
    }
    
    for(int i=0; i<[self.phoneNumbers count]; i++){
        trimed = [trimed stringByReplacingOccurrencesOfString:@" " withString:@""];

        if([self string:trimed matchesPhoneNumber:[self.phoneNumbers objectAtIndex:i]]){
            
            [self generateSpannableStringsForSubstring:trimed];
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)string:(NSString*)string containsSubstring:(NSString *)substring oneMatchEnough:(BOOL)oneMatchEnough{
    
    NSString *lowerCaseString = [string lowercaseString];
    NSString *lowerCaseSubstring = [substring lowercaseString];
    
    NSArray *stringArray = [lowerCaseString componentsSeparatedByString:@" "];
    NSArray *substringArray = [lowerCaseSubstring componentsSeparatedByString:@" "];
    
    for(NSString *substr in substringArray){
        if([substr isEqualToString:@""]){
            continue;
        }
        
        BOOL noThere = YES;
        
        for(NSString *str in stringArray){
            if([str hasPrefix:substr]){
                noThere = NO;
                
                if(oneMatchEnough){
                    return YES;
                }
            }
        }
        
        if(noThere && !oneMatchEnough){
            return NO;
        }
    }
    
    if(oneMatchEnough){
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)string:(NSString *)string matchesPhoneNumber:(NSString *)phoneNumber{
    NSArray *phoneNumberArray = [phoneNumber componentsSeparatedByString:@"\u00a0"];
    if(phoneNumberArray.count<2){
        phoneNumberArray = [phoneNumber componentsSeparatedByString:@" "];
    }
    NSString *actualStringToCompare = string;
    
    BOOL nextHasToMatch = NO;
    
    for(int i=0; i<phoneNumberArray.count; i++){
        NSString *phoneNumberPart = [phoneNumberArray objectAtIndex:i];
        if([actualStringToCompare length]>=[phoneNumberPart length]){
            if([actualStringToCompare hasPrefix:phoneNumberPart]){
                actualStringToCompare = [actualStringToCompare substringFromIndex:[phoneNumberPart length]];
                nextHasToMatch = YES;
                continue;
            }else{
                if(nextHasToMatch){
                    break;
                }
            }
        }else{
            if([phoneNumberPart hasPrefix:actualStringToCompare]){
                actualStringToCompare = @"";
            }else{
                if(nextHasToMatch){
                    break;
                }
            }
        }
    }
    
    return [actualStringToCompare length]==0?YES:NO;
}

-(void)generateSpannableStringsForSubstring:(NSString *)substring{
    
    UIFont *regularSmallFont = [UIFont systemFontOfSize:15];
    UIFont *boldSmallFont = [UIFont boldSystemFontOfSize:15];
    
    UIFont *regularFont = [UIFont systemFontOfSize:17];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:17];
    
    NSDictionary *regSmallAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularSmallFont, NSFontAttributeName, nil];
    NSDictionary *boldSmallAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   boldSmallFont, NSFontAttributeName, nil];
    NSDictionary *regAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   regularFont, NSFontAttributeName, nil];
    NSDictionary *boldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   boldFont, NSFontAttributeName, nil];
    
    if([self.phoneNumbers count]>0){
        NSString *phoneNumber = [self.phoneNumbers objectAtIndex:0];
        NSMutableAttributedString *attrNumberString = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"%@ %@", self.type, phoneNumber] attributes:regSmallAttrs];
        
        if(![substring isEqualToString:@" "] &&
           [self string:substring matchesPhoneNumber:phoneNumber]){
            
            [attrNumberString setAttributes:boldSmallAttrs range:NSMakeRange(0, [self.type length])];
        }
        
        self.attributedNumberLabel = attrNumberString;
    }

    NSMutableAttributedString *attrNameString = [[NSMutableAttributedString alloc]
                                                   initWithString:[NSString stringWithFormat:@"%@", self.name] attributes:regAttrs];
    
    NSArray *nameComponents = [self.name componentsSeparatedByString:@" "];
    NSUInteger lastNameEndPosition = 0;
    for(int i=0; i<nameComponents.count; i++){
        
        NSString *namePart = [nameComponents objectAtIndex:i];
        
        if([self string:namePart containsSubstring:substring oneMatchEnough:YES]){
               
            [attrNameString setAttributes:boldAttrs range:NSMakeRange(lastNameEndPosition, [namePart length])];
           
        }
        
        lastNameEndPosition = lastNameEndPosition + [namePart length]+1;
    }
    
    self.attributedNameLabel = attrNameString;
}

+(NSString *)removeDiacritics:(NSString *)stringToRemove{
    NSString *newString = [[NSString alloc]
                           initWithData:
                           [stringToRemove dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                           encoding:NSASCIIStringEncoding];

    return newString;
}

@end
