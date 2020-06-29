//
//  MoneroMacros.h
//  Wookey
//
//  Created by WookeyWallet on 2020/4/27.
//  Copyright © 2020 Wookey. All rights reserved.
//

#import "wallet2_api.h"

#pragma mark - const

const Monero::NetworkType netType = Monero::MAINNET;


#pragma mark - method

static NSString * objc_str_dup(std::string cppstr) {
    const char * cstr = cppstr.c_str();
    return [NSString stringWithUTF8String:strdup(cstr)];
};


#pragma mark - enum

enum monero_status {
    Status_Ok,
    Status_Error,
    Status_Critical
};


#pragma mark - struct


