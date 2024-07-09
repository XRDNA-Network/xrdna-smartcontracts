import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import ERC20AssetRegistryModule from "../../registry/ERC20RegistryProxy.module";
import ERC20AssetRegistry from '../../registry/ERC20Registry.module';
import ERC20 from './NTERC20Asset.module';

export default buildModule("ERC20AssetProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const proxy = m.useModule(ERC20AssetRegistryModule).erc20RegistryProxy;
        const erc20Reg = m.useModule(ERC20AssetRegistry).erc20Registry;
        const erc20 = m.useModule(ERC20).erc20Asset;

        
        const rr = m.contract("ERC20AssetProxy", [proxy], {
            after: [
                proxy,
                erc20,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(erc20Reg, "setProxyImplementation", [rr]);
        m.send("setProxyImplementation", proxy, 0n, data);
        return {
            erc20Proxy: rr
        }
});