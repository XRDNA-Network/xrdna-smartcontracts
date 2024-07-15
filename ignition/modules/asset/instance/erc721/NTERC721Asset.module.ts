import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CompanyRegistryProxyModule from "../../../company/registry/CompanyRegistryProxy.module";
import AvatarRegistryProxyModule from "../../../avatar/registry/AvatarRegistryProxy.module";
import ERC721RegistryModule from '../../registry/ERC721Registry.module';
import ERC721RegistryProxy from '../../registry/ERC721RegistryProxy.module';


export default buildModule("NTERC721AssetModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const aRegProxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;
        const compRegProxy = m.useModule(CompanyRegistryProxyModule).companyRegistryProxy;
        const ercReg = m.useModule(ERC721RegistryModule).erc721Registry;
        const ercRegProxy = m.useModule(ERC721RegistryProxy).erc721RegistryProxy;

        const args = {
            assetRegistry: ercRegProxy,
            companyRegistry: compRegProxy,
            avatarRegistry: aRegProxy,
        }
        
        const rr = m.contract("NTERC721Asset", [args], {
            libraries: {
                LibAccess: libs.LibAccess,
            },
            after: [
                compRegProxy,
                aRegProxy,
                ercRegProxy,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(ercReg, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", ercRegProxy, 0n, data);
        return {
            erc721Asset: rr,
            erc721Registry: ercRegProxy,
        }
});