import { ERC20AssetFactory, ERC20AssetRegistry } from "../../../../src";

export interface IERC20AssetStack  {
    getEC20Factory(): ERC20AssetFactory;
    getERC20Registry(): ERC20AssetRegistry;
}