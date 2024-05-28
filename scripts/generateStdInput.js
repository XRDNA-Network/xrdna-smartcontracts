
/**
 * Read build info json files and extract unique inputs and append to stdInput.json
 */
const fs = require("fs");
const path = require("path");

const buildInfoPath = path.join(__dirname, '../artifacts/build-info');
const stdInputPath = path.join(__dirname, '../stdInput.json');
const main = async () => {
    const files = fs.readdirSync(buildInfoPath);
    const stdInput = {};
    const allSources = {};
    for (const file of files) {
        console.log("FILE", file);
        const buildInfo = require(path.join(buildInfoPath, file));
        const input = buildInfo.input;
        for (const i of Object.keys(input)) {
            if(i === 'sources') {
                for(const s of Object.keys(input[i])) {
                    //if(!allSources[s]) {
                        allSources[s] = input[i][s];
                    //}
                }
            } else {
                stdInput[i] = input[i];
            }
        }
    }
    stdInput.sources = allSources;
    //console.log("Final stdInput", stdInput);
    fs.writeFileSync(stdInputPath, JSON.stringify(stdInput, null, 2));
}

main();