import { Signer } from "ethers";


export interface IBasicDeployArgs {
    admin: Signer;
}

export interface IDeployable {

    deploy<T extends IBasicDeployArgs>(args: T): Promise<void>;
    
}