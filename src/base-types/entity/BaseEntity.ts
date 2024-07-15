import { TransactionResponse } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { BaseAccess } from "../BaseAccess";
import { LogNames } from "../../LogNames";

export abstract class BaseEntity extends BaseAccess {

    async name(): Promise<string> {
        return RPCRetryHandler.withRetry(() => this.getContract().name());
    }

    async upgrade(): Promise<TransactionResponse> {
        const t = await RPCRetryHandler.withRetry(() => this.getContract().upgrade());
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Upgrade failed");
        }
        const logs = this.logParser.parseLogs(r);
        const upgrade = logs.get(LogNames.RegistryUpgradedEntity);
        if(!upgrade || upgrade.length === 0) {
            throw new Error("Upgrade failed");
        }
        return t;
    }
}