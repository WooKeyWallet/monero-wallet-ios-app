//
//  MoneroSubAddress.m
//  Wookey
//
//  Created by WookeyWallet on 2020/4/27.
//  Copyright © 2020 Wookey. All rights reserved.
//

#import "MoneroSubAddress.h"

@implementation MoneroSubAddress

- (instancetype)initWithRowId:(size_t)rowId address:(NSString *)address label:(NSString *)label {
    if (self = [super init]) {
        _rowId = rowId;
        _address = address;
        _label = label;
    }
    return self;
}

@end
