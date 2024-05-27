// Copyright (c) 2011-2020 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef ALPHACASH_QT_ALPHACASHADDRESSVALIDATOR_H
#define ALPHACASH_QT_ALPHACASHADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class AlphacashAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit AlphacashAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

/** Alphacash address widget validator, checks for a valid alphacash address.
 */
class AlphacashAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit AlphacashAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

#endif // ALPHACASH_QT_ALPHACASHADDRESSVALIDATOR_H
