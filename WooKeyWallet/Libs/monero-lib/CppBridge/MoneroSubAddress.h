//
//  MoneroSubAddress.h
//  Wookey
//
//  Created by WookeyWallet on 2020/4/27.
//  Copyright © 2020 Wookey. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoneroSubAddress : NSObject

@property (nonatomic, assign, readonly) size_t rowId;
@property (nonatomic, copy, readonly) NSString * address;
@property (nonatomic, copy, readonly) NSString * label;

- (instancetype)initWithRowId:(size_t)rowId address:(NSString *)address label:(NSString *)label;

@end

NS_ASSUME_NONNULL_END
