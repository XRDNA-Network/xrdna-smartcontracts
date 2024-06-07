import { Signer } from "ethers";
import { AssetStackImpl } from "./asset/AssetStackImpl";
import { AvatarStackImpl } from "./avatar/AvatarStackImpl";
import { PortalStackImpl } from "./portal/PortalStackImpl";
import { ExperienceStackImpl } from "./experience/ExperienceStackImpl";
import { WorldStackImpl } from "./world/WorldStackImpl";

export enum StackType {
    ASSET = "ASSET",
    WORLD = "WORLD",
    AVATAR = "AVATAR",
    COMPANY = "COMPANY",
    EXPERIENCE = "EXPERIENCE",
    PORTAL = "PORTAL"
}

export type StackCreatorFn = (type: StackType) => any;

export class StackFactory {
    static admin: Signer

    static setAdmin(admin: Signer) {
        StackFactory.admin = admin;
    }

    static async getStack(type: StackType): Promise<any> {
        switch (type) {
            case StackType.ASSET: {
                const a = new AssetStackImpl(StackFactory.getStack);
                await a.deploy({admin: StackFactory.admin});
                return a;
            }
            case StackType.WORLD: {
                const w = new WorldStackImpl(StackFactory.getStack);
                await w.deploy({admin: StackFactory.admin});
                return w;
            }
                
            case StackType.AVATAR: {
                const a = new AvatarStackImpl(StackFactory.getStack);
                await a.deploy({admin: StackFactory.admin});
                return a;
            }

            case StackType.PORTAL: {
                const p = new PortalStackImpl(StackFactory.getStack);
                await p.deploy({admin: StackFactory.admin});
                return p;
            
            }
            case StackType.EXPERIENCE: {
                const e = new ExperienceStackImpl(StackFactory.getStack);
                await e.deploy({admin: StackFactory.admin});
                return e;
            }
            case StackType.COMPANY:
                return <T><unknown>new CompanyStack();
            default:
                throw new Error(`Unsupported stack type: ${type}`);
        }
    }
}