//
//  GitTool.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/27.
//
//

import Foundation

final class GitTool {
    /// 打tag
    /// - Parameter version: 版本号
    func tag(_ tagName: String) {
        
    }
    
    /// 提交message
    /// - Parameter message: 提交信息
    func commit(_ message: String) {
        
    }
    
    /// checkout分支
    /// - Parameter branch: 分支名
    func checkout(_ branch: String) {

    }
    
    /// 拉取远端,
    /// - Parameter branch: 分支名, 不传的话为当前分支
    func pull(_ branch: String? = nil) {
        shell("cd \(sourceDirectory) \n git pull")
    }
    
    func shell(_ cmd: String) {
        let myAppleScript = "on run\ndo shell script \"\(cmd)\"\n end run"
        print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            let result = scriptObject.executeAndReturnError(&error)
            print(result)
            assert(error == nil)
        }
    }
    
    /// 推送远端
    /// - Parameter branch: 分支名, 不传的话为当前分支
    func push(_ branch: String? = nil) {

    }
    
    func diff() {
        
    }
}
