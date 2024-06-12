

export interface IBasicDeployArgs {
    validate(): void;
}

export interface IDeployResult {

}
export interface IDeployable {

    deploy(): Promise<any>;
    
}