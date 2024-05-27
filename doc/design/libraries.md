# Libraries

| Name                     | Description |
|--------------------------|-------------|
| *libalphacash_cli*         | RPC client functionality used by *alphacash-cli* executable |
| *libalphacash_common*      | Home for common functionality shared by different executables and libraries. Similar to *libalphacash_util*, but higher-level (see [Dependencies](#dependencies)). |
| *libalphacash_consensus*   | Stable, backwards-compatible consensus functionality used by *libalphacash_node* and *libalphacash_wallet*. |
| *libalphacash_kernel*      | Consensus engine and support library used for validation by *libalphacash_node*. |
| *libalphacashqt*           | GUI functionality used by *alphacash-qt* and *alphacash-gui* executables. |
| *libalphacash_ipc*         | IPC functionality used by *alphacash-node*, *alphacash-wallet*, *alphacash-gui* executables to communicate when [`--enable-multiprocess`](multiprocess.md) is used. |
| *libalphacash_node*        | P2P and RPC server functionality used by *alphacashd* and *alphacash-qt* executables. |
| *libalphacash_util*        | Home for common functionality shared by different executables and libraries. Similar to *libalphacash_common*, but lower-level (see [Dependencies](#dependencies)). |
| *libalphacash_wallet*      | Wallet functionality used by *alphacashd* and *alphacash-wallet* executables. |
| *libalphacash_wallet_tool* | Lower-level wallet functionality used by *alphacash-wallet* executable. |
| *libalphacash_zmq*         | [ZeroMQ](../zmq.md) functionality used by *alphacashd* and *alphacash-qt* executables. |

## Conventions

- Most libraries are internal libraries and have APIs which are completely unstable! There are few or no restrictions on backwards compatibility or rules about external dependencies. An exception is *libalphacash_kernel*, which, at some future point, will have a documented external interface.

- Generally each library should have a corresponding source directory and namespace. Source code organization is a work in progress, so it is true that some namespaces are applied inconsistently, and if you look at [`libalphacash_*_SOURCES`](../../src/Makefile.am) lists you can see that many libraries pull in files from outside their source directory. But when working with libraries, it is good to follow a consistent pattern like:

  - *libalphacash_node* code lives in `src/node/` in the `node::` namespace
  - *libalphacash_wallet* code lives in `src/wallet/` in the `wallet::` namespace
  - *libalphacash_ipc* code lives in `src/ipc/` in the `ipc::` namespace
  - *libalphacash_util* code lives in `src/util/` in the `util::` namespace
  - *libalphacash_consensus* code lives in `src/consensus/` in the `Consensus::` namespace

## Dependencies

- Libraries should minimize what other libraries they depend on, and only reference symbols following the arrows shown in the dependency graph below:

<table><tr><td>

```mermaid

%%{ init : { "flowchart" : { "curve" : "basis" }}}%%

graph TD;

alphacash-cli[alphacash-cli]-->libalphacash_cli;

alphacashd[alphacashd]-->libalphacash_node;
alphacashd[alphacashd]-->libalphacash_wallet;

alphacash-qt[alphacash-qt]-->libalphacash_node;
alphacash-qt[alphacash-qt]-->libalphacashqt;
alphacash-qt[alphacash-qt]-->libalphacash_wallet;

alphacash-wallet[alphacash-wallet]-->libalphacash_wallet;
alphacash-wallet[alphacash-wallet]-->libalphacash_wallet_tool;

libalphacash_cli-->libalphacash_util;
libalphacash_cli-->libalphacash_common;

libalphacash_common-->libalphacash_consensus;
libalphacash_common-->libalphacash_util;

libalphacash_kernel-->libalphacash_consensus;
libalphacash_kernel-->libalphacash_util;

libalphacash_node-->libalphacash_consensus;
libalphacash_node-->libalphacash_kernel;
libalphacash_node-->libalphacash_common;
libalphacash_node-->libalphacash_util;

libalphacashqt-->libalphacash_common;
libalphacashqt-->libalphacash_util;

libalphacash_wallet-->libalphacash_common;
libalphacash_wallet-->libalphacash_util;

libalphacash_wallet_tool-->libalphacash_wallet;
libalphacash_wallet_tool-->libalphacash_util;

classDef bold stroke-width:2px, font-weight:bold, font-size: smaller;
class alphacash-qt,alphacashd,alphacash-cli,alphacash-wallet bold
```
</td></tr><tr><td>

**Dependency graph**. Arrows show linker symbol dependencies. *Consensus* lib depends on nothing. *Util* lib is depended on by everything. *Kernel* lib depends only on consensus and util.

</td></tr></table>

- The graph shows what _linker symbols_ (functions and variables) from each library other libraries can call and reference directly, but it is not a call graph. For example, there is no arrow connecting *libalphacash_wallet* and *libalphacash_node* libraries, because these libraries are intended to be modular and not depend on each other's internal implementation details. But wallet code is still able to call node code indirectly through the `interfaces::Chain` abstract class in [`interfaces/chain.h`](../../src/interfaces/chain.h) and node code calls wallet code through the `interfaces::ChainClient` and `interfaces::Chain::Notifications` abstract classes in the same file. In general, defining abstract classes in [`src/interfaces/`](../../src/interfaces/) can be a convenient way of avoiding unwanted direct dependencies or circular dependencies between libraries.

- *libalphacash_consensus* should be a standalone dependency that any library can depend on, and it should not depend on any other libraries itself.

- *libalphacash_util* should also be a standalone dependency that any library can depend on, and it should not depend on other internal libraries.

- *libalphacash_common* should serve a similar function as *libalphacash_util* and be a place for miscellaneous code used by various daemon, GUI, and CLI applications and libraries to live. It should not depend on anything other than *libalphacash_util* and *libalphacash_consensus*. The boundary between _util_ and _common_ is a little fuzzy but historically _util_ has been used for more generic, lower-level things like parsing hex, and _common_ has been used for alphacash-specific, higher-level things like parsing base58. The difference between util and common is mostly important because *libalphacash_kernel* is not supposed to depend on *libalphacash_common*, only *libalphacash_util*. In general, if it is ever unclear whether it is better to add code to *util* or *common*, it is probably better to add it to *common* unless it is very generically useful or useful particularly to include in the kernel.


- *libalphacash_kernel* should only depend on *libalphacash_util* and *libalphacash_consensus*.

- The only thing that should depend on *libalphacash_kernel* internally should be *libalphacash_node*. GUI and wallet libraries *libalphacashqt* and *libalphacash_wallet* in particular should not depend on *libalphacash_kernel* and the unneeded functionality it would pull in, like block validation. To the extent that GUI and wallet code need scripting and signing functionality, they should be get able it from *libalphacash_consensus*, *libalphacash_common*, and *libalphacash_util*, instead of *libalphacash_kernel*.

- GUI, node, and wallet code internal implementations should all be independent of each other, and the *libalphacashqt*, *libalphacash_node*, *libalphacash_wallet* libraries should never reference each other's symbols. They should only call each other through [`src/interfaces/`](../../src/interfaces/) abstract interfaces.

## Work in progress

- Validation code is moving from *libalphacash_node* to *libalphacash_kernel* as part of [The libalphacashkernel Project #24303](https://github.com/alphacash/alphacash/issues/24303)
- Source code organization is discussed in general in [Library source code organization #15732](https://github.com/alphacash/alphacash/issues/15732)
