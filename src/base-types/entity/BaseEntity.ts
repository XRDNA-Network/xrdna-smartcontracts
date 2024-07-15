import { AddressLike, TransactionResponse } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { BaseAccess } from "../BaseAccess";
import { LogNames } from "../../LogNames";
import { Version } from "../../Version";

export abstract class BaseEntity extends BaseAccess {

    async name(): Promise<string> {
        return RPCRetryHandler.withRetry(() => this.getContract().name());
    }

    async upgrade(initData: string): Promise<TransactionResponse> {
        const t = await RPCRetryHandler.withRetry(() => this.getContract().upgrade(initData));
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

    async version(): Promise<Version> {
        const r = await RPCRetryHandler.withRetry(() => this.getContract().version());
        return {
            major: r[0],
            minor: r[1],
        } as Version;
    }

    async getImplementation(): Promise<AddressLike> {
        return RPCRetryHandler.withRetry(() => this.getContract().getImplementation());
    }
}