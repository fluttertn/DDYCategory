#import "NSArray+DDYExtension.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

@implementation NSArray (DDYExtension)

#pragma mark - TableView索引数组
#pragma mark 索引数组排序
- (NSMutableArray *)ddy_SortWithCollectionStringSelector:(SEL)selector {
    // 索引规则对象
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    // 索引数量（26个字母和1个#）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    // 初始化存储分组数组
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    // 得到@[ @[A], @[B], @[C] ... @[Z], @[#] ] 空数组
    for (int i = 0; i < sectionTitlesCount; i++) {
        [sections addObject:[NSMutableArray array]];
    }
    // 按selector参数分配到数组
    for (id obj in self) {
        NSInteger sectionNumber = [DDYCollation sectionForObject:obj collationStringSelector:selector];
        [[sections objectAtIndex:sectionNumber] addObject:obj];
    }
    // 对每个数组按排序 同时去除空数组
    for (int i = 0; i < sectionTitlesCount; i++) {
        [sections replaceObjectAtIndex:i withObject:[DDYCollation sortedArrayFromArray:sections[i] collationStringSelector:selector]];
    }
    // 去除空分组
    for (int i = 0; i < sections.count; i++) {
        if (!sections[i] || ![sections[i] count]) {
            [sections removeObject:sections[i]];
        }
    }
    return sections;
}

#pragma mark 索引数组标题
- (NSMutableArray *)ddy_SortWithModel:(NSString *)model selector:(SEL)selector showSearch:(BOOL)show {
    
    NSMutableArray *section = [NSMutableArray array];
    if (show) [section addObject:UITableViewIndexSearch];
    Class class = NSClassFromString(model);
    unsigned int count = 0;
    objc_property_t *propertys = class_copyPropertyList(class, &count);
    
    for(int i = 0; i < count; i ++) {
        
        objc_property_t property = propertys[i];
        
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        if ([propertyName isEqualToString:NSStringFromSelector(selector)]) {
            
            Ivar ivar = class_getInstanceVariable(class, [[NSString stringWithFormat:@"_%@",propertyName] UTF8String]);
            
            for (NSArray *itemArray in self) {
                NSString *str = (NSString *)object_getIvar(itemArray[0], ivar);
                char c = [self ddy_SortBlankString:str] ? '#' : [str characterAtIndex:0];
                if (!isalpha(c)) c = '#';
                [section addObject:[NSString stringWithFormat:@"%c", toupper(c)]];
            }
        }
    }
    return section;
}

- (BOOL)ddy_SortBlankString:(NSString *)string {
    if (string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]==0) {
        return YES;
    }
    return NO;
}

#pragma mark  对模型数组进行索引排序
- (void)ddy_ModelSortSelector:(SEL)selector complete:(void (^)(NSArray *modelsArray, NSArray *titlesArray))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 索引规则对象
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        // 索引数量（26个字母和1个#）
        NSInteger sectionTitlesCount = collation.sectionTitles.count;
        // 临时存储分组的数组
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
        // 最终去空的分组数组
        NSMutableArray *sortedModelArray = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
        // 最终储存标题的数组
        NSMutableArray *sectionTitleArray = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
        // @[ @[A], @[B], @[C] ... @[Z], @[#] ] 27个空数组(@[ @[], @[], @[] ... @[], @[] ])
        for (int i = 0; i < sectionTitlesCount; i++) {
            [tempArray addObject:[NSMutableArray array]];
        }
        // 按selector参数分配到数组
        for (id obj in self) {
            NSInteger sectionNumber = [collation sectionForObject:obj collationStringSelector:selector];
            [[tempArray objectAtIndex:sectionNumber] addObject:obj];
        }
        // 对每个数组按排序 同时去除空数组
        for (int i = 0; i < sectionTitlesCount; i++) {
            if (tempArray[i] && [tempArray[i] count]) {
                [sortedModelArray addObject:[collation sortedArrayFromArray:tempArray[i] collationStringSelector:selector]];
                [sectionTitleArray addObject:[UILocalizedIndexedCollation currentCollation].sectionTitles[i]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(sortedModelArray, sectionTitleArray);
            }
        });
    });
}

@end
