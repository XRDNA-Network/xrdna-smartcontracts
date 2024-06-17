import { LogDescription, TransactionReceipt } from "ethers";


export type LogMap  = Map<string, LogDescription[]>;

export interface ILogParser {

    parseLogs(r: TransactionReceipt): LogMap;
}