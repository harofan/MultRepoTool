//
//  SpecScanner.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import Foundation

struct SpecScanner {
    static func scanSpec() -> [Spec] {
        let URL = URL(fileURLWithPath: sourceDirectory)
        var specs = [Spec]()
        do {
            let directorys = try FileManager.default.contentsOfDirectory(at: URL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            print(directorys)
            for directory in directorys {
                
            }
        } catch let error as NSError {
            print(error)
        }
        return []
    }
}
