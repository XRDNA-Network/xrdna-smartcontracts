

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
    coveragePeriod: number;

    /**
     * The period of time in days that the registration is valid for after the coverage period has ended.
     */
    gracePeriod: number;
}