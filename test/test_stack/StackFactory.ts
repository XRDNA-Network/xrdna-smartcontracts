import { AssetStackImpl } from "./asset/AssetStackImpl";

export enum StackType {
    ASSET = "ASSET",
    WORLD = "WORLD",
    AVATAR = "AVATAR",
    COMPANY = "COMPANY",
    EXPERIENCE = "EXPERIENCE"
}

export type StackCreatorFn = (type: StackType) => any;

export class StackFactory {

    static getStack(type: StackType): any {
        switch (type) {
            case StackType.ASSET:
                return new AssetStackImpl(StackFactory.getStack);
            case StackType.WORLD:
                return <T><unknown>new WorldStack();
            case StackType.AVATAR:
                return <T><unknown>new AvatarStack();
            case StackType.COMPANY:
                return <T><unknown>new CompanyStack();
            default:
                throw new Error(`Unsupported stack type: ${type}`);
        }
    }
}