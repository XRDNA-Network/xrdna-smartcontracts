import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../../config";

export default buildModule("ERC721AssetFactory", (m) => {
    
    const admins = config.assetFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("ERC721AssetFactory", [acct, admins]);
    return {erc721Factory: Factory};
});