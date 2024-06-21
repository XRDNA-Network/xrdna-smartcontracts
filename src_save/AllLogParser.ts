import { Log, TransactionReceipt, Interface, LogDescription } from "ethers";
import { ILogParser, LogMap } from "./interfaces/ILogParser";
import { AddrressToABIMap, buildAddressToABIMap } from "./AddressToABIMap";
import { DeploymentAddressConfig } from "./ContractAddresses";

export class AllLogParser implements ILogParser {

    private abiMap: Map<string, Interface> = new Map();
    constructor(readonly deploymentConfig: DeploymentAddressConfig) {}

    addAbi(address: string, abi: any): void {
        this.abiMap.set(address.toLowerCase(), new Interface(abi));
    }

    parseLogs(r: TransactionReceipt): LogMap {
        buildAddressToABIMap(this.deploymentConfig);
        const map: LogMap = new Map();
        const logs = r.logs;
        if(!logs || logs.length === 0) {
            return map;
        }
        
        logs.forEach( (l: Log) => {
            let ifc = this.abiMap.get(l.address.toLowerCase());
            if(!ifc) {
                const abiMap = AddrressToABIMap;
                const addy = l.address.toLowerCase();
                const abi = abiMap.get(addy);
                if(!abi) {
                    return;
                }
                ifc = new Interface(abi);
                this.abiMap.set(addy, ifc);
            }
            
            try {
                const parsed = ifc.parseLog(l);
                if(parsed) {
                    if(!map.get(parsed.name)) {
                        map.set(parsed.name,[]);
                    }
                    map.get(parsed.name)!.push(parsed);
                }
            } catch (e) {
                console.error("Error parsing log", e);
                console.log(l);
            }
        });
        return map;
    }

}