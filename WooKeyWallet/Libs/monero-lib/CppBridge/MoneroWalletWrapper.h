//
//  MoneroWalletWrapper.h
//  Wookey
//
//  Created by WookeyWallet on 2020/4/27.
//  Copyright © 2020 Wookey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoneroTrxHistory.h"
#import "MoneroSubAddress.h"
#import "MoneroWalletListener.h"

@class MoneroWalletWrapper;

@protocol MoneroWalletDelegate <NSObject>
- (void)moneroWalletRefreshed:(nonnull MoneroWalletWrapper *)wallet;
- (void)moneroWalletNewBlock:(nonnull MoneroWalletWrapper *)wallet currentHeight:(uint64_t)currentHeight;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MoneroWalletWrapper : NSObject

@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, assign, readonly) BOOL isSynchronized;
@property (nonatomic, assign, readonly) int status;
@property (nonatomic, copy, readonly) NSString * errorMessage;

@property (nonatomic, copy, readonly) NSString * publicViewKey;
@property (nonatomic, copy, readonly) NSString * publicSpendKey;
@property (nonatomic, copy, readonly) NSString * secretViewKey;
@property (nonatomic, copy, readonly) NSString * secretSpendKey;
@property (nonatomic, copy, readonly) NSString * publicAddress;

@property (nonatomic, assign, readonly) uint64_t balance;
@property (nonatomic, assign, readonly) uint64_t unlockedBalance;
@property (nonatomic, assign, readonly) uint64_t blockChainHeight;
@property (nonatomic, assign, readonly) uint64_t daemonBlockChainHeight;
@property (nonatomic, assign, readwrite) uint64_t restoreHeight;


+ (MoneroWalletWrapper *)generateWithPath:(NSString *)path
                                 password:(NSString *)password
                                 language:(NSString *)language;
+ (MoneroWalletWrapper *)recoverWithSeed:(NSString *)seed
                                    path:(NSString *)path
                                password:(NSString *)password;
+ (MoneroWalletWrapper *)recoverFromKeysWithPath:(NSString *)path
                                        password:(NSString *)password
                                        language:(NSString *)language
                                   restoreHeight:(uint64_t)restoreHeight
                                        address:(NSString *)address
                                        viewKey:(NSString *)viewKey
                                        spendKey:(NSString *)spendKey;
+ (MoneroWalletWrapper *)openExistingWithPath:(NSString *)path
                                     password:(NSString *)password;


- (BOOL)connectToDaemon:(NSString *)daemonAddress delegate:(id<MoneroWalletDelegate>)delegate;
- (BOOL)connectToDaemon:(NSString *)daemonAddress refresh:(MoneroWalletRefreshHandler)refresh newBlock:(MoneroWalletNewBlockHandler)newBlock;
- (void)startRefresh;
- (void)pauseRefresh;
- (BOOL)save;
- (BOOL)close;


+ (BOOL)validAddress:(NSString *)address;
+ (BOOL)verifyPassword:(NSString *)password path:(NSString *)path;
+ (NSString *)displayAmount:(uint64_t)amount;
+ (NSString *)generatePaymentId;
+ (NSString *)paymentIdFromAddress:(NSString *)address;


- (NSString *)getSeedString:(NSString *)language;
- (BOOL)setNewPassword:(NSString *)password;
- (NSString *)generateIntegartedAddress:(NSString *)paymentId;

- (void)setDelegate:(id<MoneroWalletDelegate>)delegate;

- (BOOL)addSubAddress:(NSString *)label accountIndex:(uint32_t)index;
- (BOOL)setSubAddress:(NSString *)label addressIndex:(uint32_t)addressIndex accountIndex:(uint32_t)accountIndex;
- (NSArray<MoneroSubAddress *> *)fetchSubAddressWithAccountIndex:(uint32_t)index;


- (BOOL)createTransactionToAddress:(NSString *)address paymentId:(NSString *)paymentId amount:(NSString *)amount mixinCount:(uint32_t)mixinCount priority:(PendingTransactionPriority)priority;
- (BOOL)createSweepTransactionToAddress:(NSString *)address paymentId:(NSString *)paymentId mixinCount:(uint32_t)mixinCount priority:(PendingTransactionPriority)priority;
- (BOOL)commitPendingTransaction;
- (void)disposeTransaction;
- (int64_t)transactionFee;
- (NSString *)transactionErrorMessage;
- (NSArray<MoneroTrxHistory *> *)fetchTransactionHistory;

@end

NS_ASSUME_NONNULL_END
