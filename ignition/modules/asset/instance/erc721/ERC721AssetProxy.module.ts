import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import ERC721AssetRegistryModule from "../../registry/ERC721Registry.module";
import ERC721AssetRegistryProxy from '../../registry/ERC721RegistryProxy.module';
import ERC721Module from './NTERC721Asset.module';

export default buildModule("ERC721AssetProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const reg = m.useModule(ERC721AssetRegistryModule).erc721Registry;
        const proxy = m.useModule(ERC721AssetRegistryProxy).erc721RegistryProxy;
        const erc721 = m.useModule(ERC721Module).erc721Asset;

        
        const rr = m.contract("ERC721AssetProxy", [proxy], {
            after: [
                reg,
                erc721,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(reg, "setProxyImplementation", [rr]);
        m.send("setProxyImplementation", proxy, 0n, data);
        
        return {
            erc20Proxy: rr
        }
});