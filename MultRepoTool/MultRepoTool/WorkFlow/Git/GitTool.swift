//
//  GitTool.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/27.
//
//

//import ObjectiveGit
import Foundation

final class GitTool {
//    lazy var repo: XTRepository = try! XTReposito
//    guard let headOID = repository.headSHA.flatMap({ repository.oid(forSHA: $0) })
    /// 打tag
    /// - Parameter version: 版本号
    func tag(_ tagName: String) {
//        let repo = Repository()
//        crea
//        repo.createTagNamed(<#T##tagName: String##String#>, target: <#T##GTObject#>, tagger: <#T##GTSignature#>, message: <#T##String#>)
//        repo.createLightweightTagNamed(tagName, target: GTObject(obj: <#T##OpaquePointer#>, in: <#T##GTRepository#>)
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
        shell("git pull")
//        let repo = try? GTRepository(url: URL(string: sourceDirectory)!)
//        print(repo)
//        let configuration = try! repo.configuration()
//        guard let remote = configuration.remotes?.first else { fatalError("远端获取失败") }
//        var success: ObjCBool = false
//        let branch = try! repo.lookUpBranch(withName: "branch", type: .local, success: &success)
//        try! repo.pull(branch, from: remote, withOptions: nil, progress: nil)
    }
    
    /// 推送远端
    /// - Parameter branch: 分支名, 不传的话为当前分支
    func push(_ branch: String? = nil) {
//        let result = run(binPath, "git", "push")
//        print(result.stdout)
    }
    
    func diff() {
        
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
    
    func shell(at: String, _ args: String) {
        let task = Process()
        task.launchPath = at
        task.arguments = ["-c", args]

        let pipeStandard = Pipe()
        task.standardOutput = pipeStandard
        task.launch()

        let dataStandard = pipeStandard.fileHandleForReading.readDataToEndOfFile()
        let outputStandard = String(data: dataStandard, encoding: String.Encoding.utf8)!
        if outputStandard.count > 0  {
            let lastIndexStandard = outputStandard.index(before: outputStandard.endIndex)
            print(String(outputStandard[outputStandard.startIndex ..< lastIndexStandard]))
        }
        task.waitUntilExit()
    }
    
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin"
        task.arguments = args
        let pipeStandard = Pipe()
        task.standardOutput = pipeStandard
        task.launch()
        
        let dataStandard = pipeStandard.fileHandleForReading.readDataToEndOfFile()
        let outputStandard = String(data: dataStandard, encoding: String.Encoding.utf8)!
        if outputStandard.count > 0  {
            let lastIndexStandard = outputStandard.index(before: outputStandard.endIndex)
            print(String(outputStandard[outputStandard.startIndex ..< lastIndexStandard]))
        }
        
        task.waitUntilExit()
        return task.terminationStatus
    }
}


//BranchBlock localBranchWithName = ^ GTBranch * (NSString *branchName, GTRepository *repo) {
//    BOOL success = NO;
//    GTBranch *branch = [repo lookUpBranchWithName:branchName type:GTBranchTypeLocal success:&success error:NULL];
//    expect(branch).notTo(beNil());
//    expect(branch.shortName).to(equal(branchName));
//
//    return branch;
//};
