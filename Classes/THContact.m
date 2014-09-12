//
//  THContact.m
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import "THContact.h"

@implementation THContact

-(id)init{
    
    if(self = [super init]){
        self.name = @"";
        self.phoneNumbers = [[NSMutableArray alloc] init];
    }
    
    return self;
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
    
    if([self string:self.name containsSubstring:filterString]){
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
    
    lowerCaseString = [self removeDiacritics:lowerCaseString];
    lowerCaseSubstring = [self removeDiacritics:lowerCaseSubstring];
    
    NSRange range = [lowerCaseString rangeOfString: lowerCaseSubstring];
    BOOL found = (range.location!=NSNotFound);
    return found;
}

-(NSString *)removeDiacritics:(NSString *)stringToRemove{
    NSArray *diacriticsArray = @[@"À", @"Á", @"Â", @"Ã", @"Ä", @"Å", @"Æ", @"Ç", @"È", @"É", @"Ê", @"Ë", @"Ì", @"Í", @"Î", @"Ï", @"Ð", @"Ñ", @"Ò", @"Ó", @"Ô", @"Õ", @"Ö", @"Ø", @"Ù", @"Ú", @"Û", @"Ü", @"Ý", @"ß", @"à", @"á", @"â", @"ã", @"ä", @"å", @"æ", @"ç", @"è", @"é", @"ê", @"ë", @"ì", @"í", @"î", @"ï", @"ñ", @"ò", @"ó", @"ô", @"õ", @"ö", @"ø", @"ù", @"ú", @"û", @"ü", @"ý", @"ÿ", @"Ā", @"ā", @"Ă", @"ă", @"Ą", @"ą", @"Ć", @"ć", @"Ĉ", @"ĉ", @"Ċ", @"ċ", @"Č", @"č", @"Ď", @"ď", @"Đ", @"đ", @"Ē", @"ē", @"Ĕ", @"ĕ", @"Ė", @"ė", @"Ę", @"ę", @"Ě", @"ě", @"Ĝ", @"ĝ", @"Ğ", @"ğ", @"Ġ", @"ġ", @"Ģ", @"ģ", @"Ĥ", @"ĥ", @"Ħ", @"ħ", @"Ĩ", @"ĩ", @"Ī", @"ī", @"Ĭ", @"ĭ", @"Į", @"į", @"İ", @"ı", @"Ĳ", @"ĳ", @"Ĵ", @"ĵ", @"Ķ", @"ķ", @"Ĺ", @"ĺ", @"Ļ", @"ļ", @"Ľ", @"ľ", @"Ŀ", @"ŀ", @"Ł", @"ł", @"Ń", @"ń", @"Ņ", @"ņ", @"Ň", @"ň", @"ŉ", @"Ō", @"ō", @"Ŏ", @"ŏ", @"Ő", @"ő", @"Œ", @"œ", @"Ŕ", @"ŕ", @"Ŗ", @"ŗ", @"Ř", @"ř", @"Ś", @"ś", @"Ŝ", @"ŝ", @"Ş", @"ş", @"Š", @"š", @"Ţ", @"ţ", @"Ť", @"ť", @"Ŧ", @"ŧ", @"Ũ", @"ũ", @"Ū", @"ū", @"Ŭ", @"ŭ", @"Ů", @"ů", @"Ű", @"ű", @"Ų", @"ų", @"Ŵ", @"ŵ", @"Ŷ", @"ŷ", @"Ÿ", @"Ź", @"ź", @"Ż", @"ż", @"Ž", @"ž", @"ſ", @"ƒ", @"Ơ", @"ơ", @"Ư", @"ư", @"Ǎ", @"ǎ", @"Ǐ", @"ǐ", @"Ǒ", @"ǒ", @"Ǔ", @"ǔ", @"Ǖ", @"ǖ", @"Ǘ", @"ǘ", @"Ǚ", @"ǚ", @"Ǜ", @"ǜ", @"Ǻ", @"ǻ", @"Ǽ", @"ǽ", @"Ǿ", @"ǿ"];
    
    NSArray *replacementArray = @[@"A", @"A", @"A", @"A", @"A", @"A", @"AE", @"C", @"E", @"E", @"E", @"E", @"I", @"I", @"I", @"I", @"D", @"N", @"O", @"O", @"O", @"O", @"O", @"O", @"U", @"U", @"U", @"U", @"Y", @"s", @"a", @"a", @"a", @"a", @"a", @"a", @"a"/*"ae"*/, @"c", @"e", @"e", @"e", @"e", @"i", @"i", @"i", @"i", @"n", @"o", @"o", @"o", @"o", @"o", @"o", @"u", @"u", @"u", @"u", @"y", @"y", @"A", @"a", @"A", @"a", @"A", @"a", @"C", @"c", @"C", @"c", @"C", @"c", @"C", @"c", @"D", @"d", @"D", @"d", @"E", @"e", @"E", @"e", @"E", @"e", @"E", @"e", @"E", @"e", @"G", @"g", @"G", @"g", @"G", @"g", @"G", @"g", @"H", @"h", @"H", @"h", @"I", @"i", @"I", @"i", @"I", @"i", @"I", @"i", @"I", @"i", @"I"/*"IJ"*/, @"i"/*"ij"*/, @"J", @"j", @"K", @"k", @"L", @"l", @"L", @"l", @"L", @"l", @"L", @"l", @"l", @"l", @"N", @"n", @"N", @"n", @"N", @"n", @"n", @"O", @"o", @"O", @"o", @"O", @"o", @"O"/*"OE"*/, @"o"/*"oe"*/, @"R", @"r", @"R", @"r", @"R", @"r", @"S", @"s", @"S", @"s", @"S", @"s", @"S", @"s", @"T", @"t", @"T", @"t", @"T", @"t", @"U", @"u", @"U", @"u", @"U", @"u", @"U", @"u", @"U", @"u", @"U", @"u", @"W", @"w", @"Y", @"y", @"Y", @"Z", @"z", @"Z", @"z", @"Z", @"z", @"s", @"f", @"O", @"o", @"U", @"u", @"A", @"a", @"I", @"i", @"O", @"o", @"U", @"u", @"U", @"u", @"U", @"u", @"U", @"u", @"U", @"u", @"A", @"a", @"A"/*"AE"*/, @"a"/*"ae"*/, @"O", @"o"];
    
    NSString *newString = stringToRemove;
    
    if(newString.length>0){
        NSString * zeroCharString = [newString substringWithRange:NSMakeRange(0, 1)];
        if([zeroCharString isEqualToString:@" "]){
            newString = [newString substringWithRange:NSMakeRange(1, newString.length-1)];
        }
    }
    
    for(int i=0; i<stringToRemove.length; i++){
        NSString * charAtI = [stringToRemove substringWithRange:NSMakeRange(i, 1)];
        
        NSInteger index = [diacriticsArray indexOfObject:charAtI];
        if(index!=NSNotFound){
            newString = [newString stringByReplacingOccurrencesOfString:charAtI withString:[replacementArray objectAtIndex:index]];
        }
    }

    return newString;
}

@end
