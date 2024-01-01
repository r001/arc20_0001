program arc20_0001.aleo;

record credits:
    owner as address.private;
    contract as address.private;
    microcredits as u64.private;

struct transfer_from:
    from as address;
    to as address;
    amount as u64;
    expire as u32;


mapping account:
	key as address.public;
	value as u64.public;


mapping total_supply:
	key as boolean.public;
	value as u64.public;

function transfer_public:
    input r0 as address.public;
    input r1 as u64.public;
    async transfer_public self.caller r0 r1 into r2;
    output r2 as arc20_0001.aleo/transfer_public.future;

finalize transfer_public:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    get account[r0] into r3;
    sub r3 r2 into r4;
    set r4 into account[r0];
    get.or_use account[r1] 0u64 into r5;
    add r5 r2 into r6;
    set r6 into account[r1];


function transfer_from_public:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as u32.public;
    input r4 as signature.private;
    cast r2 r0 r1 r3 into r5 as transfer_from;
    hash.bhp256 r5 into r6 as field;
    sign.verify r4 r2 r6 into r7;
    assert.eq r7 true;
    async transfer_from_public r0 r1 r2 r3 into r8;
    output r8 as arc20_0001.aleo/transfer_from_public.future;

finalize transfer_from_public:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as u32.public;
    lt block.height r3 into r4;
    assert.eq r4 true;
    get account[r2] into r5;
    sub r5 r1 into r6;
    set r6 into account[r2];
    get.or_use account[r0] 0u64 into r7;
    add r7 r1 into r8;
    set r8 into account[r0];


function transfer_private:
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as credits.record;
    is.eq self.caller self.signer into r3;
    is.eq r2.contract aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl into r4;
    not r3 into r5;
    or r5 r4 into r6;
    assert.eq r6 true;
    is.eq self.caller r2.contract into r7;
    is.eq self.signer r2.owner into r8;
    is.eq r2.contract aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl into r9;
    and r8 r9 into r10;
    or r7 r10 into r11;
    not r3 into r12;
    not r12 into r13;
    or r13 r11 into r14;
    assert.eq r14 true;
    sub r2.microcredits r1 into r15;
    cast r2.owner r2.contract r15 into r16 as credits.record;
    cast r0 aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl r1 into r17 as credits.record;
    output r16 as credits.record;
    output r17 as credits.record;


function transfer_private_contract:
    input r0 as address.private;
    input r1 as address.private;
    input r2 as u64.private;
    input r3 as credits.record;
    is.neq self.caller self.signer into r4;
    assert.eq r4 true;
    is.eq self.caller r3.contract into r5;
    is.eq self.signer r3.owner into r6;
    is.eq r3.contract aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl into r7;
    and r6 r7 into r8;
    or r5 r8 into r9;
    assert.eq r9 true;
    sub r3.microcredits r2 into r10;
    cast r3.owner r3.contract r10 into r11 as credits.record;
    cast r0 r1 r2 into r12 as credits.record;
    output r11 as credits.record;
    output r12 as credits.record;


function transfer_private_to_public:
    input r0 as credits.record;
    input r1 as address.public;
    input r2 as u64.public;
    is.eq self.caller self.signer into r3;
    is.eq r0.contract aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl into r4;
    not r3 into r5;
    or r5 r4 into r6;
    assert.eq r6 true;
    is.eq self.caller r0.contract into r7;
    is.eq self.signer r0.owner into r8;
    is.eq r0.contract aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl into r9;
    and r8 r9 into r10;
    or r7 r10 into r11;
    not r3 into r12;
    not r12 into r13;
    or r13 r11 into r14;
    assert.eq r14 true;
    sub r0.microcredits r2 into r15;
    cast r0.owner r0.contract r15 into r16 as credits.record;
    async transfer_private_to_public r1 r2 into r17;
    output r16 as credits.record;
    output r17 as arc20_0001.aleo/transfer_private_to_public.future;

finalize transfer_private_to_public:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into account[r0];


function transfer_public_to_private:
    input r0 as address.private;
    input r1 as u64.public;
    is.neq self.caller self.signer into r2;
    ternary r2 self.caller aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl into r3;
    cast r0 r3 r1 into r4 as credits.record;
    async transfer_public_to_private self.caller r0 r1 into r5;
    output r4 as credits.record;
    output r5 as arc20_0001.aleo/transfer_public_to_private.future;

finalize transfer_public_to_private:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    get account[r0] into r3;
    sub r3 r2 into r4;
    set r4 into account[r0];


function join:
    input r0 as credits.record;
    input r1 as credits.record;
    is.neq self.caller self.signer into r2;
    is.eq r0.contract self.caller into r3;
    is.eq r1.contract self.caller into r4;
    and r3 r4 into r5;
    not r2 into r6;
    or r6 r5 into r7;
    assert.eq r7 true;
    add r0.microcredits r1.microcredits into r8;
    cast r0.owner r0.contract r8 into r9 as credits.record;
    output r9 as credits.record;


function split:
    input r0 as credits.record;
    input r1 as u64.private;
    is.neq self.caller self.signer into r2;
    is.eq r0.contract self.caller into r3;
    not r2 into r4;
    or r4 r3 into r5;
    assert.eq r5 true;
    sub r0.microcredits r1 into r6;
    cast r0.owner r0.contract r6 into r7 as credits.record;
    cast r0.owner r0.contract r1 into r8 as credits.record;
    output r7 as credits.record;
    output r8 as credits.record;


function mint:
    input r0 as u64.private;
    async mint self.caller r0 into r1;
    output r1 as arc20_0001.aleo/mint.future;

finalize mint:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into account[r0];
    get.or_use total_supply[true] 0u64 into r4;
    add r4 r1 into r5;
    set r5 into total_supply[true];


function burn:
    input r0 as u64.private;
    async burn self.caller r0 into r1;
    output r1 as arc20_0001.aleo/burn.future;

finalize burn:
    input r0 as address.public;
    input r1 as u64.public;
    get account[r0] into r2;
    sub r2 r1 into r3;
    set r3 into account[r0];
    get.or_use total_supply[true] 0u64 into r4;
    sub r4 r1 into r5;
    set r5 into total_supply[true];


function hash_to_sign:
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as address.private;
    input r3 as u32.private;
    cast r2 r0 r1 r3 into r4 as transfer_from;
    hash.bhp256 r4 into r5 as field;
    output r5 as field.private;
