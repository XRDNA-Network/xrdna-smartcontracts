import { AddressLike, Signer, ethers } from "ethers";


/**
 * Represents the terms of a registration.
 */
export interface RegistrationTerms {

    /**
     * The registration fee.
     */
    fee: bigint;

    /**
     * The period of time in days that the registration is valid for.
     */
    coveragePeriodDays: bigint;

    /**
     * The period of time in days that the registration is valid for after the coverage period has ended.
     */
    gracePeriodDays: bigint;
}

export interface ISignTermsOpts {
    signer: Signer;
    terms: RegistrationTerms;
    termsOwner: AddressLike;
    expiration: bigint;
}

export const signTerms = async (opts: ISignTermsOpts): Promise<string> => {
        
    const encoded = ethers.AbiCoder.defaultAbiCoder().encode(
        ["address", "uint256", "uint16", "uint16", "uint256"], 
        [opts.termsOwner, opts.terms.fee, opts.terms.coveragePeriodDays, opts.terms.gracePeriodDays, opts.expiration]);
    const msg = ethers.keccak256(ethers.getBytes(encoded));
    return await opts.signer.signMessage(ethers.getBytes(msg));
}