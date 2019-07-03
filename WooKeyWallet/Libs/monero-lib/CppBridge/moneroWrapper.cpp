//
//  moneroWrapper.cpp

//#include <boost/system/detail/error_code.ipp>

#include "moneroWrapper.h"
#include "wallet2_api.h"
#include <map>

const Monero::NetworkType networkType = Monero::MAINNET;

static Monero::Wallet* monero_wallet;


struct WalletListernerImplementation: Monero::WalletListener
{
    WalletListernerImplementation()
    {
        _refreshedHandler = nullptr;
    }
    
    virtual void moneySpent(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    virtual void moneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }

    virtual void newBlock(uint64_t height)
    {
        if (_newBlockHandler && monero_wallet) {
            _newBlockHandler(_handlerClass, height, monero_wallet->daemonBlockChainHeight());
        }
    }

    virtual void updated()
    {
        // not implemented
    }

    virtual void refreshed()
    {
        if (_refreshedHandler) {
            _refreshedHandler(_handlerClass);
        }
    }
    
    void registerCallbacks(void* handlerClass,
                           callbackActionRefreshed refreshedHandler,
                           callbackActionNewBlock newBlockHandler)
    {
        _handlerClass = handlerClass;
        _refreshedHandler = refreshedHandler;
        _newBlockHandler = newBlockHandler;
    }
    
private:
    callbackActionRefreshed _refreshedHandler = NULL;
    callbackActionNewBlock _newBlockHandler = NULL;
    void* _handlerClass = NULL;
};


static WalletListernerImplementation* monero_walletListener = nullptr;

Monero::WalletManagerFactory::LogLevel monero_logLevel = Monero::WalletManagerFactory::LogLevel_Silent;

bool monero_createWalletFromScatch(const char* pathWithFileName,
                                   const char* password,
                                   const char* language)
{
    Monero::WalletManagerFactory::setLogLevel(monero_logLevel);
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    
    monero_wallet = walletManager->createWallet(pathWithFileName, password, language, networkType);

    return monero_wallet->status() == Monero::Wallet::Status_Ok;
}

bool monero_recoverWalletFromSeed(const char* pathWithFileName,
                                  const char* seed,
                                  const char* password)
{
    Monero::WalletManagerFactory::setLogLevel(monero_logLevel);
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();

    monero_wallet = walletManager->recoveryWallet(pathWithFileName, password, seed, networkType, 0, 1);
    if (monero_wallet->status() != Monero::Wallet::Status_Ok) {
        return false;
    }
    return true;
    
//    bool setPasswordState = monero_wallet->setPassword(password);
//    return setPasswordState;
}

bool monero_recoverWalletFromKeys(const char* pathWithFileName,
                                  const char* password,
                                  const char* language,
                                  uint64_t restoreHeight,
                                  const char* addressString,
                                  const char* viewKeyString,
                                  const char* spendKeyString)
{
    Monero::WalletManagerFactory::setLogLevel(monero_logLevel);
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    monero_wallet = walletManager->createWalletFromKeys(pathWithFileName, password, language, networkType, restoreHeight, addressString, viewKeyString, spendKeyString);
    return monero_wallet->status() == Monero::Wallet::Status_Ok;
}

bool monero_openExistingWallet(const char* pathWithFileName, const char* password)
{
    monero_closeWallet();
    Monero::WalletManagerFactory::setLogLevel(monero_logLevel);
    Monero::WalletManagerFactory::setLogCategories("");
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    monero_wallet = walletManager->openWallet(pathWithFileName, password, networkType);
    return monero_wallet->status() == Monero::Wallet::Status_Ok;
}

bool monero_verifyPassword(const char* pathWithFileNamem, const char* password)
{
    Bitmonero::Wallet::Device device_type;
    return Bitmonero::WalletManagerFactory::getWalletManager()->queryWalletDevice(device_type, pathWithFileNamem, password);
}

bool monero_closeWallet()
{
    if (!monero_wallet) {
        return false;
    }
    struct Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    bool result = walletManager->closeWallet(monero_wallet, false);
    monero_wallet = nullptr;
    return result;
}

bool monero_isSynchronized()
{
    if (!monero_wallet) {
        return false;
    }
    return monero_wallet->synchronized();
}

const char* monero_getPublicViewKey()
{
    std::string key  = "";
    if (monero_wallet) {
        key = monero_wallet->publicViewKey();
    }
    const char* cstr = key.c_str();
    return strdup(cstr);
}

const char* monero_getPublicSpendKey()
{
    std::string key  = "";
    if (monero_wallet) {
        key = monero_wallet->publicSpendKey();
    }
    const char* cstr = key.c_str();
    return strdup(cstr);
}

const char* monero_getSecretViewKey()
{
    std::string secretViewKey  = "";
    if (monero_wallet) {
        secretViewKey = monero_wallet->secretViewKey();
    }
    const char* cstr = secretViewKey.c_str();
    return strdup(cstr);
}

const char* monero_getSecretSpendKey()
{
    std::string secretSpendKey  = "";
    if (monero_wallet) {
        secretSpendKey = monero_wallet->secretSpendKey();
    }
    const char* cstr = secretSpendKey.c_str();
    return strdup(cstr);
}

const char* monero_getPublicAddress()
{
    std::string publicAddress = "";
    
    if (monero_wallet) {
        publicAddress = monero_wallet->address();
    }
    
    const char* cstr = publicAddress.c_str();
    
    return strdup(cstr);
}

const char* monero_getSeed(const char* language)
{
    std::string seed = "";
    
    if (monero_wallet) {
        monero_wallet->setSeedLanguage(language);
        seed = monero_wallet->seed();
    }
    
    const char* cstr = seed.c_str();
    
    return strdup(cstr);
}

bool monero_init(const char* daemonAddress,
                 uint64_t upperTransactionSizeLimit,
                 const char* daemonUsername,
                 const char* daemonPassword)
{
    if (!monero_wallet) {
        return false;
    }
    
    bool status = monero_wallet->init(daemonAddress);
    return status;
}

void monero_registerListenerCallbacks(void* handlerClass,
                                      callbackActionRefreshed refreshedHandler,
                                      callbackActionNewBlock newBlockHandler)
{
    if (!monero_wallet) {
        return;
    }
    monero_deregisterListenerCallbacks();
    monero_walletListener = new WalletListernerImplementation();
    monero_walletListener->registerCallbacks(handlerClass, refreshedHandler, newBlockHandler);
    
    monero_wallet->setListener(monero_walletListener);
}

void monero_deregisterListenerCallbacks()
{
    if (!monero_wallet) {
        return;
    }
    monero_wallet->setListener(nullptr);
    if (monero_walletListener) {
        delete monero_walletListener;
    }
}


enum monero_connectionStatus connectionStatus()
{
    if (!monero_wallet) {
        return ConnectionStatus_Disconnected;
    }
    
    return (monero_connectionStatus)monero_wallet->connected();
}

int monero_status() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->status();
}

const char* monero_errorString() {
    std::string errorString = "";
    
    if (monero_wallet) {
        errorString = monero_wallet->errorString();
    }
    
    const char* cstr = errorString.c_str();
    
    return strdup(cstr);

}

void monero_startRefresh()
{
    if (monero_wallet) {
        monero_wallet->startRefresh();
    }
}

void monero_pauseRefresh()
{
    if (monero_wallet) {
        monero_wallet->pauseRefresh();
    }
}


void monero_refresh() {
    if (monero_wallet) {
        monero_wallet->refresh();
    }
}

bool monero_store(const char* pathWithFileName) {
    if (monero_wallet) {
        return monero_wallet->store(pathWithFileName);
    }
    return false;
}

bool monero_setNewPassword(const char* newPassword) {
    if (monero_wallet) {
        return monero_wallet->setPassword(newPassword);
    }
    return false;
}

uint64_t monero_getBalance()
{
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->balance();
}

uint64_t monero_getUnlockedBalance() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->unlockedBalance();
}

uint64_t monero_getBlockchainHeight() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->blockChainHeight();
}

uint64_t monero_getDaemonBlockChainHeight() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->daemonBlockChainHeight();
}

void monero_setRestoreHeight(uint64_t height) {
    if (!monero_wallet) {
        return;
    }
    monero_wallet->setRefreshFromBlockHeight(height);
}

uint64_t monero_getRestoreHeight() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->getRefreshFromBlockHeight();
}

monero_history* monero_getTrxHistory() {
    monero_history *moneroHistory = new monero_history;
    moneroHistory->numberOfTransactions = 0;

    if (!monero_wallet) {
        return moneroHistory;
    }
    
    Monero::TransactionHistory *history = monero_wallet->history();
    if (!history) {
        return moneroHistory;
    }
    
    history->refresh();
    
    std::vector<Monero::TransactionInfo *> allTransactionInfo = history->getAll();
    moneroHistory->numberOfTransactions = allTransactionInfo.size();
    moneroHistory->transactions = new monero_trx*[moneroHistory->numberOfTransactions];
    
    for (std::size_t i = 0; i < history->count(); ++i) {
        Monero::TransactionInfo *transactionInfo = allTransactionInfo[i];
        monero_trx *trx = new monero_trx;
        trx->direction = (monero_trxDirection)transactionInfo->direction();
        trx->isPending = transactionInfo->isPending();
        trx->isFailed = transactionInfo->isFailed();
        trx->amount = transactionInfo->amount();
        trx->fee = transactionInfo->fee();
        trx->confirmations = transactionInfo->confirmations();
        trx->timestamp = transactionInfo->timestamp();
        trx->blockHeight = transactionInfo->blockHeight();
        trx->hash = strdup(transactionInfo->hash().c_str());
        trx->label = strdup(transactionInfo->label().c_str());
        trx->paymentId = strdup(transactionInfo->paymentId().c_str());
        trx->unlockTime = transactionInfo->unlockTime();
        moneroHistory->transactions[i] = trx;
    }
    
    return moneroHistory;
}

const char* monero_getPatmentId()
{
    std::string payment_id = Monero::Wallet::genPaymentId();
    std::cout << ("[=========="+payment_id+"===========]");
    return strdup(payment_id.c_str());
}

const char* monero_getIntegartedAddress(const char* payment_id)
{
    std::string addr = "";
    if (monero_wallet) {
        addr = monero_wallet->integratedAddress(payment_id);
    }
    return strdup(addr.c_str());
}

void monero_deleteHistory(monero_history* history)
{
    if (history == nullptr) {
        return;
    }
    if (history->transactions != nullptr) {
        delete [] history->transactions;
    }
    
    delete history;
}

bool monero_isValidWalletAddress(const char* walletAddress)
{
    return Monero::Wallet::addressValid(walletAddress, networkType);
}

bool monero_isValidPaymentId(const char* paymentId)
{
    if (!monero_wallet) {
        return false;
    }
    
    return monero_wallet->paymentIdValid(paymentId);
}

uint64_t monero_getAmountFromString(const char* str)
{
    return Monero::Wallet::amountFromString(str);
}

const char* monero_displayAmount(uint64_t amount)
{
    std::string str = Monero::Wallet::displayAmount(amount);
    return strdup(str.c_str());
}

#pragma mark - SubAddress

bool monero_addSubAddress(uint32_t accountIndex, const char* label) {
    if (!monero_wallet) {
        return false;
    }
    monero_wallet->addSubaddress(accountIndex, label);
    return true;
}

monero_subAddress* monero_getAllSubAddress() {
    if (!monero_wallet) {
        return NULL;
    }
    Monero::Subaddress* subAddress = monero_wallet->subaddress();
    if (!subAddress) {
        return NULL;
    }
    
    subAddress->refresh(0);
    
    std::vector<Monero::SubaddressRow *> all = subAddress->getAll();
    std::size_t allCount = all.size();
    monero_subAddress *result = new monero_subAddress;
    result->count = allCount;
    result->list = new monero_subAddressRow*[allCount];
    for (std::size_t i = 0; i < allCount; ++i) {
        Monero::SubaddressRow *item = all[i];
        monero_subAddressRow *_item = new monero_subAddressRow;
        _item->rowId = item->getRowId();
        _item->address = strdup(item->getAddress().c_str());
        _item->label = strdup(item->getLabel().c_str());
        result->list[i] = _item;
    }
    return result;
}


#pragma mark - Transactions

static Monero::PendingTransaction* _pendingTransaction;

/// Returns a key which must be deleted after usage.
bool monero_createTransaction(const char* dstAddress,
                                 const char* paymentId,
                                 uint64_t amount,
                                 uint32_t mixinCount,
                                 enum monero_pendingTransactionPriority priority)
{
    if (!monero_wallet) {
        return false;
    }
    monero_disposeTransaction();
    Monero::optional<uint64_t> _amount;
    if (amount != -2019) {
        _amount = amount;
    }
    _pendingTransaction = monero_wallet->createTransaction
    (dstAddress,
     paymentId,
     _amount,
     mixinCount,
     (Monero::PendingTransaction::Priority)priority);
    
    if (!_pendingTransaction) {
        return false;
    }
    if (_pendingTransaction->status() != Status_Ok) {
        std::string err = _pendingTransaction->errorString();
        std::cout<<err;
        return false;
    }
    return true;
}

bool monero_createSweepTransaction(const char* dstAddress,
                                      const char* paymentId,
                                      uint32_t mixinCount,
                                      enum monero_pendingTransactionPriority priority)
{
    return monero_createTransaction(dstAddress, paymentId, -2019, mixinCount, priority);
}

int64_t monero_getTransactionFee()
{
    if (_pendingTransaction) {
        return _pendingTransaction->fee();
    }
    return -1;
}

void monero_disposeTransaction()
{
    if (monero_wallet && _pendingTransaction) {
        monero_wallet->disposeTransaction(_pendingTransaction);
        _pendingTransaction = NULL;
    }
}

bool monero_commitPendingTransaction()
{
    bool success = false;
    if (_pendingTransaction) {
        success = _pendingTransaction->commit();
    }
    return success;
}

const char* monero_commitPendingTransactionErrorString()
{
    const char* err_str = "Unkown";
    if (_pendingTransaction) {
        std::string cpp_err = _pendingTransaction->errorString();
        err_str = strdup(cpp_err.c_str());
    }
    return err_str;
}












