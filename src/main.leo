// The 'arc20_0001' program.
/// Program implementing proposed token standard
///
/// This program is capable to send private credits to a contract that is driven by mpc address.
/// This program is has also transfer_from_public function that can be used by contracts to transfer tokens to themselves.

program arc20_0001.aleo {

	/// Mapping of addresses to balances
	mapping account: address => u64;

	/// Mapping of total supply
	mapping total_supply: bool => u64;

	/// Name of the token 'Aleo Credits'
	const NAME: field =  29591854713254390051098558719843710286620636002170764447558050801690808942592field;

	/// Symbol of the token 'ALEO'
	const SYMBOL: field =  29535093885169187707116277799267314899879263164026335641338301482164084015104field;

	/// Signature
	/// Signature is used to connect the company website with contract to minimize fraud.
	/// See 2.2.3 of the standard
	/// const COMPANY_SIGNATURE: signature = sign069ju4e8s66unu25celqycvsv3k9chdyz4n4sy62tx6wxj0u25vqp58hgu9hwyqc63qzxvjwesf2wz0krcvvw9kd9x0rsk4lwqn2acqhp9v0pdkhx6gvkanuuwratqmxa3du7l43c05253hhed9eg6ppzzfnjt06fpzp6msekdjxd36smjltndmxjndvv9x2uecsgngcwsc2qkns4afd;

	/// Decimals of the token
	/// The number of decimal digits expressing fractional units of the token. 
	const DECIMALS: u8 = 6u8;

	/// ZERO_ADDRESS is the result of BHP256::hash_to_address(0group)
	/// Used to signal that no valid address is pressent
	const ZERO_ADDRESS : address = aleo1yr9ls3d7cn2x2sr359kqq7vjkwnzr4x0e24ju6ysj2pte4c99c8qx0rwwl;

	/// A record that represents a credit. 
	record credits {
		
		/// Mandatory owner of the credits
		owner       : address,

		/// Optional contract that can control the credits
		/// If contract is ZERO_ADDRESS then the credits can be fully controlled by the owner
		/// If contract is not ZERO_ADDRESS then the credits will be encoded with owners keys, but only contract can call any of the functions of this program
		contract    : address,
		
		/// Amount of credits
		microcredits: u64    ,
	}

	/// A struct that represents a transfer of credits. 
	struct transfer_from {
		
		/// Address from which credits are transferred
		from  : address,
		
		/// Address to which credits are transferred
		to    : address,
		
		/// Amount of credits
		amount: u64    ,
		
		/// Expiration block height of the transfer
		expire: u32    ,
	}

	/// Transfer of credits in a publicly visible way
	///
	/// # Arguments
	///
	/// * `to` - Address from which credits are transferred
	/// * `amount` - Amount of credits to be transferred
	transition transfer_public(public to: address, public amount: u64) { 
		return then finalize(self.caller, to, amount);
	} finalize transfer_public(caller:address, to: address, amount: u64) { 
		Mapping::set(account, caller, Mapping::get       (account       , caller      ) - amount);
		Mapping::set(account, to    , Mapping::get_or_use(account       , to    , 0u64) + amount);
	}

	/// Transfer of credits in a publicly visible way 
	/// 
	/// This transition can be initiated by a third party. Which makes it possible to transfer funds to contracts in one step.
	///
	/// # Arguments
	///
	/// * `to` - Address to which credits are transferred
	/// * `amount` - Amount of credits to be transferred
	/// * `from` - Address from which credits are transferred
	/// * `expire` - Expiration block height of the transfer after which the authorization is not valid anymore
	/// * `authorization` - Autorization signature created by the private key associated with the `from` address
	transition transfer_from_public(
		public to: address,
		public amount: u64,
		public from: address,
		public expire: u32,
		authorization: signature,
	) { 
		let tx_hash : field = BHP256::hash_to_field(transfer_from { from, to, amount, expire });
		assert(authorization.verify(from, tx_hash));
		return then finalize(to, amount, from, expire);
	} finalize transfer_from_public(to: address, amount: u64, from: address, expire: u32) {
		assert(block.height < expire);
		Mapping::set(account, from, Mapping::get       (account       , from      ) - amount);
		Mapping::set(account, to  , Mapping::get_or_use(account       , to  , 0u64) + amount);
	}

	/// Transfer of credits to accounts in a way that all tx data is hidden from the public
	///
	/// # Arguments
	///
	/// * `to`       - Address from which credits are transferred
	/// * `amount`   - Amount of credits to be transferred
	/// * `credit`   - Credits to be transferred
	transition transfer_private(
		to: address,
		amount: u64,
		credit: credits
	) -> (credits, credits) { 
		if self.caller == self.signer {
			assert(credit.contract == ZERO_ADDRESS);	
		} else {

			assert(
				self.caller     == credit.contract ||
				self.signer     == credit.owner    &&
				credit.contract == ZERO_ADDRESS
			);

		}
		return ( 
			credits {
				owner       : credit.owner                ,
				contract    : credit.contract             ,
				microcredits: credit.microcredits - amount,
				}                                         ,
			credits {
				owner       : to                          ,
				contract		: ZERO_ADDRESS                ,
				microcredits: amount                      ,
				}
			);
	}

	/// Transfer of credits to contracts in a way that all tx data is hidden from the public
	///
	/// This transition can only be called by a contract, otherwise it will fail.
	///
	/// To transfer private credits implemented in TOKEN.aleo to contract HANDLER.aleo that is driven by mpc address: `mpc_address`, the following must be done:
	/// user must call Handler.aleo/deposit(record, amount)
	/// The transition looks like this:
	/// program HANDLER.aleo {
	///   transition deposit(record, amount) {
	///      ...
	///      TOKEN.aleo/transfer_private(mpc_address, self_address, amount, record);
	///      ...
	///   }
	/// }
	/// # Arguments
	///
	/// * `to`       - Address from which credits are transferred
	///
	/// * `contract` - Address of the contract that will handle the credits,
	///								 if sent from an account it always must be `ZERO_ADDRESS`
	///
	/// * `amount`   - Amount of credits to be transferred
	/// * `credit`   - Credits to be transferred
	transition transfer_private_contract(
		to: address,
		contract: address,
		amount: u64,
		credit: credits
	) -> (credits, credits) { 
		assert(self.caller != self.signer);

		assert(
			self.caller     == credit.contract ||
			self.signer     == credit.owner    &&
			credit.contract == ZERO_ADDRESS
		);

		return ( 
			credits {
				owner       : credit.owner                ,
				contract    : credit.contract             ,
				microcredits: credit.microcredits - amount,
				}                                         ,
			credits {
				owner       : to                          ,
				contract                                  ,
				microcredits: amount                      ,
				}
			);
	}

	/// Transfer of credits from private to public domain
	///
	/// # Arguments
	/// 
	/// * `credit` - Credits record to be transferred
	/// * `to` - Address from which credits are transferred
	/// * `amount` - Amount of credits to be transferred
	///
	/// # Returns
	/// 
	/// * `credits` - Remining private credit record
	transition transfer_private_to_public(credit: credits, public to: address, public amount: u64) -> credits { 
		if self.caller == self.signer {
			assert(credit.contract   == ZERO_ADDRESS       );	
		} else {
			assert(
				self.caller            == credit.contract || 
				self.signer            == credit.owner    &&
				credit.contract        == ZERO_ADDRESS       );
		}
		let remaining : credits = 
			credits {
				owner       : credit.owner                ,
				contract    : credit.contract             ,
				microcredits: credit.microcredits - amount,
		};
		return remaining then finalize(to, amount);
		} finalize transfer_private_to_public(to: address, amount: u64) { 
		Mapping::set(account, to, Mapping::get_or_use(account, to, 0u64) + amount);
		}

	/// Transfer of credits from public to private domain
	/// 
	/// # Arguments
	///
	/// * `to` - Address from which credits are transferred
	/// * `amount` - Amount of credits to be transferred
	///
	/// # Returns
	/// 
	/// * `credits` - Private credit record
	transition transfer_public_to_private(to: address, public amount: u64) -> credits { 
		let contract : address = ZERO_ADDRESS;
		if self.caller != self.signer {
			contract = self.caller;
		}
		return credits {
			owner       : to    ,
			contract            ,
			microcredits: amount,
			} then finalize(self.caller, to, amount);
		} finalize transfer_public_to_private(caller:address, to: address, amount: u64) {
		Mapping::set(account, caller, Mapping::get(account, caller) - amount);
		}

	/// Join two credit records into one
	///
	/// # Arguments
	///
	/// * `credit1` - First credit record
	/// * `credit2` - Second credit record
	///
	/// # Returns
	/// 
	/// * `credits` - Joined credit record
	transition join(credit1: credits, credit2: credits) -> credits { 
		if(self.caller != self.signer) {

			assert(
				credit1.contract == self.caller &&
				credit2.contract == self.caller
			);

		} 	

		return credits { 
			owner       : credit1.owner                              ,
			contract    : credit1.contract                           ,
			microcredits: credit1.microcredits + credit2.microcredits,
			};

		}

	/// Split credit record into two
	///
	/// # Arguments
	/// 
	/// * `credit` - Credit record to be split
	/// * `amount` - Amount of credits to be split off
	///
	/// # Returns
	///
	/// * `credits` - Remaining credit record
	/// * `credits` - Split off credit record
	transition split(credit: credits, amount: u64) -> (credits, credits) { 
		if(self.caller != self.signer) {
			assert(credit.contract == self.caller);
		}

		return (
			credits {
				owner       : credit.owner                ,
				contract    : credit.contract             ,
				microcredits: credit.microcredits - amount,
				},
			credits {
				owner       : credit.owner   ,
				contract    : credit.contract,
				microcredits: amount         ,
				}
			);
	}

	/// Mint new credits
	///
	/// # Arguments
	///
	/// * `amount` - Amount of credits to be minted
	transition mint(amount: u64) {
		return then finalize(self.caller, amount);
		} finalize mint(caller:address, amount: u64) { 
		Mapping::set(account     , caller, Mapping::get_or_use(account     , caller, 0u64) + amount);
		Mapping::set(total_supply, true  , Mapping::get_or_use(total_supply, true  , 0u64) + amount);
		}

	/// Burn credits
	///
	/// # Arguments
	/// 
	/// * `amount` - Amount of credits to be minted
	///
	transition burn(amount: u64) {
		return then finalize(self.caller, amount);
		} finalize burn(caller:address, amount: u64) { 
		Mapping::set(account     , caller, Mapping::get(       account     , caller      ) - amount);
		Mapping::set(total_supply, true  , Mapping::get_or_use(total_supply, true  , 0u64) - amount);
		}

	//can't be implemented currently as there is no access to mappings in transitions
	//transition total_supply() -> u64 {}

	/// Create a hash of transfer parameters for signing
	///
	/// # Arguments
	///
	/// * `to` - Address to which credits are transferred
	/// * `amount` - Amount of credits to be transferred
	/// * `from` - Address from which credits are transferred
	/// * `expire` - Expiration block height of the transfer after which the authorization is not valid anymore
	///
	/// # Returns
	///
	/// * `field` - Hash of transfer parameters that can be signed offline later

	transition hash_to_sign(to: address, amount: u64, from: address, expire: u32) -> field { 
		return BHP256::hash_to_field(transfer_from { from, to, amount, expire });
	}
	}
