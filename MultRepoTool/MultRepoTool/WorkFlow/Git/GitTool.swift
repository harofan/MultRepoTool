//
//  GitTool.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/27.
//
//

import Foundation
import ShellOut

final class GitTool {
    /// 当前head打tag, 只存在本地,需要手动push
    /// - Parameter version: 版本号
    /// - Parameter tagMsg: 版本信息, 可以为空
    func tag(_ tagName: String, tagMsg: String?) {
        if let tagMessage = tagMsg {
            // 完整tag信息
            shell("cd \(sourceDirectory) \n git tag -a \(tagName) -m \"\(tagMessage)\"")
        } else {
            // 轻量化版本tag
            shell("cd \(sourceDirectory) \n git tag -a \(tagName)")
        }
    }
    
    /// 指定节点打tag, 只存在本地,需要手动push
    /// - Parameter version: 版本号
    /// - Parameter tagMsg: 版本信息, 可以为空
    /// - Parameter hash: 指定节点hash值
    func tag(_ tagName: String, tagMsg: String?, hash: String) {
        if let tagMessage = tagMsg {
            // 完整tag信息
            shell("cd \(sourceDirectory) \n git tag -a \(tagName) -m \"\(tagMessage)\" \(hash)")
        } else {
            // 轻量化版本tag
            shell("cd \(sourceDirectory) \n git tag -a \(tagName) \(hash)")
        }
    }
    
    /// 推送tag
    /// - Parameter tagName: tag名称, 不填写的话默认推送全部
    func pushTag(_ tagName: String? = nil) {
        if let tagName = tagName {
            // 推送指定tag
            shell("cd \(sourceDirectory) \n git push origin \(tagName)")
        } else {
            // 推送全部tag
            shell("cd \(sourceDirectory) \n git push origin --tags")
        }
    }
    
    /// 提交message
    /// - Parameter message: 提交信息
    func commit(_ message: String) {
        do {
            try shellOut(to: .gitCommit(message: message), at: sourceDirectory)
        } catch {
            let error = error as! ShellOutError
            print(error.message)
            print(error.output)
            assert(false)
        }
    }
    
    /// checkout分支
    /// - Parameter branch: 分支名
    func checkout(_ branch: String) {
        do {
            try shellOut(to: .gitCheckout(branch: branch), at: sourceDirectory)
        } catch {
            let error = error as! ShellOutError
            print(error.message)
            print(error.output)
            assert(false)
        }
    }
    
    /// 拉取远端,
    /// - Parameter branch: 分支名, 不传的话为当前分支
    func pull() {
        do {
            try shellOut(to: .gitPull(), at: sourceDirectory)
        } catch {
            let error = error as! ShellOutError
            print(error.message)
            print(error.output)
            assert(false)
        }
//        shell("cd \(sourceDirectory) \n git pull")
    }
    
    /// 推送远端
    /// - Parameter branch: 分支名, 不传的话为当前分支
    func push(_ branch: String? = nil) {
        do {
            try shellOut(to: .gitPush(), at: sourceDirectory)
        } catch {
            let error = error as! ShellOutError
            print(error.message)
            print(error.output)
            assert(false)
        }
//        shell("cd \(sourceDirectory) \n git push")
    }
    
    func diff() {
        
    }
    
    @discardableResult
    private func shell(_ cmd: String) -> NSAppleEventDescriptor? {
        let myAppleScript = "on run\ndo shell script \"\(cmd)\"\n end run"
        print(myAppleScript)
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            let result = scriptObject.executeAndReturnError(&error)
            print(result)
            assert(error == nil)
            return result
        }
        return nil
    }
}
