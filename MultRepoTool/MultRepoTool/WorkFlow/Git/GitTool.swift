//
//  GitTool.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/27.
//
//

import ObjectiveGit

final class GitTool {
    lazy var repo: GTRepository = try! GTRepository(url: URL(string: sourceDirectory)!)
    
    /// 打tag
    /// - Parameter version: 版本号
    func tag(_ version: String) {
//        repo.createLightweightTagNamed(<#T##tagName: String##String#>, target: <#T##GTObject#>)
//        _ = repo.tag(named: version)
    }
    
    /// 提交message
    /// - Parameter message: 提交信息
    func commit(_ message: String) {
//        _ = repo.commit(message: message, signature: caculateSignature())
    }
    
    /// checkout分支
    /// - Parameter branch: 分支名
    func checkout(_ branch: String) {
//        let branch = try! repo.localBranch(named: branch).get()
//        _ = repo.checkout(branch, strategy: .Safe)
    }
    
    /// 拉取远端,
    /// - Parameter branch: 分支名, 不传的话为当前分支
    func pull(_ branch: String? = nil) {
        // TODO: 暂时仅支持rebase-pull的方式
        // TODO: SwiftGit2暂时不支持pull && push, 可以考虑日后业务流程完善, 踩过坑后给他提个pr
//        let result = run(binPath, "git", "pull")
//        print(result.stdout)
        let branch = GTBranch(reference: GTReference()
        repo.pull(<#T##branch: GTBranch##GTBranch#>, from: <#T##GTRemote#>, withOptions: <#T##[AnyHashable : Any]?#>, progress: <#T##GTRemoteFetchTransferProgressBlock?##GTRemoteFetchTransferProgressBlock?##(UnsafePointer<git_transfer_progress>, UnsafeMutablePointer<ObjCBool>) -> Void#>)
    }
    
    /// 推送远端
    /// - Parameter branch: 分支名, 不传的话为当前分支
    func push(_ branch: String? = nil) {
//        let result = run(binPath, "git", "push")
//        print(result.stdout)
    }
    
    /// 计算OId
//    func caculateOId() -> OID {
////        OID(string: UUID().uuidString)!
//    }
//
//    /// 计算签名
//    func caculateSignature() -> Signature {
////        Signature(name: userName, email: email)
//    }
    
//    private func shell(_ args: [String]) -> String {
//        let task = Process()
//        task.launchPath = binPath
//        task.arguments = args
//        let pipe = Pipe()
//        task.standardOutput = pipe
//        task.launch()
//        task.waitUntilExit()
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
//        return output
//    }
}
