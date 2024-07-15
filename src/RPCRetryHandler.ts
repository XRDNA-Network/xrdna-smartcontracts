
/**
 * RetryHandler handles common RPC problems with web3 calls and transactions. It will retry the 
 * call or transaction if it fails due to a known issue. Otherwise, it will throw.
 */
export type FnToRetry = (...args: any[]) => Promise<any>;

export class RPCRetryHandler  {

    static async withRetry(fn: FnToRetry, retries: number = 3): Promise<any> {
        let tries = 0;
        let lastError: any;
        while(tries < retries) {
            try {
                return await fn();
            } catch(e) {
                if(!RPCRetryHandler.isKnownError(e)) {
                    throw e;
                }
                lastError = e;
            }
            tries++;
        }
        throw lastError;
    }

    static isKnownError(e: any): boolean {
        //RPC network connection problem
        if(e.message.toLowerCase().indexOf("connect") >= 0 ) {
            return true;
        }

        //nonce too low or already used
        if((e.code && e.code === 'NONCE_EXPIRED') || 
            e.message.indexOf("nonce has already been used") >= 0 ||
                        e.message.indexOf("nonce too low") >= 0) {
                            
            return true;
        } 

        //allready submitted to mempool
        if(e.message.indexOf("already known") >= 0) {
            //means it's waiting in the mempool but could have a nonce gap
            return true;
        }
        return false;
    }
    
}