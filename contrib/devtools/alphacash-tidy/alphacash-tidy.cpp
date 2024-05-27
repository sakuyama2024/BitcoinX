// Copyright (c) 2023 Alphacash Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "logprintf.h"

#include <clang-tidy/ClangTidyModule.h>
#include <clang-tidy/ClangTidyModuleRegistry.h>

class AlphacashModule final : public clang::tidy::ClangTidyModule
{
public:
    void addCheckFactories(clang::tidy::ClangTidyCheckFactories& CheckFactories) override
    {
        CheckFactories.registerCheck<alphacash::LogPrintfCheck>("alphacash-unterminated-logprintf");
    }
};

static clang::tidy::ClangTidyModuleRegistry::Add<AlphacashModule>
    X("alphacash-module", "Adds alphacash checks.");

volatile int AlphacashModuleAnchorSource = 0;
