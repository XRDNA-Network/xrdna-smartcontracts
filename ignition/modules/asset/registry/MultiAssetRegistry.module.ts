import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import ERC721Module from "./ERC721Registry.module";
import ERC20Module from "./ERC20Registry.module";

import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';

export default buildModule("MultiAssetRegistry", (m) => {
    
    const erc20 = m.useModule(ERC20Module);
    const erc721 = m.useModule(ERC721Module);
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.assetRegistryAdmin;
    const admins = config.assetRegistryOtherAdmins;
    const args = {
        mainAdmin: acct,
        admins,
        registries: [erc721.erc721Registry, erc20.erc20Registry]
    }
    const Registry = m.contract("MultiAssetRegistry", 
                                [args], {
        after: [erc20.erc20Registry, erc721.erc721Registry]
    });
    return {
        erc20Registry: erc20.erc20Registry,
        erc721Registry: erc721.erc721Registry,
        multiAssetRegistry: Registry
    };
});