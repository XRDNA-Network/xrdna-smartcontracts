import { Interface, TransactionReceipt } from "ethers";

export class LogParser {

    ifc: Interface;
    constructor(
        readonly abi: any,
        readonly contractAddress: string
    ) {
        this.ifc = new Interface(abi);
    }

    parseLogs(receipt: TransactionReceipt): Map<string, any> {
        const logs = receipt.logs;
        const parsedLogs = new Map<string, any>();
        logs.forEach((l:any) => {
            try {
                if(l.address !== this.contractAddress) {
                    return;
                }
                const parsed = this.ifc.parseLog(l);
                if(parsed) {
                    parsedLogs.set(parsed.name, parsed.args);
                }
            } catch (e) {
                console.error("Error parsing log", e);
            }
        });
        return parsedLogs;
    }
}