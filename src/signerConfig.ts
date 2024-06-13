
import {ChainIds} from './ChainIds';

export interface ISignerEntry {
    assetRegistryAdmin: string;
    assetFactoryAdmin: string;
    avatarRegistryAdmin: string;
    avatarFactoryAdmin: string;
    companyRegistryAdmin: string;
    companyFactoryAdmin: string;
    experienceRegistryAdmin: string;
    experienceFactoryAdmin: string;
    portalRegistryAdmin: string;
    worldRegistryAdmin: string;
    worldFactoryAdmin: string;
    vectorAddressAuthority: string;
}

export interface ISignerConfig {
    [key: number]: ISignerEntry;
}

const HH_ACCT_0 = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
const HH_ACCT_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";

export default (): ISignerConfig => ({
    [ChainIds.LocalTestnet]: {
        assetRegistryAdmin: HH_ACCT_0,
        assetFactoryAdmin: HH_ACCT_0,
        avatarRegistryAdmin: HH_ACCT_0,
        avatarFactoryAdmin: HH_ACCT_0,
        companyRegistryAdmin: HH_ACCT_0,
        companyFactoryAdmin: HH_ACCT_0,
        experienceRegistryAdmin: HH_ACCT_0,
        experienceFactoryAdmin: HH_ACCT_0,
        portalRegistryAdmin: HH_ACCT_0,
        worldRegistryAdmin: HH_ACCT_0,
        worldFactoryAdmin:  HH_ACCT_0,
        vectorAddressAuthority: HH_ACCT_1
    }
})