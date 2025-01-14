# beacon_chain
# Copyright (c) 2023 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at https://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at https://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

when (NimMajor, NimMinor) < (1, 4):
  {.push raises: [Defect].}
else:
  {.push raises: [].}

import
  ./datatypes/[phase0, altair, bellatrix, capella, eip4844],
  ./eth2_merkleization

type
  LightClientDataFork* {.pure.} = enum  # Append only, used in DB data!
    None = 0,  # only use non-0 in DB to detect accidentally uninitialized data
    Altair = 1,
    Capella = 2

  ForkyLightClientHeader* =
    altair.LightClientHeader |
    capella.LightClientHeader

  ForkyLightClientBootstrap* =
    altair.LightClientBootstrap |
    capella.LightClientBootstrap

  ForkyLightClientUpdate* =
    altair.LightClientUpdate |
    capella.LightClientUpdate

  ForkyLightClientFinalityUpdate* =
    altair.LightClientFinalityUpdate |
    capella.LightClientFinalityUpdate

  ForkyLightClientOptimisticUpdate* =
    altair.LightClientOptimisticUpdate |
    capella.LightClientOptimisticUpdate

  SomeForkyLightClientUpdateWithSyncCommittee* =
    ForkyLightClientUpdate

  SomeForkyLightClientUpdateWithFinality* =
    ForkyLightClientUpdate |
    ForkyLightClientFinalityUpdate

  SomeForkyLightClientUpdate* =
    ForkyLightClientUpdate |
    ForkyLightClientFinalityUpdate |
    ForkyLightClientOptimisticUpdate

  SomeForkyLightClientObject* =
    ForkyLightClientBootstrap |
    SomeForkyLightClientUpdate

  ForkyLightClientStore* =
    altair.LightClientStore |
    capella.LightClientStore

  ForkedLightClientHeader* = object
    case kind*: LightClientDataFork
    of LightClientDataFork.None:
      discard
    of LightClientDataFork.Altair:
      altairData*: altair.LightClientHeader
    of LightClientDataFork.Capella:
      capellaData*: capella.LightClientHeader

  ForkedLightClientBootstrap* = object
    case kind*: LightClientDataFork
    of LightClientDataFork.None:
      discard
    of LightClientDataFork.Altair:
      altairData*: altair.LightClientBootstrap
    of LightClientDataFork.Capella:
      capellaData*: capella.LightClientBootstrap

  ForkedLightClientUpdate* = object
    case kind*: LightClientDataFork
    of LightClientDataFork.None:
      discard
    of LightClientDataFork.Altair:
      altairData*: altair.LightClientUpdate
    of LightClientDataFork.Capella:
      capellaData*: capella.LightClientUpdate

  ForkedLightClientFinalityUpdate* = object
    case kind*: LightClientDataFork
    of LightClientDataFork.None:
      discard
    of LightClientDataFork.Altair:
      altairData*: altair.LightClientFinalityUpdate
    of LightClientDataFork.Capella:
      capellaData*: capella.LightClientFinalityUpdate

  ForkedLightClientOptimisticUpdate* = object
    case kind*: LightClientDataFork
    of LightClientDataFork.None:
      discard
    of LightClientDataFork.Altair:
      altairData*: altair.LightClientOptimisticUpdate
    of LightClientDataFork.Capella:
      capellaData*: capella.LightClientOptimisticUpdate

  SomeForkedLightClientUpdateWithSyncCommittee* =
    ForkedLightClientUpdate

  SomeForkedLightClientUpdateWithFinality* =
    ForkedLightClientUpdate |
    ForkedLightClientFinalityUpdate

  SomeForkedLightClientUpdate* =
    ForkedLightClientUpdate |
    ForkedLightClientFinalityUpdate |
    ForkedLightClientOptimisticUpdate

  SomeForkedLightClientObject* =
    ForkedLightClientBootstrap |
    SomeForkedLightClientUpdate

  ForkedLightClientStore* = object
    case kind*: LightClientDataFork
    of LightClientDataFork.None:
      discard
    of LightClientDataFork.Altair:
      altairData*: altair.LightClientStore
    of LightClientDataFork.Capella:
      capellaData*: capella.LightClientStore

func lcDataForkAtEpoch*(
    cfg: RuntimeConfig, epoch: Epoch): LightClientDataFork =
  static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
  if epoch >= cfg.CAPELLA_FORK_EPOCH:
    LightClientDataFork.Capella
  elif epoch >= cfg.ALTAIR_FORK_EPOCH:
    LightClientDataFork.Altair
  else:
    LightClientDataFork.None

template kind*(
    x: typedesc[ # `SomeLightClientObject` doesn't work here (Nim 1.6)
      altair.LightClientHeader |
      altair.LightClientBootstrap |
      altair.LightClientUpdate |
      altair.LightClientFinalityUpdate |
      altair.LightClientOptimisticUpdate |
      altair.LightClientStore]): LightClientDataFork =
  LightClientDataFork.Altair

template kind*(
    x: typedesc[ # `SomeLightClientObject` doesn't work here (Nim 1.6)
      capella.LightClientHeader |
      capella.LightClientBootstrap |
      capella.LightClientUpdate |
      capella.LightClientFinalityUpdate |
      capella.LightClientOptimisticUpdate |
      capella.LightClientStore]): LightClientDataFork =
  LightClientDataFork.Capella

template LightClientHeader*(kind: static LightClientDataFork): auto =
  when kind == LightClientDataFork.Capella:
    typedesc[capella.LightClientHeader]
  elif kind == LightClientDataFork.Altair:
    typedesc[altair.LightClientHeader]
  else:
    static: raiseAssert "Unreachable"

template LightClientBootstrap*(kind: static LightClientDataFork): auto =
  when kind == LightClientDataFork.Capella:
    typedesc[capella.LightClientBootstrap]
  elif kind == LightClientDataFork.Altair:
    typedesc[altair.LightClientBootstrap]
  else:
    static: raiseAssert "Unreachable"

template LightClientUpdate*(kind: static LightClientDataFork): auto =
  when kind == LightClientDataFork.Capella:
    typedesc[capella.LightClientUpdate]
  elif kind == LightClientDataFork.Altair:
    typedesc[altair.LightClientUpdate]
  else:
    static: raiseAssert "Unreachable"

template LightClientFinalityUpdate*(kind: static LightClientDataFork): auto =
  when kind == LightClientDataFork.Capella:
    typedesc[capella.LightClientFinalityUpdate]
  elif kind == LightClientDataFork.Altair:
    typedesc[altair.LightClientFinalityUpdate]
  else:
    static: raiseAssert "Unreachable"

template LightClientOptimisticUpdate*(kind: static LightClientDataFork): auto =
  when kind == LightClientDataFork.Capella:
    typedesc[capella.LightClientOptimisticUpdate]
  elif kind == LightClientDataFork.Altair:
    typedesc[altair.LightClientOptimisticUpdate]
  else:
    static: raiseAssert "Unreachable"

template LightClientStore*(kind: static LightClientDataFork): auto =
  when kind == LightClientDataFork.Capella:
    typedesc[capella.LightClientStore]
  elif kind == LightClientDataFork.Altair:
    typedesc[altair.LightClientStore]
  else:
    static: raiseAssert "Unreachable"

template Forky*(
    x: typedesc[ForkedLightClientHeader],
    kind: static LightClientDataFork): auto =
  kind.LightClientHeader

template Forky*(
    x: typedesc[ForkedLightClientBootstrap],
    kind: static LightClientDataFork): auto =
  kind.LightClientBootstrap

template Forky*(
    x: typedesc[ForkedLightClientUpdate],
    kind: static LightClientDataFork): auto =
  kind.LightClientUpdate

template Forky*(
    x: typedesc[ForkedLightClientFinalityUpdate],
    kind: static LightClientDataFork): auto =
  kind.LightClientFinalityUpdate

template Forky*(
    x: typedesc[ForkedLightClientOptimisticUpdate],
    kind: static LightClientDataFork): auto =
  kind.LightClientOptimisticUpdate

template Forky*(
    x: typedesc[ForkedLightClientStore],
    kind: static LightClientDataFork): auto =
  kind.LightClientStore

template Forked*(x: typedesc[ForkyLightClientHeader]): auto =
  typedesc[ForkedLightClientHeader]

template Forked*(x: typedesc[ForkyLightClientBootstrap]): auto =
  typedesc[ForkedLightClientBootstrap]

template Forked*(x: typedesc[ForkyLightClientUpdate]): auto =
  typedesc[ForkedLightClientUpdate]

template Forked*(x: typedesc[ForkyLightClientFinalityUpdate]): auto =
  typedesc[ForkedLightClientFinalityUpdate]

template Forked*(x: typedesc[ForkyLightClientOptimisticUpdate]): auto =
  typedesc[ForkedLightClientOptimisticUpdate]

template Forked*(x: typedesc[ForkyLightClientStore]): auto =
  typedesc[ForkedLightClientStore]

template withAll*(
    x: typedesc[LightClientDataFork], body: untyped): untyped =
  static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
  block:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    body
  block:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    body
  block:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withLcDataFork*(
    x: LightClientDataFork, body: untyped): untyped =
  case x
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withForkyHeader*(
    x: ForkedLightClientHeader, body: untyped): untyped =
  case x.kind
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    template forkyHeader: untyped {.inject, used.} = x.capellaData
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    template forkyHeader: untyped {.inject, used.} = x.altairData
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withForkyBootstrap*(
    x: ForkedLightClientBootstrap, body: untyped): untyped =
  case x.kind
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    template forkyBootstrap: untyped {.inject, used.} = x.capellaData
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    template forkyBootstrap: untyped {.inject, used.} = x.altairData
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withForkyUpdate*(
    x: ForkedLightClientUpdate, body: untyped): untyped =
  case x.kind
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    template forkyUpdate: untyped {.inject, used.} = x.capellaData
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    template forkyUpdate: untyped {.inject, used.} = x.altairData
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withForkyFinalityUpdate*(
    x: ForkedLightClientFinalityUpdate, body: untyped): untyped =
  case x.kind
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    template forkyFinalityUpdate: untyped {.inject, used.} = x.capellaData
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    template forkyFinalityUpdate: untyped {.inject, used.} = x.altairData
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withForkyOptimisticUpdate*(
    x: ForkedLightClientOptimisticUpdate, body: untyped): untyped =
  case x.kind
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    template forkyOptimisticUpdate: untyped {.inject, used.} = x.capellaData
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    template forkyOptimisticUpdate: untyped {.inject, used.} = x.altairData
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withForkyObject*(
    x: SomeForkedLightClientObject, body: untyped): untyped =
  case x.kind
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    template forkyObject: untyped {.inject, used.} = x.capellaData
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    template forkyObject: untyped {.inject, used.} = x.altairData
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template withForkyStore*(
    x: ForkedLightClientStore, body: untyped): untyped =
  case x.kind
  of LightClientDataFork.Capella:
    const lcDataFork {.inject, used.} = LightClientDataFork.Capella
    template forkyStore: untyped {.inject, used.} = x.capellaData
    body
  of LightClientDataFork.Altair:
    const lcDataFork {.inject, used.} = LightClientDataFork.Altair
    template forkyStore: untyped {.inject, used.} = x.altairData
    body
  of LightClientDataFork.None:
    const lcDataFork {.inject, used.} = LightClientDataFork.None
    body

template toFull*(
    update: SomeForkedLightClientUpdate): ForkedLightClientUpdate =
  when update is ForkyLightClientUpdate:
    update
  else:
    withForkyObject(update):
      when lcDataFork > LightClientDataFork.None:
        var res = ForkedLightClientUpdate(kind: lcDataFork)
        template forkyRes: untyped = res.forky(lcDataFork)
        forkyRes = forkyObject.toFull()
        res
      else:
        default(ForkedLightClientUpdate)

template toFinality*(
    update: SomeForkedLightClientUpdate): ForkedLightClientFinalityUpdate =
  when update is ForkyLightClientFinalityUpdate:
    update
  else:
    withForkyObject(update):
      when lcDataFork > LightClientDataFork.None:
        var res = ForkedLightClientFinalityUpdate(kind: lcDataFork)
        template forkyRes: untyped = res.forky(lcDataFork)
        forkyRes = forkyObject.toFinality()
        res
      else:
        default(ForkedLightClientFinalityUpdate)

template toOptimistic*(
    update: SomeForkedLightClientUpdate): ForkedLightClientOptimisticUpdate =
  when update is ForkyLightClientOptimisticUpdate:
    update
  else:
    withForkyObject(update):
      when lcDataFork > LightClientDataFork.None:
        var res = ForkedLightClientOptimisticUpdate(kind: lcDataFork)
        template forkyRes: untyped = res.forky(lcDataFork)
        forkyRes = forkyObject.toOptimistic()
        res
      else:
        default(ForkedLightClientOptimisticUpdate)

func matches*[A, B: SomeForkedLightClientUpdate](a: A, b: B): bool =
  if a.kind != b.kind:
    return false
  withForkyObject(a):
    when lcDataFork > LightClientDataFork.None:
      forkyObject.matches(b.forky(lcDataFork))
    else:
      true

template forky*(
    x:
      ForkedLightClientHeader |
      SomeForkedLightClientObject |
      ForkedLightClientStore,
    kind: static LightClientDataFork): untyped =
  when kind == LightClientDataFork.Capella:
    x.capellaData
  elif kind == LightClientDataFork.Altair:
    x.altairData
  else:
    static: raiseAssert "Unreachable"

func migrateToDataFork*(
    x: var ForkedLightClientHeader,
    newKind: static LightClientDataFork) =
  if newKind == x.kind:
    # Already at correct kind
    discard
  elif newKind < x.kind:
    # Downgrade not supported, re-initialize
    x = ForkedLightClientHeader(kind: newKind)
  else:
    # Upgrade to Altair
    when newKind >= LightClientDataFork.Altair:
      if x.kind == LightClientDataFork.None:
        x = ForkedLightClientHeader(
          kind: LightClientDataFork.Altair)

    # Upgrade to Capella
    when newKind >= LightClientDataFork.Capella:
      if x.kind == LightClientDataFork.Altair:
        x = ForkedLightClientHeader(
          kind: LightClientDataFork.Capella,
          capellaData: upgrade_lc_header_to_capella(
            x.forky(LightClientDataFork.Altair)))

    static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
    doAssert x.kind == newKind

func migrateToDataFork*(
    x: var ForkedLightClientBootstrap,
    newKind: static LightClientDataFork) =
  if newKind == x.kind:
    # Already at correct kind
    discard
  elif newKind < x.kind:
    # Downgrade not supported, re-initialize
    x = ForkedLightClientBootstrap(kind: newKind)
  else:
    # Upgrade to Altair
    when newKind >= LightClientDataFork.Altair:
      if x.kind == LightClientDataFork.None:
        x = ForkedLightClientBootstrap(
          kind: LightClientDataFork.Altair)

    # Upgrade to Capella
    when newKind >= LightClientDataFork.Capella:
      if x.kind == LightClientDataFork.Altair:
        x = ForkedLightClientBootstrap(
          kind: LightClientDataFork.Capella,
          capellaData: upgrade_lc_bootstrap_to_capella(
            x.forky(LightClientDataFork.Altair)))

    static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
    doAssert x.kind == newKind

func migrateToDataFork*(
    x: var ForkedLightClientUpdate,
    newKind: static LightClientDataFork) =
  if newKind == x.kind:
    # Already at correct kind
    discard
  elif newKind < x.kind:
    # Downgrade not supported, re-initialize
    x = ForkedLightClientUpdate(kind: newKind)
  else:
    # Upgrade to Altair
    when newKind >= LightClientDataFork.Altair:
      if x.kind == LightClientDataFork.None:
        x = ForkedLightClientUpdate(
          kind: LightClientDataFork.Altair)

    # Upgrade to Capella
    when newKind >= LightClientDataFork.Capella:
      if x.kind == LightClientDataFork.Altair:
        x = ForkedLightClientUpdate(
          kind: LightClientDataFork.Capella,
          capellaData: upgrade_lc_update_to_capella(
            x.forky(LightClientDataFork.Altair)))

    static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
    doAssert x.kind == newKind

func migrateToDataFork*(
    x: var ForkedLightClientFinalityUpdate,
    newKind: static LightClientDataFork) =
  if newKind == x.kind:
    # Already at correct kind
    discard
  elif newKind < x.kind:
    # Downgrade not supported, re-initialize
    x = ForkedLightClientFinalityUpdate(kind: newKind)
  else:
    # Upgrade to Altair
    when newKind >= LightClientDataFork.Altair:
      if x.kind == LightClientDataFork.None:
        x = ForkedLightClientFinalityUpdate(
          kind: LightClientDataFork.Altair)

    # Upgrade to Capella
    when newKind >= LightClientDataFork.Capella:
      if x.kind == LightClientDataFork.Altair:
        x = ForkedLightClientFinalityUpdate(
          kind: LightClientDataFork.Capella,
          capellaData: upgrade_lc_finality_update_to_capella(
            x.forky(LightClientDataFork.Altair)))

    static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
    doAssert x.kind == newKind

func migrateToDataFork*(
    x: var ForkedLightClientOptimisticUpdate,
    newKind: static LightClientDataFork) =
  if newKind == x.kind:
    # Already at correct kind
    discard
  elif newKind < x.kind:
    # Downgrade not supported, re-initialize
    x = ForkedLightClientOptimisticUpdate(kind: newKind)
  else:
    # Upgrade to Altair
    when newKind >= LightClientDataFork.Altair:
      if x.kind == LightClientDataFork.None:
        x = ForkedLightClientOptimisticUpdate(
          kind: LightClientDataFork.Altair)

    # Upgrade to Capella
    when newKind >= LightClientDataFork.Capella:
      if x.kind == LightClientDataFork.Altair:
        x = ForkedLightClientOptimisticUpdate(
          kind: LightClientDataFork.Capella,
          capellaData: upgrade_lc_optimistic_update_to_capella(
            x.forky(LightClientDataFork.Altair)))

    static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
    doAssert x.kind == newKind

func migrateToDataFork*(
    x: var ForkedLightClientStore,
    newKind: static LightClientDataFork) =
  if newKind == x.kind:
    # Already at correct kind
    discard
  elif newKind < x.kind:
    # Downgrade not supported, re-initialize
    x = ForkedLightClientStore(kind: newKind)
  else:
    # Upgrade to Altair
    when newKind >= LightClientDataFork.Altair:
      if x.kind == LightClientDataFork.None:
        x = ForkedLightClientStore(
          kind: LightClientDataFork.Altair)

    # Upgrade to Capella
    when newKind >= LightClientDataFork.Capella:
      if x.kind == LightClientDataFork.Altair:
        x = ForkedLightClientStore(
          kind: LightClientDataFork.Capella,
          capellaData: upgrade_lc_store_to_capella(
            x.forky(LightClientDataFork.Altair)))

    static: doAssert LightClientDataFork.high == LightClientDataFork.Capella
    doAssert x.kind == newKind

func migratingToDataFork*[
    T:
      ForkedLightClientHeader |
      SomeForkedLightClientObject |
      ForkedLightClientStore](
    x: T, newKind: static LightClientDataFork): T =
  var upgradedObject = x
  upgradedObject.migrateToDataFork(newKind)
  upgradedObject

# https://github.com/ethereum/consensus-specs/blob/v1.3.0-rc.1/specs/altair/light-client/full-node.md#block_to_light_client_header
func toAltairLightClientHeader(
    blck:  # `SomeSignedBeaconBlock` doesn't work here (Nim 1.6)
      phase0.SignedBeaconBlock | phase0.TrustedSignedBeaconBlock |
      altair.SignedBeaconBlock | altair.TrustedSignedBeaconBlock |
      bellatrix.SignedBeaconBlock | bellatrix.TrustedSignedBeaconBlock
): altair.LightClientHeader =
  altair.LightClientHeader(
    beacon: blck.message.toBeaconBlockHeader())

# https://github.com/ethereum/consensus-specs/blob/v1.3.0-rc.1/specs/capella/light-client/full-node.md#block_to_light_client_header
func toCapellaLightClientHeader(
    blck:  # `SomeSignedBeaconBlock` doesn't work here (Nim 1.6)
      phase0.SignedBeaconBlock | phase0.TrustedSignedBeaconBlock |
      altair.SignedBeaconBlock | altair.TrustedSignedBeaconBlock |
      bellatrix.SignedBeaconBlock | bellatrix.TrustedSignedBeaconBlock
): capella.LightClientHeader =
  # Note that during fork transitions, `finalized_header` may still
  # point to earlier forks. While Bellatrix blocks also contain an
  # `ExecutionPayload` (minus `withdrawals_root`), it was not included
  # in the corresponding light client data. To ensure compatibility
  # with legacy data going through `upgrade_lc_header_to_capella`,
  # leave out execution data.
  capella.LightClientHeader(
    beacon: blck.message.toBeaconBlockHeader())

func toCapellaLightClientHeader(
    blck:  # `SomeSignedBeaconBlock` doesn't work here (Nim 1.6)
      capella.SignedBeaconBlock | capella.TrustedSignedBeaconBlock |
      eip4844.SignedBeaconBlock | eip4844.TrustedSignedBeaconBlock
): capella.LightClientHeader =
  template payload: untyped = blck.message.body.execution_payload
  capella.LightClientHeader(
    beacon: blck.message.toBeaconBlockHeader(),
    execution: capella.ExecutionPayloadHeader(
      parent_hash: payload.parent_hash,
      fee_recipient: payload.fee_recipient,
      state_root: payload.state_root,
      receipts_root: payload.receipts_root,
      logs_bloom: payload.logs_bloom,
      prev_randao: payload.prev_randao,
      block_number: payload.block_number,
      gas_limit: payload.gas_limit,
      gas_used: payload.gas_used,
      timestamp: payload.timestamp,
      extra_data: payload.extra_data,
      base_fee_per_gas: payload.base_fee_per_gas,
      block_hash: payload.block_hash,
      transactions_root: hash_tree_root(payload.transactions),
      withdrawals_root: hash_tree_root(payload.withdrawals)),
    execution_branch: blck.message.body.build_proof(
      capella.EXECUTION_PAYLOAD_INDEX).get)

func toLightClientHeader*(
    blck:  # `SomeSignedBeaconBlock` doesn't work here (Nim 1.6)
      phase0.SignedBeaconBlock | phase0.TrustedSignedBeaconBlock |
      altair.SignedBeaconBlock | altair.TrustedSignedBeaconBlock |
      bellatrix.SignedBeaconBlock | bellatrix.TrustedSignedBeaconBlock |
      capella.SignedBeaconBlock | capella.TrustedSignedBeaconBlock |
      eip4844.SignedBeaconBlock | eip4844.TrustedSignedBeaconBlock,
    kind: static LightClientDataFork): auto =
  when kind == LightClientDataFork.Capella:
    blck.toCapellaLightClientHeader()
  elif kind == LightClientDataFork.Altair:
    blck.toAltairLightClientHeader()
  else:
    static: raiseAssert "Unreachable"
