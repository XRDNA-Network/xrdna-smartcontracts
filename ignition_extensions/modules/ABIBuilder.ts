import fs from 'fs'
import path from 'path'

const base_path = path.resolve(__dirname, '../../artifacts/generated/abi/');

export const generateABI = (props: {
    contractName: string,
    abi: any[]
}): void => {
    if(!fs.existsSync(base_path)){
        fs.mkdirSync(base_path, {recursive: true});
    }

    fs.writeFileSync(path.resolve(base_path, `${props.contractName}ABI.json`), JSON.stringify({abi: props.abi}, null, 2));
}