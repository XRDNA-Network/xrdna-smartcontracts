import { Avatar } from "../../../src/avatar/Avatar";
import { AvatarFactory } from "../../../src/avatar/AvatarFactory";
import { AvatarRegistry } from "../../../src/avatar/AvatarRegistry";

export interface IAvatarStack {

    getAvatarFactory(): AvatarFactory;
    getAvatarRegistry(): AvatarRegistry;
}