//
//  moneroWrapper.hpp
//

#ifndef moneroWrapper_h
#define moneroWrapper_h

#include "stdbool.h"
#include "stdint.h"
#include "time.h"
#include <uuid/uuid.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    enum monero_status {
        Status_Ok,
        Status_Error,
        Status_Critical
    };
    
    enum monero_connectionStatus {
        ConnectionStatus_Disconnected,
        ConnectionStatus_Connected,
        ConnectionStatus_WrongVersion
    };

    enum monero_trxDirection
    {
        Direction_In,
        Direction_Out
    };
    
    enum monero_pendingTransactionPriority {
        PendingTransactionPriority_Default = 0,
        PendingTransactionPriority_Low = 1,
        PendingTransactionPriority_Medium = 2,
        PendingTransactionPriority_High = 3,
        PendingTransactionPriority_Last
    };
    
    struct monero_trx
    {
        enum monero_trxDirection direction;
        bool isPending;
        bool isFailed;
        uint64_t amount;
        uint64_t fee;
        uint64_t blockHeight;
        const char *label;
        uint64_t confirmations;
        time_t timestamp;
        uint64_t unlockTime;
        const char *hash;
        const char *paymentId;
        const char *address;
    };
    
    struct monero_history
    {
        uint64_t numberOfTransactions;
        struct monero_trx** transactions;
    };
    
    typedef void (*callbackActionRefreshed)(void*);
    typedef void (*callbackActionNewBlock)(void*, uint64_t curreneight, uint64_t blockChainHeight);

    // Init wallet
    // ----------------------------------------------------------------------------

    bool monero_createWalletFromScatch(const char* pathWithFileName,
                                       const char* password,
                                       const char* language);
    bool monero_recoverWalletFromSeed(const char* pathWithFileName,
                                      const char* seed,
                                      const char* password);
    bool monero_recoverWalletFromKeys(const char* pathWithFileName,
                                      const char* password,
                                      const char* language,
                                      uint64_t restoreHeight,
                                      const char* addressString,
                                      const char* viewKeyString,
                                      const char* spendKeyString);
    bool monero_openExistingWallet(const char* pathWithFileName,
                                   const char* password);
    bool monero_closeWallet();

    bool monero_init(const char* daemonAddress,
                     uint64_t upperTransactionSizeLimit,
                     const char* daemonUsername,    // provide "" for no username
                     const char* daemonPassword);   // provide "" for no password
    
    void monero_registerListenerCallbacks(void* handlerClass,
                                          callbackActionRefreshed refreshedHandler,
                                          callbackActionNewBlock newBlockHandler);
    void monero_deregisterListenerCallbacks();

    // Wallet info
    // ----------------------------------------------------------------------------
    const char* monero_getPublicViewKey();
    const char* monero_getPublicSpendKey();
    const char* monero_getSecretViewKey();
    const char* monero_getSecretSpendKey();
    const char* monero_getPublicAddress();
    const char* monero_getSeed(const char* language);
    enum monero_connectionStatus connectionStatus();
    int monero_status();
    const char* monero_errorString();
    uint64_t monero_getBlockchainHeight();
    uint64_t monero_getDaemonBlockChainHeight();
    void monero_setRestoreHeight(uint64_t height);
    uint64_t monero_getRestoreHeight();
    
    // Wallet actions
    // ----------------------------------------------------------------------------

    void monero_startRefresh();
    void monero_pauseRefresh();
    void monero_stopRefresh();
    void monero_refresh();
    bool monero_store(const char* pathWithFileName);
    bool monero_setNewPassword(const char* newPassword);

    // Wallet Balance
    // ----------------------------------------------------------------------------

    uint64_t monero_getBalance();
    uint64_t monero_getUnlockedBalance();
    struct monero_history* monero_getTrxHistory();
    void monero_deleteHistory(struct monero_history* history);
    
    // Transactions
    // ----------------------------------------------------------------------------

    bool monero_createTransaction(const char* dstAddress,
                                     const char* paymentId,
                                     uint64_t amount,
                                     uint32_t mixinCount,
                                     enum monero_pendingTransactionPriority priority);
    bool monero_createSweepTransaction(const char* dstAddress,
                                          const char* paymentId,
                                          uint32_t mixinCount,
                                          enum monero_pendingTransactionPriority priority);
    
    int64_t monero_getTransactionFee();
    
    void monero_disposeTransaction();
    
    bool monero_commitPendingTransaction();
    
    const char* monero_commitPendingTransactionErrorString();
    
    const char* monero_getPatmentId();
    
    const char* monero_getIntegartedAddress(const char* payment_id);
    
    // Helpers
    // ----------------------------------------------------------------------------
    bool monero_isSynchronized();
    bool monero_isValidWalletAddress(const char* walletAddress);
    bool monero_isValidPaymentId(const char* paymentId);
    bool monero_verifyPassword(const char* pathWithFileNamem, const char* password);
    
    void monero_printBlockChainHeight();
    
    uint64_t monero_getAmountFromString(const char* str);
    const char* monero_displayAmount(uint64_t amount);

#ifdef __cplusplus
}
#endif

#endif /* moneroWrapper_h */
