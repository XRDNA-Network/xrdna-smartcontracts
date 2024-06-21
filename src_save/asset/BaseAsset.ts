import { Provider, ethers } from "ethers";
import { AllLogParser } from "../AllLogParser";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IERC20Opts {
    address: string;
    provider: Provider;
    logParser: AllLogParser;
}

export abstract class BaseAsset {

    abstract readonly address: string;
    abstract readonly provider: Provider;
    abstract readonly asset: ethers.Contract;
    abstract readonly logParser: AllLogParser;

    async issuer(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.issuer());
    }

    async originAddress(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.originAddress());
    }

    async originChainId(): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.originAddress());
    }

    // function hook() external view returns (IAssetHook) {
    //     return _loadCommonAttributes().hook;
    // }

    // function addHook(IAssetHook _hook) public override onlyIssuer {
    //     CommonAssetV1Storage storage s = _loadCommonAttributes();
    //     require(address(_hook) != address(0), "BaseAsset: hook cannot be zero address");
    //     s.hook = _hook;
    //     emit AssetHookAdded(address(_hook));
    // }

    // function removeHook() public override onlyIssuer {
    //     CommonAssetV1Storage storage s = _loadCommonAttributes();
    //     address h = address(s.hook);
    //     emit AssetHookRemoved(h);
    //     delete s.hook;
    // }

    // function addCondition(IAssetCondition condition) public override onlyIssuer {
    //     CommonAssetV1Storage storage s = _loadCommonAttributes();
    //     require(address(condition) != address(0), "BaseAsset: condition cannot be zero address");
    //     s.condition = condition;
    //     emit AssetConditionAdded(address(condition));
    // }

    // function removeCondition() public override onlyIssuer {
    //     CommonAssetV1Storage storage s = _loadCommonAttributes();
    //     address c = address(s.condition);
    //     emit AssetConditionRemoved(c);
    //     delete s.condition;
    // }

    // function canViewAsset(AssetCheckArgs memory args) public view override returns (bool) {
    //     CommonAssetV1Storage storage s = _loadCommonAttributes();
    //     if (address(s.condition) == address(0)) {
    //         return true;
    //     }
    //     return s.condition.canView(args);
    // }

    // function canUseAsset(AssetCheckArgs memory args) public view override returns (bool) {
    //     CommonAssetV1Storage storage s = _loadCommonAttributes();
    //     if (address(s.condition) == address(0)) {
    //         return true;
    //     }
    //     return s.condition.canUse(args);
    // }

}
