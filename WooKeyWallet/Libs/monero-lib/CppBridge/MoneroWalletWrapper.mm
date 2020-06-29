//
//  MoneroWalletWrapper.m
//  Wookey
//
//  Created by WookeyWallet on 2020/4/27.
//  Copyright © 2020 Wookey. All rights reserved.
//

#import "MoneroWalletWrapper.h"
#import "MoneroConfig.h"

using namespace std;

struct WalletListenerImpl: Bitmonero::WalletListener
{
    MoneroWalletListener *_listener = NULL;
    
    ~WalletListenerImpl()
    {
        _listener = NULL;
    }
    
    void moneySpent(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    void moneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }

    void newBlock(uint64_t height)
    {
        if (_listener && _listener.newBlockHandler) {
            _listener.newBlockHandler(height);
        }
    }

    void updated()
    {
        // not implemented
    }

    void refreshed()
    {
        if (_listener && _listener.refreshHandler) {
            _listener.refreshHandler();
        }
    }
    
    void registerListener(MoneroWalletListener *listener)
    {
        _listener = listener;
    }
};

@interface MoneroWalletWrapper ()
{
    Monero::Wallet* monero_wallet;
    WalletListenerImpl* monero_walletListener;
    Monero::PendingTransaction* monero_pendingTransaction;
}

@end

@implementation MoneroWalletWrapper

#pragma mark - Life Cycles

#pragma mark ___init

- (instancetype)init {
    if (self = [super init]) {
        monero_wallet = nullptr;
        monero_walletListener = nullptr;
    }
    return self;
}

+ (MoneroWalletWrapper *)init_monero_wallet:(Monero::Wallet *)monero_wallet {
    if (monero_wallet->status() != Monero::Wallet::Status_Ok) return NULL;
#if DEBUG
    Monero::WalletManagerFactory::setLogLevel(Monero::WalletManagerFactory::LogLevel_Max);
#endif
    MoneroWalletWrapper *walletWrapper = [[MoneroWalletWrapper alloc] init];
    walletWrapper->monero_wallet = monero_wallet;
    return walletWrapper;
}

+ (MoneroWalletWrapper *)generateWithPath:(NSString *)path
                                 password:(NSString *)password
                                 language:(NSString *)language {
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Lg = [language UTF8String];
    Monero::Wallet* monero_wallet = walletManager->createWallet(utf8Path, utf8Pwd, utf8Lg, netType);
    return [self init_monero_wallet:monero_wallet];
}

+ (MoneroWalletWrapper *)recoverWithSeed:(NSString *)seed
                                    path:(NSString *)path
                                password:(NSString *)password {
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Seed = [seed UTF8String];
    Monero::Wallet* monero_wallet = walletManager->recoveryWallet(utf8Path, utf8Pwd, utf8Seed, netType, 0, 1);
    return [self init_monero_wallet:monero_wallet];
}

+ (MoneroWalletWrapper *)recoverFromKeysWithPath:(NSString *)path
                                        password:(NSString *)password
                                        language:(NSString *)language
                                   restoreHeight:(uint64_t)restoreHeight
                                         address:(NSString *)address
                                         viewKey:(NSString *)viewKey
                                        spendKey:(NSString *)spendKey {
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Language = [language UTF8String];
    string utf8Address = [address UTF8String];
    string utf8ViewKey = [viewKey UTF8String];
    string utf8SpendKey = [spendKey UTF8String];
    Monero::Wallet* monero_wallet = walletManager->createWalletFromKeys(utf8Path, utf8Pwd, utf8Language, netType, restoreHeight, utf8Address, utf8ViewKey, utf8SpendKey);
    return [self init_monero_wallet:monero_wallet];
}

+ (MoneroWalletWrapper *)openExistingWithPath:(NSString *)path
                                     password:(NSString *)password {
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    Monero::Wallet* monero_wallet = walletManager->openWallet(utf8Path, utf8Pwd, netType);
    return [self init_monero_wallet:monero_wallet];
}

#pragma mark ___listener

- (void)addListener {
    if (monero_walletListener) return;
    WalletListenerImpl * impl = new WalletListenerImpl();
    monero_wallet->setListener(impl);
    monero_walletListener = impl;
}

- (void)setBlocksRefresh:(MoneroWalletRefreshHandler)refresh newBlock:(MoneroWalletNewBlockHandler)newBlock {
    [self addListener];
    monero_walletListener->registerListener(NULL);
    MoneroWalletListener *listener = [[MoneroWalletListener alloc] init];
    listener.newBlockHandler = newBlock;
    listener.refreshHandler = refresh;
    monero_walletListener->registerListener(listener);
}

- (void)setDelegate:(id<MoneroWalletDelegate>)delegate {
    __weak typeof(delegate) weakDelegate = delegate;
    __weak typeof(self) weakSelf = self;
    [self setBlocksRefresh:^{
        if (weakSelf && weakDelegate && [weakDelegate respondsToSelector:@selector(moneroWalletRefreshed:)]) {
            MoneroWalletWrapper * wallet = weakSelf;
            [weakDelegate moneroWalletRefreshed:(wallet)];
        }
    } newBlock:^(uint64_t curreneight) {
        if (weakSelf && weakDelegate && [weakDelegate respondsToSelector:@selector(moneroWalletNewBlock:currentHeight:)]) {
            MoneroWalletWrapper * wallet = weakSelf;
            [weakDelegate moneroWalletNewBlock:wallet currentHeight:curreneight];
        }
    }];
}

#pragma mark ___deinit

-(void)dealloc {
    if (monero_walletListener) {
        monero_walletListener->registerListener(NULL);
        delete monero_walletListener;
        monero_walletListener = nullptr;
    }
}


#pragma mark - Data

- (BOOL)connectToDaemon:(NSString *)daemonAddress {
    if (!monero_wallet) return NO;
    return monero_wallet->init([daemonAddress UTF8String]);
}

- (BOOL)connectToDaemon:(NSString *)daemonAddress delegate:(id<MoneroWalletDelegate>)delegate {
    [self setDelegate:delegate];
    return [self connectToDaemon:daemonAddress];
}

- (BOOL)connectToDaemon:(NSString *)daemonAddress refresh:(MoneroWalletRefreshHandler)refresh newBlock:(MoneroWalletNewBlockHandler)newBlock {
    [self setBlocksRefresh:refresh newBlock:newBlock];
    return [self connectToDaemon:daemonAddress];
}

- (void)startRefresh {
    if (monero_wallet) {
        monero_wallet->startRefresh();
    }
}

- (void)pauseRefresh {
    if (monero_wallet) {
        monero_wallet->pauseRefresh();
    }
}

- (BOOL)save {
    if (monero_wallet) {
        return monero_wallet->store(monero_wallet->path());
    }
    return NO;
}

- (BOOL)close {
    BOOL success = YES;
    if (monero_wallet) {
        monero_wallet->pauseRefresh();
        monero_wallet->setListener(nullptr);
        struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
        if (!walletManager->closeWallet(monero_wallet)) {
            NSLog(@"close wallet fail: %@", [self errorMessage]);
            success = NO;
        }
    }
    return success;
}


#pragma mark - Utils

#pragma mark ___class

+ (BOOL)validAddress:(NSString *)address {
    return Monero::Wallet::addressValid([address UTF8String], netType);
}

+ (BOOL)verifyPassword:(NSString *)password path:(NSString *)path {
    Bitmonero::Wallet::Device device_type;
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    return Bitmonero::WalletManagerFactory::getWalletManager()->queryWalletDevice(device_type, utf8Path, utf8Pwd);
}

+ (NSString *)displayAmount:(uint64_t)amount {
    string amountStr = Monero::Wallet::displayAmount(amount);
    return objc_str_dup(amountStr);
}

+ (NSString *)generatePaymentId {
    string payment_id = Monero::Wallet::genPaymentId();
    return objc_str_dup(payment_id);
}

+ (NSString *)paymentIdFromAddress:(NSString *)address {
    string utf8Address = [address UTF8String];
    string payment_id = Monero::Wallet::paymentIdFromAddress(utf8Address, netType);
    return objc_str_dup(payment_id);
}


#pragma mark ___object

- (NSString *)getSeedString:(NSString *)language {
    string seed = "";
    if (monero_wallet) {
        monero_wallet->setSeedLanguage([language UTF8String]);
        seed = monero_wallet->seed();
    }
    return objc_str_dup(seed);
}

- (BOOL)setNewPassword:(NSString *)password {
    if (monero_wallet) {
        return monero_wallet->setPassword([password UTF8String]);
    }
    return NO;
}

- (NSString *)generateIntegartedAddress:(NSString *)paymentId {
    string integratedAddress = "";
    if (monero_wallet) {
        integratedAddress = monero_wallet->integratedAddress([paymentId UTF8String]);
    }
    return objc_str_dup(integratedAddress);
}


#pragma mark - SubAddress

- (BOOL)addSubAddress:(NSString *)label accountIndex:(uint32_t)index {
    if (monero_wallet) {
        monero_wallet->addSubaddress(index, [label UTF8String]);
        return YES;
    }
    return NO;
}

- (BOOL)setSubAddress:(NSString *)label addressIndex:(uint32_t)addressIndex accountIndex:(uint32_t)accountIndex {
    if (monero_wallet) {
        monero_wallet->setSubaddressLabel(accountIndex, addressIndex, [label UTF8String]);
        return YES;
    }
    return NO;
}

- (NSArray<MoneroSubAddress *> *)fetchSubAddressWithAccountIndex:(uint32_t)index {
    NSMutableArray<MoneroSubAddress *> *result = [NSMutableArray array];
    if (monero_wallet) {
        Monero::Subaddress * subAddress = monero_wallet->subaddress();
        if (subAddress) {
            subAddress->refresh(index);
            std::vector<Monero::SubaddressRow *> all = subAddress->getAll();
            std::size_t allCount = all.size();
            for (std::size_t i = 0; i < allCount; ++i) {
                Monero::SubaddressRow *item = all[i];
                [result addObject:[[MoneroSubAddress alloc] initWithRowId:item->getRowId()
                                                                  address:objc_str_dup(item->getAddress())
                                                                    label:objc_str_dup(item->getLabel())]];
            }
        }
    }
    return result;
}


#pragma mark - Transaction

- (BOOL)createTransactionToAddress:(NSString *)address paymentId:(NSString *)paymentId amount:(NSString *)amount mixinCount:(uint32_t)mixinCount priority:(PendingTransactionPriority)priority {
    if (!monero_wallet) return NO;
    [self disposeTransaction];
    Monero::optional<uint64_t> _amount;
    if (![amount isEqualToString:@"sweep"]) {
        _amount = Monero::Wallet::amountFromString([amount UTF8String]);
    }
    monero_pendingTransaction = monero_wallet->createTransaction([address UTF8String],
                                                                 [paymentId UTF8String],
                                                                 _amount,
                                                                 mixinCount,
                                                                 (Monero::PendingTransaction::Priority)priority);
    if (!monero_pendingTransaction) return NO;
    if (monero_pendingTransaction->status() != Status_Ok) {
        NSLog(@"monero createTransaction fail reason: %@", [self transactionErrorMessage]);
        return NO;
    }
    return YES;
}

- (BOOL)createSweepTransactionToAddress:(NSString *)address paymentId:(NSString *)paymentId mixinCount:(uint32_t)mixinCount priority:(PendingTransactionPriority)priority {
    return [self createTransactionToAddress:address paymentId:paymentId amount:@"sweep" mixinCount:mixinCount priority:priority];
}

- (BOOL)commitPendingTransaction {
    if (monero_pendingTransaction) {
        return monero_pendingTransaction->commit();
    }
    return NO;
}

- (void)disposeTransaction {
    if (monero_wallet && monero_pendingTransaction) {
        monero_wallet->disposeTransaction(monero_pendingTransaction);
        monero_pendingTransaction = NULL;
    }
}

- (int64_t)transactionFee {
    if (monero_pendingTransaction) {
        return monero_pendingTransaction->fee();
    }
    return -1;
}

- (NSString *)transactionErrorMessage {
    string errorStr = "";
    if (monero_pendingTransaction) {
        errorStr = monero_pendingTransaction->errorString();
    }
    return objc_str_dup(errorStr);
}

- (NSArray<MoneroTrxHistory *> *)fetchTransactionHistory {
    NSMutableArray<MoneroTrxHistory *> *result = [NSMutableArray array];
    if (monero_wallet) {
        Monero::TransactionHistory *history = monero_wallet->history();
        if (history) {
            history->refresh();
            std::vector<Monero::TransactionInfo *> allTransactionInfo = history->getAll();
            for (std::size_t i = 0; i < history->count(); ++i) {
                Monero::TransactionInfo *transactionInfo = allTransactionInfo[i];
                MoneroTrxHistory * trx = [[MoneroTrxHistory alloc] init];
                trx.direction = (TrxDirection)transactionInfo->direction();
                trx.isPending = transactionInfo->isPending();
                trx.isFailed = transactionInfo->isFailed();
                trx.amount = transactionInfo->amount();
                trx.fee = transactionInfo->fee();
                trx.confirmations = transactionInfo->confirmations();
                trx.timestamp = transactionInfo->timestamp();
                trx.blockHeight = transactionInfo->blockHeight();
                trx.hashValue = objc_str_dup(transactionInfo->hash());
                trx.label = objc_str_dup(transactionInfo->label());
                trx.paymentId = objc_str_dup(transactionInfo->paymentId());
                trx.unlockTime = transactionInfo->unlockTime();
                [result addObject:trx];
            }
        }
    }
    return result;
}


#pragma mark - Properties

#pragma mark ___setter

- (void)setRestoreHeight:(uint64_t)restoreHeight {
    if (monero_wallet) {
        monero_wallet->setRefreshFromBlockHeight(restoreHeight);
    }
}

#pragma mark ___getter

- (NSString *)name {
    NSString *name = @"";
    if (monero_wallet) {
        NSString *filename = objc_str_dup(monero_wallet->filename());
        NSString *lastItem = [[filename componentsSeparatedByString:@"/"] lastObject];
        if (lastItem) {
            name = lastItem;
        }
    }
    return name;
}

- (BOOL)isSynchronized {
    if (!monero_wallet) return NO;
    return monero_wallet->synchronized();
}

- (int)status {
    if (!monero_wallet) return 0;
    return monero_wallet->status();
}

- (NSString *)errorMessage {
    string errorString = "";
    if (monero_wallet) {
        errorString = monero_wallet->errorString();
    }
    return objc_str_dup(errorString);
}

- (NSString *)publicViewKey {
    string key  = "";
    if (monero_wallet) {
        key = monero_wallet->publicViewKey();
    }
    return objc_str_dup(key);
}

- (NSString *)publicSpendKey {
    string key  = "";
    if (monero_wallet) {
        key = monero_wallet->publicSpendKey();
    }
    return objc_str_dup(key);
}

- (NSString *)secretViewKey {
    string key  = "";
    if (monero_wallet) {
        key = monero_wallet->secretViewKey();
    }
    return objc_str_dup(key);
}

- (NSString *)secretSpendKey {
    string key  = "";
    if (monero_wallet) {
        key = monero_wallet->secretSpendKey();
    }
    return objc_str_dup(key);
}

- (NSString *)publicAddress {
    string address  = "";
    if (monero_wallet) {
        address = monero_wallet->address();
    }
    return objc_str_dup(address);
}

- (uint64_t)balance {
    if (monero_wallet) {
        return monero_wallet->balance();
    }
    return 0;
}

- (uint64_t)unlockedBalance {
    if (monero_wallet) {
        return monero_wallet->unlockedBalance();
    }
    return 0;
}

- (uint64_t)blockChainHeight {
    if (monero_wallet) {
        return monero_wallet->blockChainHeight();
    }
    return 0;
}

- (uint64_t)daemonBlockChainHeight {
    if (monero_wallet) {
        return monero_wallet->daemonBlockChainHeight();
    }
    return 0;
}

- (uint64_t)restoreHeight {
    if (monero_wallet) {
        return monero_wallet->getRefreshFromBlockHeight();
    }
    return 0;
}


@end
