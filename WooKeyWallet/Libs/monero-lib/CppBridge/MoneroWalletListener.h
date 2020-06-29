//
//  MoneroWalletListener.h
//  Wookey
//
//  Created by WookeyWallet on 2020/6/23.
//  Copyright © 2020 Wookey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MoneroWalletRefreshHandler)(void);
typedef void (^MoneroWalletNewBlockHandler)(uint64_t curreneight);

NS_ASSUME_NONNULL_BEGIN

@interface MoneroWalletListener : NSObject

@property (nonatomic, strong) MoneroWalletRefreshHandler refreshHandler;
@property (nonatomic, strong) MoneroWalletNewBlockHandler newBlockHandler;

@end

NS_ASSUME_NONNULL_END
