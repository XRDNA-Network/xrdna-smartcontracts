import { Provider, Signer } from "ethers";
import { AllLogParser } from "../AllLogParser";

export interface IWrapperOpts {
    address: string;
    signerOrProvider: Provider | Signer;
    logParser: AllLogParser;
}