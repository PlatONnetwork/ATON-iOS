-   [概览](#概览)
-   [版本说明](#版本说明)
    -   [v0.2.0 更新说明](#v0.2.0-更新说明)
    -   [v0.3.0 更新说明](#v0.3.0-更新说明)
-   [快速入门](#快速入门)
    -   [安装或引入](#安装或引入)
        -   [环境要求](#环境要求)
        -   [CocoaPods](#cocoapods)
    -   [初始化代码](#初始化代码)
-   [合约](#合约)
    -   [合约示例](#合约示例)
    -   [部署合约](#部署合约)
        -   [**`platonDeployContract`**](#platondeploycontract)
    -   [合约call调用](#合约call调用)
        -   [**`platonCall`**](#platoncall)
    -   [合约sendRawTransaction调用](#合约sendrawtransaction调用)
        -   [**`platonSendRawTransaction`**](#platonsendrawtransaction)
    -   [合约Event](#合约event)
        -   [**`platonGetTransactionReceipt`**](#platongettransactionreceipt)
    -   [内置合约](#内置合约)
        -   [CandidateContract](#candidatecontract)
            -   [**`CandidateDeposit`**](#candidatedeposit)
            -   [**`CandidateApplyWithdraw`**](#candidateapplywithdraw)
            -   [**`CandidateWithdraw`**](#candidatewithdraw)
            -   [**`SetCandidateExtra`**](#setcandidateextra)
            -   [**`CandidateWithdrawInfos`**](#candidatewithdrawinfos)
            -   [**`CandidateDetails`**](#candidatedetails)
            -   [**`GetBatchCandidateDetail`**](#getbatchcandidatedetail)
            -   [**`CandidateList`**](#candidatelist)
            -   [**`VerifiersList`**](#verifierslist)
-   [web3](#web3)
    -   [web3 eth相关 (标准JSON RPC )](#web3-eth相关-标准json-rpc)

# 概览
> Platon Swift SDK是PlatON面向Swift开发者，提供的PlatON公链的Swift开发工具包

# 版本说明

## v0.2.0 更新说明
1. 支持PlatON的智能合约

## v0.3.0 更新说明
1. 实现了PlatON协议中交易类型定义
2. 增加内置合约CandidateContract

# 快速入门

## 安装或引入

### 环境要求
1. swift4.0以上，iOS 9.0以上

### CocoaPods

2. 在Podfile文件中添加引用
```
pod 'platonWeb3', '~> 0.3.0'
```


## 初始化代码
```
let web3 : Web3 = Web3(rpcURL: "http://192.168.1.100:6789")
```

# 合约

## 合约示例

```
#include <stdlib.h>
#include <string.h>
#include <string>
#include <platon/platon.hpp>

namespace demo {
    class FirstDemo : public platon::Contract
    {
        public:
            FirstDemo(){}
      
            /// 实现父类: platon::Contract 的虚函数
            /// 该函数在合约首次发布时执行，仅调用一次
            void init() 
            {
                platon::println("init success...");
            }

            /// 定义Event.
            PLATON_EVENT(Notify, uint64_t, const char *)

        public:
            void invokeNotify(const char *msg)
            { 
                // 定义状态变量
                platon::setState("NAME_KEY", std::string(msg));
                // 日志输出
                platon::println("into invokeNotify...");
                // 事件返回
                PLATON_EMIT_EVENT(Notify, 0, "Insufficient value for the method.");
            }

            const char* getName() const 
            {
                std::string value;
                platon::getState("NAME_KEY", value);
                // 读取合约数据并返回
                return value.c_str();
            }
    };
}

// 此处定义的函数会生成ABI文件供外部调用
PLATON_ABI(demo::FirstDemo, invokeNotify)
PLATON_ABI(demo::FirstDemo, getName)
```

## 部署合约


### **`platonDeployContract`**


**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| abi | String  | 合约abi |
| bin | Data | 合约bin |
| sender  | String  | 账户地址                   |
| privateKey  | String  | 私钥，需要与账户地址对应                   |
| gasPrice  | BigUInt  | 手续费用，Energon价格                   |
| gas  | BigUInt  | 手续费用，Energon数量                   |
| estimateGas  | Bool  | 是否估算gas                   |
| waitForTransactionReceipt  | Bool  | 是否等待交易回执返回                   |
| timeout  | dispatch_time_t  | 超时时间 时间秒                  |                 |
| completion  | ContractDeployCompletion  | 回调闭包                   |

ContractDeployCompletion定义如下

```
public typealias ContractDeployCompletion = (
_ result : PlatonCommonResult,                  //执行结果
_ address : String?,                            //合约地址
_ receipt: EthereumTransactionReceiptObject?    //交易回执
) -> ()
```

示例：

```
    func deploy(completion: () -> Void){
        print("begin deploy")
        let bin = self.getBIN()
        let abiS = self.getABI()
        web3.eth.platonDeployContract(abi: abiS!, bin: bin!, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, estimateGas: false, waitForTransactionReceipt: true, timeout: 20, completion:{
            (result,contractAddress,receipt) in
            
            switch result{
            case .success:
                self.contractAddress = contractAddress
                print("deploy success, contractAddress: \(String(describing: contractAddress))")
            case .fail(let code, let errorMsg):
                print("error code: \(String(describing: code)), msg:\(String(describing: errorMsg))")
            }
        })
    }
```

## 合约call调用

### **`platonCall`**


**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| code | ExecuteCode  | 交易类型，普通合约传ContractExecute |
| contractAddress | String | 合约地址 |
| functionName  | String  | 函数名称                   |
| from  | String  | 合约调用账户地址，可为空                   |
| params  | [Data]  | 参数，如果无参，传[]                   |
| outputs  | [SolidityParameter]  | 返回值类型                   |
| completion  | ContractCallCompletion  | 回调闭包                   |

ExecuteCode含义如下

```
public enum ExecuteCode {
case Transfer           //主币转账交易
case ContractDeploy     //合约发布
case ContractExecute    //合约调用
case Vote               //投票
case Authority          //权限
case MPCTransaction     //MPC交易
case CampaignPledge     //竞选质押
case ReducePledge       //减持质押   
case DrawPledge         //提取质押
case InnerContract      //内置合约调用
}
```

ContractCallCompletion定义如下

```
public typealias ContractCallCompletion = (
_ result : PlatonCommonResult,      //执行结果
_ data : AnyObject?                 //返回数据
) -> ()
```

示例：

```
    func getName(){
        guard contractAddress != nil else {
            print("deploy contract first!")
            return
        }
        let paramter = SolidityFunctionParameter(name: "whateverkey", type: .string)
        web3.eth.platonCall(code: ExecuteCode.ContractExecute, contractAddress: self.contractAddress!, functionName: "getName", from: nil, params: [], outputs: [paramter]) { (result, data) in
            switch result{
            case .success:
                if let dic = data as? Dictionary<String, String>{
                    print("return: \(String(describing: dic["whateverkey"]))")
                }else{
                    print("return empty value")
                }
            case .fail(let code, let errorMsg):
                print("error code: \(String(describing: code)), msg:\(String(describing: errorMsg))")
            }
        }
    }
```

## 合约sendRawTransaction调用

### **`platonSendRawTransaction`**

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| code | ExecuteCode  | 交易类型，普通合约传ContractExecute |
| contractAddress | String | 合约地址 |
| functionName  | String  | 函数名称                   |
| params  | [Data]  | 参数，如果无参，传[]                   |
| sender  | String  | 账户地址                   |
| privateKey  | String  | 私钥，需要与账户地址对应                   |
| gasPrice  | BigUInt  | 手续费用，Energon价格                   |
| gas  | BigUInt  | 手续费用，Energon数量                   |
| estimateGas  | Bool  | 是否估算gas                   |
| completion  | ContractSendRawCompletion  | 回调闭包                   |

ContractSendRawCompletion定义如下

```
public typealias ContractSendRawCompletion = (
_ result : PlatonCommonResult,          //执行结果
_ data : Data?                          //交易hash
) -> ()
```

示例：

```
    func invokeNotify(msg: String){
        
        guard contractAddress != nil else {
            print("ERROR:deploy contract first!")
            return
        }
        
        let msg_s = SolidityWrappedValue.string(msg)
        let msg_d = Data(hex: msg_s.value.abiEncode(dynamic: false)!)
        
        web3.eth.platonSendRawTransaction(code: ExecuteCode.ContractExecute, contractAddress: self.contractAddress!, functionName: "invokeNotify", params: [msg_d], sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: nil, estimated: false) { (result, data) in
            switch result{
            case .success:
                print("transaction success, hash: \(String(describing: data?.toHexString()))")
                self.invokeNotifyHash = data?.toHexString()
            case .fail(let code, let errorMsg):
                print("error code: \(String(describing: code)), msg:\(String(describing: errorMsg))")
            }
        }
    }

```

## 合约Event

### **`platonGetTransactionReceipt`**


**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| txHash | String  | 交易类型，普通合约传ContractExecute |
| loopTime | Int | 轮询次数 |
| completion  | PlatonCommonCompletion  | 回调闭包                   |

PlatonCommonCompletion定义如下

```
public typealias PlatonCommonCompletion = (
_ result : PlatonCommonResult,          //执行结果
_ obj : AnyObject?                      //返回数据
) -> ()
```

示例：

```
    func Notify(){
        guard self.invokeNotifyHash != nil else {
            print("ERROR:invoke invokeNotify first!")
            return
        }
        web3.eth.platonGetTransactionReceipt(txHash: self.invokeNotifyHash!, loopTime: 15) { (result, data) in
            switch result{
            case .success:
                if let receipt = data as? EthereumTransactionReceiptObject{
                    let rlpItem = try? RLPDecoder().decode((receipt.logs.first?.data.bytes)!)
                    let code = ABI.uint64Decode(data: Data(rlpItem!.array![0].bytes!))
                    let message = ABI.stringDecode(data: Data(rlpItem!.array![1].bytes!))
                    print("code:\(code) message:\(message)")
                }
            case .fail(let code, let errorMsg):
                print("error code: \(String(describing: code)), msg:\(String(describing: errorMsg))")
            }
        }
    }

```

## 内置合约
###  CandidateContract
> PlatOn经济模型中候选人相关的合约接口 [合约描述](https://note.youdao.com/)


#### **`CandidateDeposit`**
> 节点候选人申请/增加质押

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| nodeId | String  | 节点id, 16进制格式， 0x开头 |
| owner | String | 质押金退款地址, 16进制格式， 0x开头 |
| fee | BigInteger |  出块奖励佣金比，以10000为基数(eg：5%，则fee=500) |
| host | String | 节点IP  |
| port | String | 节点P2P端口号 |
| Extra | String | 附加数据，json格式字符串类型 |
| sender  | String  | 账户地址                   |
| privateKey  | String  | 私钥，需要与账户地址对应                   |
| gasPrice  | BigUInt  | 手续费用，Energon价格                   |
| gas  | BigUInt  | 手续费用，Energon数量                   |
| value  | BigUInt  | 质押金额                   |
| completion  | PlatonCommonCompletion  | 回调闭包                   |


Extra描述
```
{
    "nodeName":string,                     //节点名称
    "officialWebsite":string,              //官网 http | https
    "nodePortrait":string,                 //节点logo http | https
    "nodeDiscription":string,              //机构简介
    "nodeDepartment":string                //机构名称
}
```



出参（事件：CandidateDepositEvent）：
* `Ret`: bool 操作结果
* `ErrMsg`: string 错误信息

合约方法
```
    func CandidateDeposit(){
        let nodeId = "0x6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3";//节点id
        let owner = "0xf8f3978c14f585c920718c27853e2380d6f5db36"; //质押金退款地址
        let fee = UInt64(500)
        let host = "192.168.9.76"; //节点IP
        let port = "26794"; //节点P2P端口号
        
        var extra : Dictionary<String,String> = [:]
        extra["nodeName"] = "xxxx-noedeName"
        extra["nodePortrait"] = "http://192.168.9.86:8082/group2/M00/00/00/wKgJVlr0KDyAGSddAAYKKe2rswE261.png"
        extra["nodeDiscription"] = "xxxx-nodeDiscription"
        extra["nodeDepartment"] = "xxxx-nodeDepartment"
        extra["officialWebsite"] = "https://www.platon.network/"
        
        var theJSONText : String = ""
        if let theJSONData = try? JSONSerialization.data(withJSONObject: extra,options: []) {
            theJSONText = String(data: theJSONData,
                                 encoding: .utf8)!
        }
        
        contract.CandidateDeposit(nodeId: nodeId, owner: owner, fee: fee, host: host, port: port, extra: theJSONText, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: BigUInt("500")!) { (result, data) in
            switch result{
            case .success:
                print("Transaction success")
                if let data = data as? Data{
                    web3.eth.platonGetTransactionReceipt(txHash: data.toHexString(), loopTime: 15, completion: { (result, receipt) in
                        if let receipt = receipt as? EthereumTransactionReceiptObject{
                            if String((receipt.status?.quantity)!) == "1"{
                                let rlpItem = try? RLPDecoder().decode((receipt.logs.first?.data.bytes)!)
                                if (rlpItem?.array?.count)! > 0{
                                    let message = ABI.stringDecode(data: Data(rlpItem!.array![0].bytes!))
                                    print("message:\(message)")
                                }
                                print("CandidateDeposit success")
                            }else if String((receipt.status?.quantity)!) == "0"{
                                print("CandidateDeposit receipt status: 0")
                            }
                        }
                    })
                }else{
                    print("CandidateDeposit empty transaction hash")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`CandidateApplyWithdraw`**
> 节点质押金退回申请，申请成功后节点将被重新排序，发起的地址必须是质押金退款的地址 from==owner

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| nodeId | String  | 节点id, 16进制格式， 0x开头 |
| withdraw | BigInteger |  退款金额 (单位：wei) |
| sender  | String  | 账户地址                   |
| privateKey  | String  | 私钥，需要与账户地址对应                   |
| gasPrice  | BigUInt  | 手续费用，Energon价格                   |
| gas  | BigUInt  | 手续费用，Energon数量                   |
| value  | BigUInt  | 转账金额，一般为nil                   |
| completion  | PlatonCommonCompletion  | 回调闭包                   |

**返回事件**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| param1 | String | 执行结果，json格式字符串类型 |

param1描述
```
{
    "Ret":boolean,                         //是否成功 true:成功  false:失败
    "ErrMsg":string                        //错误信息，失败时存在
}
```

**合约使用**
```
    func CandidateApplyWithdraw(){
        let nodeId = "0x6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3";
        //退款金额, 单位 wei
        let value = BigUInt("500")!
        //must be owner
        let owner = "f8f3978c14f585c920718c27853e2380d6f5db36"
        let ownerPrivateKey = "74df7c508a4e20a3da81b331e2168cff9e6bc085e1968a30a05daf85ae654ed6"
        contract.CandidateApplyWithdraw(nodeId: nodeId,withdraw: value,sender: owner,privateKey: ownerPrivateKey,gasPrice: gasPrice,gas: gas,value: BigUInt(0)) { (result, data) in
            switch result{
            case .success:
                print("CandidateApplyWithdraw success")
                if let data = data as? Data{
                    web3.eth.platonGetTransactionReceipt(txHash: data.toHexString(), loopTime: 15, completion: { (result, receipt) in
                        if let receipt = receipt as? EthereumTransactionReceiptObject{
                            if String((receipt.status?.quantity)!) == "1"{
                                let rlpItem = try? RLPDecoder().decode((receipt.logs.first?.data.bytes)!)
                                if (rlpItem?.array?.count)! > 0{
                                    let message = ABI.stringDecode(data: Data(rlpItem!.array![0].bytes!))
                                    print("message:\(message)")
                                }
                                print("CandidateApplyWithdraw success")
                            }else if String((receipt.status?.quantity)!) == "0"{
                                print("CandidateApplyWithdraw receipt status: 0")
                            }
                        }
                    })
                }else{
                    print("CandidateApplyWithdraw empty transaction hash")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`CandidateWithdraw`**
> 节点质押金提取，调用成功后会提取所有已申请退回的质押金到owner账户。

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| nodeId | String  | 节点id, 16进制格式， 0x开头 |
| sender  | String  | 账户地址                   |
| privateKey  | String  | 私钥，需要与账户地址对应                   |
| gasPrice  | BigUInt  | 手续费用，Energon价格                   |
| gas  | BigUInt  | 手续费用，Energon数量                   |
| value  | BigUInt  | 转账金额，一般为nil                   |
| completion  | PlatonCommonCompletion  | 回调闭包                   |

**返回事件**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| param1 | String | 执行结果，json格式字符串类型 |

param1描述
```
{
    "Ret":boolean,                         //是否成功 true:成功  false:失败
    "ErrMsg":string                        //错误信息，失败时存在
}
```

**合约使用**
```
    func CandidateWithdraw(){
        let nodeId = "0x6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3";
        contract.CandidateWithdraw(nodeId: nodeId,sender: sender,privateKey: privateKey,gasPrice: gasPrice,gas: gas,value: BigUInt(0)) { (result, data) in
            switch result{
            case .success:
                print("send Transaction success")
                if let data = data as? Data{
                    web3.eth.platonGetTransactionReceipt(txHash: data.toHexString(), loopTime: 15, completion: { (result, receipt) in
                        if let receipt = receipt as? EthereumTransactionReceiptObject{
                            if String((receipt.status?.quantity)!) == "1"{
                                let rlpItem = try? RLPDecoder().decode((receipt.logs.first?.data.bytes)!)
                                if (rlpItem?.array?.count)! > 0{
                                    let message = ABI.stringDecode(data: Data(rlpItem!.array![0].bytes!))
                                    print("message:\(message)")
                                }
                                print("CandidateWithdraw success")
                            }else if String((receipt.status?.quantity)!) == "0"{
                                print("CandidateWithdraw receipt status: 0")
                            }
                        }
                    })
                }else{
                    print("CandidateWithdraw empty transaction hash")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`SetCandidateExtra`**
> 设置节点附加信息, 发起的地址必须是质押金退款的地址 from==owner

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| Extra | String | 附加数据，json格式字符串类型 |
| sender  | String  | 账户地址                   |
| privateKey  | String  | 私钥，需要与账户地址对应                   |
| gasPrice  | BigUInt  | 手续费用，Energon价格                   |
| gas  | BigUInt  | 手续费用，Energon数量                   |
| value  | BigUInt  | 转账金额，一般为nil                   |
| completion  | PlatonCommonCompletion  | 回调闭包                   |
Extra描述
```
{
    "nodeName":string,                     //节点名称
    "officialWebsite":string,              //官网 http | https
    "nodePortrait":string,                 //节点logo http | https
    "nodeDiscription":string,              //机构简介
    "nodeDepartment":string                //机构名称
}
```

**返回事件**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| param1 | String | 执行结果，json格式字符串类型 |

param1描述
```
{
    "Ret":boolean,                         //是否成功 true:成功  false:失败
    "ErrMsg":string                        //错误信息，失败时存在
}
```

**合约使用**
```
    func SetCandidateExtra(){
        let nodeId = "0x6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3";//节点id
        var extra : Dictionary<String,String> = [:]
        extra["nodeName"] = "xxxx-noedeName"
        extra["nodePortrait"] = "group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg"
        extra["nodeDiscription"] = "xxxx-nodeDiscription1"
        extra["nodeDepartment"] = "xxxx-nodeDepartment"
        extra["officialWebsite"] = "xxxx-officialWebsite"
        
        var theJSONText : String = ""
        if let theJSONData = try? JSONSerialization.data(withJSONObject: extra,options: []) {
            theJSONText = String(data: theJSONData,
                                 encoding: .utf8)!
        }
        //must be owner
        let owner = "f8f3978c14f585c920718c27853e2380d6f5db36"
        let ownerPrivateKey = "74df7c508a4e20a3da81b331e2168cff9e6bc085e1968a30a05daf85ae654ed6"
        contract.SetCandidateExtra(nodeId: nodeId, extra: theJSONText, sender: owner, privateKey: ownerPrivateKey, gasPrice: gasPrice, gas: gas, value: nil) { (result, data) in
            switch result{
            case .success:
                print("send Transaction success")
                if let data = data as? Data{
                    web3.eth.platonGetTransactionReceipt(txHash: data.toHexString(), loopTime: 15, completion: { (result, receipt) in
                        if let receipt = receipt as? EthereumTransactionReceiptObject{
                            if String((receipt.status?.quantity)!) == "1"{
                                let rlpItem = try? RLPDecoder().decode((receipt.logs.first?.data.bytes)!)
                                if (rlpItem?.array?.count)! > 0{
                                    let message = ABI.stringDecode(data: Data(rlpItem!.array![0].bytes!))
                                    print("message:\(message)")
                                }
                                print("SetCandidateExtra success")
                            }else if String((receipt.status?.quantity)!) == "0"{
                                print("SetCandidateExtra receipt status: 0")
                            }
                        }
                    })
                }else{
                    print("SetCandidateExtra empty transaction hash")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`CandidateWithdrawInfos`**
> 获取节点申请的退款记录列表

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| nodeId | String  | 节点id, 16进制格式， 0x开头 |

**返回**

- String：json格式字符串

```
{
    "Ret": true,                      
    "ErrMsg": "success",
    "Infos": [{                        //退款记录
        "Balance": 100,                //退款金额
        "LockNumber": 13112,           //退款申请所在块高
        "LockBlockCycle": 1            //退款金额锁定周期
    }]
}
```

**合约使用**
```
    func CandidateWithdrawInfos() {
        contract.CandidateWithdrawInfos(nodeId: "0x6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3") { (result, data) in
            switch result{
            case .success:
                if let data = data as? String{
                    print("result:\(data)")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`CandidateDetails`**
> 获取候选人信息

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| nodeId | String  | 节点id, 16进制格式， 0x开头 |

**返回**

- String：json格式字符串

```
{
    //质押金额 
    "Deposit": 200,    
    //质押金更新的最新块高
    "BlockNumber": 12206,
    //所在区块交易索引
    "TxIndex": 0,
    //节点Id
    "CandidateId": "6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3",
    //节点IP
    "Host": "192.168.9.76",
    //节点P2P端口号
    "Port": "26794",
    //质押金退款地址
    "Owner": "0xf8f3978c14f585c920718c27853e2380d6f5db36",
    //最新质押交易的发送方
    "From": "0x493301712671ada506ba6ca7891f436d29185821",
    //附加数据
    "Extra": "{\"nodeName\":\"xxxx-noedeName\",\"officialWebsite\":\"xxxx-officialWebsite\",\"nodePortrait\":\"group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg\",\"nodeDiscription\":\"xxxx-nodeDiscription1\",\"nodeDepartment\":\"xxxx-nodeDepartment\"}",
    //出块奖励佣金比，以10000为基数(eg：5%，则fee=500)
    "Fee": 500
}
```

**合约使用**
```
    func CandidateDetails(){
        contract.CandidateDetails(nodeId: "0x6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3") { (result, data) in
            switch result{
            case .success:
                if let data = data as? String{
                    print("result:\(data)")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`GetBatchCandidateDetail`**
> 批量获取候选人信息

**入参**

| **参数名** | **类型** | **参数说明** |
| ------ | ------ | ------ |
| nodeIds | String  | 节点id列表，中间通过`:`号分割 |

**返回**

- String：json格式字符串

```
[{
    "Deposit": 11100000000000000000,
    "BlockNumber": 13721,
    "TxIndex": 0,
    "CandidateId": "c0e69057ec222ab257f68ca79d0e74fdb720261bcdbdfa83502d509a5ad032b29d57c6273f1c62f51d689644b4d446064a7c8279ff9abd01fa846a3555395535",
    "Host": "192.168.9.76",
    "Port": "26793",
    "Owner": "0x3ef573e439071c87fe54287f07fe1fd8614f134c",
    "From": "0x3ef573e439071c87fe54287f07fe1fd8614f134c",
    "Extra": "{\"nodeName\":\"xxxx-noedeName\",\"officialWebsite\":\"xxxx-officialWebsite\",\"nodePortrait\":\"group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg\",\"nodeDiscription\":\"xxxx-nodeDiscription1\",\"nodeDepartment\":\"xxxx-nodeDepartment\"}",
    "Fee": 9900
}, {
    "Deposit": 200,
    "BlockNumber": 12206,
    "TxIndex": 0,
    "CandidateId": "6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3",
    "Host": "192.168.9.76",
    "Port": "26794",
    "Owner": "0xf8f3978c14f585c920718c27853e2380d6f5db36",
    "From": "0x493301712671ada506ba6ca7891f436d29185821",
    "Extra": "{\"nodeName\":\"xxxx-noedeName\",\"officialWebsite\":\"xxxx-officialWebsite\",\"nodePortrait\":\"group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg\",\"nodeDiscription\":\"xxxx-nodeDiscription1\",\"nodeDepartment\":\"xxxx-nodeDepartment\"}",
    "Fee": 500
}]
```

**合约使用**
```
    func GetBatchCandidateDetail(){
       var nodes = "0x6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3"
        nodes = nodes + ":"
        nodes = nodes + "0xc0e69057ec222ab257f68ca79d0e74fdb720261bcdbdfa83502d509a5ad032b29d57c6273f1c62f51d689644b4d446064a7c8279ff9abd01fa846a3555395535"

        contract.GetBatchCandidateDetail(batchNodeIds: nodes) { (result, data) in
            switch result{
            case .success:
                if let data = data as? String{
                    print("result:\(data)")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`CandidateList`**
> 获取所有入围节点的信息列表

**入参**

无

**返回**

- String：json格式字符串

```
[{
    "Deposit": 11100000000000000000,
    "BlockNumber": 13721,
    "TxIndex": 0,
    "CandidateId": "c0e69057ec222ab257f68ca79d0e74fdb720261bcdbdfa83502d509a5ad032b29d57c6273f1c62f51d689644b4d446064a7c8279ff9abd01fa846a3555395535",
    "Host": "192.168.9.76",
    "Port": "26793",
    "Owner": "0x3ef573e439071c87fe54287f07fe1fd8614f134c",
    "From": "0x3ef573e439071c87fe54287f07fe1fd8614f134c",
    "Extra": "{\"nodeName\":\"xxxx-noedeName\",\"officialWebsite\":\"xxxx-officialWebsite\",\"nodePortrait\":\"group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg\",\"nodeDiscription\":\"xxxx-nodeDiscription1\",\"nodeDepartment\":\"xxxx-nodeDepartment\"}",
    "Fee": 9900
}, {
    "Deposit": 200,
    "BlockNumber": 12206,
    "TxIndex": 0,
    "CandidateId": "6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3",
    "Host": "192.168.9.76",
    "Port": "26794",
    "Owner": "0xf8f3978c14f585c920718c27853e2380d6f5db36",
    "From": "0x493301712671ada506ba6ca7891f436d29185821",
    "Extra": "{\"nodeName\":\"xxxx-noedeName\",\"officialWebsite\":\"xxxx-officialWebsite\",\"nodePortrait\":\"group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg\",\"nodeDiscription\":\"xxxx-nodeDiscription1\",\"nodeDepartment\":\"xxxx-nodeDepartment\"}",
    "Fee": 500
}]
```

**合约使用**
```
    func CandidateList(){
        contract.CandidateList { (result, data) in
            switch result{
            case .success:
                if let data = data as? String{
                    print("result:\(data)")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

#### **`VerifiersList`**
> 获取参与当前共识的验证人列表

**入参**

无

**返回**

- String：json格式字符串

```
[{
    "Deposit": 11100000000000000000,
    "BlockNumber": 13721,
    "TxIndex": 0,
    "CandidateId": "c0e69057ec222ab257f68ca79d0e74fdb720261bcdbdfa83502d509a5ad032b29d57c6273f1c62f51d689644b4d446064a7c8279ff9abd01fa846a3555395535",
    "Host": "192.168.9.76",
    "Port": "26793",
    "Owner": "0x3ef573e439071c87fe54287f07fe1fd8614f134c",
    "From": "0x3ef573e439071c87fe54287f07fe1fd8614f134c",
    "Extra": "{\"nodeName\":\"xxxx-noedeName\",\"officialWebsite\":\"xxxx-officialWebsite\",\"nodePortrait\":\"group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg\",\"nodeDiscription\":\"xxxx-nodeDiscription1\",\"nodeDepartment\":\"xxxx-nodeDepartment\"}",
    "Fee": 9900
}, {
    "Deposit": 200,
    "BlockNumber": 12206,
    "TxIndex": 0,
    "CandidateId": "6bad331aa2ec6096b2b6034570e1761d687575b38c3afc3a3b5f892dac4c86d0fc59ead0f0933ae041c0b6b43a7261f1529bad5189be4fba343875548dc9efd3",
    "Host": "192.168.9.76",
    "Port": "26794",
    "Owner": "0xf8f3978c14f585c920718c27853e2380d6f5db36",
    "From": "0x493301712671ada506ba6ca7891f436d29185821",
    "Extra": "{\"nodeName\":\"xxxx-noedeName\",\"officialWebsite\":\"xxxx-officialWebsite\",\"nodePortrait\":\"group2/M00/00/12/wKgJVlw0XSyAY78cAAH3BKJzz9Y83.jpeg\",\"nodeDiscription\":\"xxxx-nodeDiscription1\",\"nodeDepartment\":\"xxxx-nodeDepartment\"}",
    "Fee": 500
}]
```

合约使用：
```
    func VerifiersList(){
        contract.VerifiersList { (result, data) in
            switch result{
            case .success:
                if let data = data as? String{
                    print("result:\(data)")
                }
            case .fail(let code, let errMsg):
                print("error code:\(code ?? 0) errMsg:\(errMsg ?? "")")
            }
        }
    }
```

# web3
## web3 eth相关 (标准JSON RPC )
- Swift可 api的使用请参考[Web3.swift github](https://github.com/Boilertalk/Web3.swift)
