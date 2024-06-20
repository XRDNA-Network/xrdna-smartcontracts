import { MessagePrefix, Signer, concat, ethers, hexlify, keccak256, toUtf8Bytes } from "ethers";

export type VectorAddress = {
    x: string;
    y: string;
    z: string;
    t: bigint;
    p: bigint;
    p_sub: bigint;
}

export const signVectorAddress = async (address: VectorAddress, resgistrar: string, signer: Signer): Promise<string> => {
    const asKey = `${address.x}${address.y}${address.z}${address.t}${address.p}${address.p_sub}`;
    const merged = ethers.AbiCoder.defaultAbiCoder().encode(["string", "address"], [asKey, resgistrar]);

    const msg = keccak256(ethers.getBytes(merged));
    return signer.signMessage(ethers.getBytes(msg));
}