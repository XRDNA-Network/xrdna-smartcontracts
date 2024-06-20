import {ethers, Signer, Wallet} from 'ethers';
import { HardhatTestKeys } from './HardhatTestKeys';
import {ChainIds} from './ChainIds';

/**
 * To keep different signers for various registries and authorities better organized,
 * this utility will catalog all signing addresses per network chain id. This is 
 * only useful for testing and deployment since all XRDNA SDKs will require signers
 * be assigned based on the role of the SDK. The addresses in this utility should
 * map to the expected admins and authorities assigned in the SDKs.
 */

export interface IDeploymentEntry {
    assetRegistryAdmin: string;
    assetRegistryOtherAdmins: string[];
    assetFactoryAdmin: string;
    assetFactoryOtherAdmins: string[];
    avatarRegistryAdmin: string;
    avatarRegistryOtherAdmins: string[];
    avatarFactoryAdmin: string;
    avatarFactoryOtherAdmins: string[];
    companyRegistryAdmin: string;
    companyRegistryOtherAdmins: string[];
    companyFactoryAdmin: string;
    companyFactoryOtherAdmins: string[];
    experienceRegistryAdmin: string;
    experienceRegistryOtherAdmins: string[];
    experienceFactoryAdmin: string;
    experienceFactoryOtherAdmins: string[];
    portalRegistryAdmin: string;
    portalRegistryOtherAdmins: string[];
    registrarRegistryAdmin: string;
    registrarRegistryOtherAdmins: string[];
    registrarFactoryAdmin: string;
    registrarFactoryOtherAdmins: string[];
    worldRegistryAdmin: string;
    worldRegistryOtherAdmins: string[];
    worldFactoryAdmin: string;
    worldFactoryOtherAdmins: string[];
    vectorAddressAuthority: string;
}

export interface ITestingConfig {
    assetRegistryAdmin: Signer;
    assetFactoryAdmin: Signer;
    avatarRegistryAdmin: Signer;
    avatarFactoryAdmin: Signer;
    companyRegistryAdmin: Signer;
    companyFactoryAdmin: Signer;
    experienceRegistryAdmin: Signer;
    experienceFactoryAdmin: Signer;
    portalRegistryAdmin: Signer;
    registrarRegistryAdmin: Signer;
    worldRegistryAdmin: Signer;
    worldFactoryAdmin: Signer;
    vectorAddressAuthority: Signer;
}

export interface IDeploymentConfig {
    [key: number]: IDeploymentEntry;
}

export class XRDNASigners {
    readonly deployment: IDeploymentConfig = {};
    readonly testingConfig: ITestingConfig;

    constructor(readonly provider?: ethers.Provider) {
        this.testingConfig = this._buildTestConfig();
        this._buildDeploymentConfig();
    }
    

    private _buildTestConfig(): ITestingConfig {
        const signer = new Wallet(HardhatTestKeys[0].key, this.provider);
        const vector = new Wallet(HardhatTestKeys[1].key, this.provider);
        return {
            assetRegistryAdmin: signer,
            assetFactoryAdmin: signer,
            avatarRegistryAdmin: signer,
            avatarFactoryAdmin: signer,
            companyRegistryAdmin: signer,
            companyFactoryAdmin: signer,
            experienceRegistryAdmin: signer,
            experienceFactoryAdmin: signer,
            portalRegistryAdmin: signer,
            registrarRegistryAdmin: signer,
            worldRegistryAdmin: signer,
            worldFactoryAdmin: signer,
            vectorAddressAuthority: vector
        }
    }

    private _buildDeploymentConfig() {
       this.deployment[ChainIds.LocalTestnet] = this._buildLocalTestnetDeployment();
       this.deployment[ChainIds.XrdnaBaseSepolia] = this._buildXRDNATestnetDeployment();
       this.deployment[ChainIds.XrdnaBaseMainnet] = this._buildXRDNAMainnetDeployment();

    }

    private _buildLocalTestnetDeployment(): IDeploymentEntry {
        const admin = HardhatTestKeys[0].address;
        const vector = HardhatTestKeys[1].address;
        return {
            assetRegistryAdmin: admin,
            assetRegistryOtherAdmins: [],
            assetFactoryAdmin: admin,
            assetFactoryOtherAdmins: [],
            avatarRegistryAdmin: admin,
            avatarRegistryOtherAdmins: [],
            avatarFactoryAdmin: admin,
            avatarFactoryOtherAdmins: [],
            companyRegistryAdmin: admin,
            companyRegistryOtherAdmins: [],
            companyFactoryAdmin: admin,
            companyFactoryOtherAdmins: [],
            experienceRegistryAdmin: admin,
            experienceRegistryOtherAdmins: [],
            experienceFactoryAdmin: admin,
            experienceFactoryOtherAdmins: [],
            portalRegistryAdmin: admin,
            portalRegistryOtherAdmins: [],
            registrarRegistryAdmin: admin,
            registrarRegistryOtherAdmins: [],
            registrarFactoryAdmin: admin,
            registrarFactoryOtherAdmins: [],
            worldRegistryAdmin: admin,
            worldRegistryOtherAdmins: [],
            worldFactoryAdmin: admin,
            worldFactoryOtherAdmins: [],
            vectorAddressAuthority: vector
        }
    }
    private _buildXRDNATestnetDeployment(): IDeploymentEntry {
        const TDG = '0x0616Ab4786C29d0e33F9cCe808886211F7C80D35';
        const XRDNA = '0x28ba8a72cc5d3eafdbd27929b658e446c697148b';
        const POWERS = '0x18872e7ffEf6d3C56B2E7051575bE3a1F0188C18';
        return {
            assetRegistryAdmin: XRDNA,
            assetRegistryOtherAdmins: [TDG, POWERS],
            assetFactoryAdmin: XRDNA,
            assetFactoryOtherAdmins: [TDG, POWERS],
            avatarRegistryAdmin: XRDNA,
            avatarRegistryOtherAdmins: [TDG, POWERS],
            avatarFactoryAdmin: XRDNA,
            avatarFactoryOtherAdmins: [TDG, POWERS],
            companyRegistryAdmin: XRDNA,
            companyRegistryOtherAdmins: [TDG, POWERS],
            companyFactoryAdmin: XRDNA,
            companyFactoryOtherAdmins: [TDG, POWERS],
            experienceRegistryAdmin: XRDNA,
            experienceRegistryOtherAdmins: [TDG, POWERS],
            experienceFactoryAdmin: XRDNA,
            experienceFactoryOtherAdmins: [TDG, POWERS],
            portalRegistryAdmin: XRDNA,
            portalRegistryOtherAdmins: [TDG, POWERS],
            registrarRegistryAdmin: XRDNA,
            registrarRegistryOtherAdmins: [TDG, POWERS],
            registrarFactoryAdmin: XRDNA,
            registrarFactoryOtherAdmins: [TDG, POWERS],
            worldRegistryAdmin: XRDNA,
            worldRegistryOtherAdmins: [TDG, POWERS],
            worldFactoryAdmin: XRDNA,
            worldFactoryOtherAdmins: [TDG, POWERS],
            vectorAddressAuthority: XRDNA
        }
    }

    private _buildXRDNAMainnetDeployment(): IDeploymentEntry {
        const XRDNA = '0x28ba8a72cc5d3eafdbd27929b658e446c697148b';
        const TDG = '0x0616Ab4786C29d0e33F9cCe808886211F7C80D35';
        return {
            assetRegistryAdmin: XRDNA,
            assetRegistryOtherAdmins: [TDG],
            assetFactoryAdmin: XRDNA,
            assetFactoryOtherAdmins: [TDG],
            avatarRegistryAdmin: XRDNA,
            avatarRegistryOtherAdmins: [TDG],
            avatarFactoryAdmin: XRDNA,
            avatarFactoryOtherAdmins: [TDG],
            companyRegistryAdmin: XRDNA,
            companyRegistryOtherAdmins: [TDG],
            companyFactoryAdmin: XRDNA,
            companyFactoryOtherAdmins: [TDG],
            experienceRegistryAdmin: XRDNA,
            experienceRegistryOtherAdmins: [TDG],
            experienceFactoryAdmin: XRDNA,
            experienceFactoryOtherAdmins: [TDG],
            portalRegistryAdmin: XRDNA,
            portalRegistryOtherAdmins: [TDG],
            registrarRegistryAdmin: XRDNA,
            registrarRegistryOtherAdmins: [TDG],
            registrarFactoryAdmin: XRDNA,
            registrarFactoryOtherAdmins: [TDG],
            worldRegistryAdmin: XRDNA,
            worldRegistryOtherAdmins: [TDG],
            worldFactoryAdmin: XRDNA,
            worldFactoryOtherAdmins: [TDG],
            vectorAddressAuthority: XRDNA
        }
    }

}