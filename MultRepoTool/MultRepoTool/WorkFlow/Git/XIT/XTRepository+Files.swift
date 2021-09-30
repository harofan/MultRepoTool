import Foundation


public enum FileContext
{
  case commit(Commit)
  case index
  case workspace
}

// MARK: FileContents
extension XTRepository: FileContents
{
  static let textNames = ["AUTHORS", "CONTRIBUTING", "COPYING", "LICENSE",
                          "Makefile", "README"]
  
  static func isTextExtension(_ name: String) -> Bool
  {
    let ext = (name as NSString).pathExtension
    guard !ext.isEmpty
    else { return false }
    
    let unmanaged = UTTypeCreatePreferredIdentifierForTag(
          kUTTagClassFilenameExtension, ext as CFString, nil)
    let utType = unmanaged?.takeRetainedValue()
    
    return utType.map { UTTypeConformsTo($0, kUTTypeText) } ?? false
  }
  
  /// Returns true if the file seems to be text, based on its name or its content.
  /// - parameter path: File path relative to the repository
  /// - parameter context: Where to look for the specified file
  public func isTextFile(_ path: String, context: FileContext) -> Bool
  {
    let name = (path as NSString).lastPathComponent
    guard !name.isEmpty
    else { return false }
    
    if XTRepository.textNames.contains(name) {
      return true
    }
    if XTRepository.isTextExtension(name) {
      return true
    }
    
    switch context {
      case .commit(let commit):
        if let blob = commit.tree?.entry(path: path)?.object as? Blob {
          return !blob.isBinary
        }
      case .index:
        if let oid = GitIndex(repository: gitRepo)?.entry(at: path)?.oid,
           let blob = GitBlob(repository: gitRepo, oid: oid) {
          return !blob.isBinary
        }
      case .workspace:
        let url = self.fileURL(path)
        guard let data = try? Data(contentsOf: url)
        else { return false }
        
        return !data.isBinary()
    }
    
    return false
  }
  
  public func contentsOfFile(path: String, at commit: Commit) -> Data?
  {
    // TODO: make a Tree protocol to eliminate this cast
    guard let commit = commit as? GitCommit,
          let tree = commit.tree,
          let entry = tree.entry(path: path),
          let blob = entry.object as? Blob
    else { return nil }
    
    return blob.makeData()
  }
  
  public func contentsOfStagedFile(path: String) -> Data?
  {
    var result: Data?
    
    _ = try? stagedBlob(file: path)?.withData {
      (data) in
      result = (data as NSData).copy() as? Data
    }
    return result
  }
  
  public func stagedBlob(file: String) -> Blob?
  {
    guard let index = GitIndex(repository: gitRepo),
          let entry = index.entry(at: file),
          let blob = GitBlob(repository: gitRepo,
                             oid: entry.oid)
    else { return nil }
    
    return blob
  }
  
  func commitBlob(commit: Commit?, path: String) -> Blob?
  {
    return commit?.tree?.entry(path: path)?.object as? Blob
  }
  
  public func fileBlob(ref: String, path: String) -> Blob?
  {
    return commitBlob(commit: sha(forRef: ref).flatMap { commit(forSHA: $0) },
                      path: path)
  }
  
  public func fileBlob(sha: String, path: String) -> Blob?
  {
    return commitBlob(commit: commit(forSHA: sha), path: path)
  }
  
  public func fileBlob(oid: OID, path: String) -> Blob?
  {
    return commitBlob(commit: commit(forOID: oid), path: path)
  }
  
  /// Returns a file URL for a given relative path.
  public func fileURL(_ file: String) -> URL
  {
    return repoURL.appendingPathComponent(file)
  }
}

// MARK: FileDiffing
extension XTRepository: FileDiffing
{
  /// Returns a diff maker for a file at the specified commit, compared to the
  /// parent commit.
  public func diffMaker(forFile file: String,
                        commitOID: OID,
                        parentOID: OID?) -> PatchMaker.PatchResult?
  {
    guard let toCommit = commit(forOID: commitOID as! GitOID) as? GitCommit
    else { return nil }
    
    let parentCommit = parentOID.flatMap { commit(forOID: $0) }
    guard isTextFile(file, context: .commit(toCommit)) ||
          parentCommit.map({ isTextFile(file, context: .commit($0)) }) ?? false
    else { return .binary }
    
    var fromSource = PatchMaker.SourceType.data(Data())
    var toSource = PatchMaker.SourceType.data(Data())
    
    if let toTree = toCommit.tree,
       let toEntry = toTree.entry(path: file),
       let toBlob = toEntry.object as? GitBlob {
      toSource = .blob(toBlob)
    }
    
    if let fromTree = parentCommit?.tree,
       let fromEntry = fromTree.entry(path: file),
       let fromBlob = fromEntry.object as? GitBlob {
      fromSource = .blob(fromBlob)
    }
    
    return .diff(PatchMaker(from: fromSource, to: toSource, path: file))
  }
  
  // Returns a file diff for a given commit.
  public func diff(for path: String,
                   commitSHA sha: String,
                   parentOID: OID?) -> DiffDelta?
  {
    let diff = self.diff(forSHA: sha, parent: parentOID)
    
    return diff?.delta(forNewPath: path)
  }
  
  /// Returns a diff maker for a file in the index, compared to HEAD
  public func stagedDiff(file: String) -> PatchMaker.PatchResult?
  {
    guard isTextFile(file, context: .index)
    else { return .binary }
    
    guard let headRef = self.headRef
    else { return nil }
    let indexBlob = stagedBlob(file: file)
    let headBlob = fileBlob(ref: headRef, path: file)
    
    return .diff(PatchMaker(from: PatchMaker.SourceType(headBlob),
                             to: PatchMaker.SourceType(indexBlob),
                             path: file))
  }
  
  /// Returns a diff maker for a file in the index, compared to HEAD-1.
  public func amendingStagedDiff(file: String) -> PatchMaker.PatchResult?
  {
    guard isTextFile(file, context: .index)
    else { return .binary }
    
    guard let headCommit = headSHA.flatMap({ commit(forSHA: $0) })
    else { return nil }
    let blob = headCommit.parentSHAs.first
                         .flatMap { fileBlob(sha: $0, path: file) }
    let indexBlob = stagedBlob(file: file)

    return .diff(PatchMaker(from: PatchMaker.SourceType(blob),
                            to: PatchMaker.SourceType(indexBlob),
                            path: file))
  }
  
  /// Returns a diff maker for a file in the workspace, compared to the index.
  public func unstagedDiff(file: String) -> PatchMaker.PatchResult?
  {
    guard isTextFile(file, context: .workspace)
    else { return .binary }
    
    let url = self.repoURL.appendingPathComponent(file)
    let exists = FileManager.default.fileExists(atPath: url.path)
    
    do {
      let data = exists ? try Data(contentsOf: url) : Data()
      
      if let index = GitIndex(repository: gitRepo),
         let indexEntry = index.entry(at: file),
         let indexBlob = GitBlob.init(repository: gitRepo,
                                      oid: indexEntry.oid) {
        return .diff(PatchMaker(from: PatchMaker.SourceType(indexBlob),
                                 to: .data(data), path: file))
      }
      else {
        return .diff(PatchMaker(from: .data(Data()),
                                 to: .data(data),
                                 path: file))
      }
    }
    catch {
      return nil
    }
  }
  
  public func blame(for path: String,
                    from startOID: OID?, to endOID: OID?) -> Blame?
  {
    return GitBlame(repository: self, path: path, from: startOID, to: endOID)
  }
  
  public func blame(for path: String,
                    data fromData: Data?, to endOID: OID?) -> Blame?
  {
    return GitBlame(repository: self, path: path,
                    data: fromData ?? Data(), to: endOID)
  }
}

extension XTRepository
{
  /// Returns the diff for the referenced commit, compared to its first parent
  /// or to a specific parent.
  func diff(forSHA sha: String, parent parentOID: OID?) -> Diff?
  {
    let parentSHA = parentOID?.sha ?? ""
    let key = sha.appending(parentSHA)
    
    if let diff = diffCache[key] {
      return diff
    }
    else {
      guard let commit = commit(forSHA: sha)
      else { return nil }
      
      let parentSHAs = commit.parentSHAs
      let parentSHA: String? = parentSHA.isEmpty
            ? parentSHAs.first
            : parentSHAs.first { $0 == parentSHA }
      let parentCommit = parentSHA.map { self.commit(forSHA: $0) }
      
      guard let diff = GitDiff(oldTree: parentCommit??.tree, newTree: commit.tree,
                               repository: gitRepo)
      else { return nil }
      
      diffCache[key] = diff
      return diff
    }
  }
  
  /// Applies the given patch hunk to the specified file in the index.
  /// - parameter path: Target file path
  /// - parameter hunk: Hunk to be applied
  /// - parameter stage: True if the change is being staged, falses if unstaged
  /// (the patch should be reversed)
  /// - throws: `Error.patchMismatch` if the patch can't be applied, or any
  /// errors from resultings stage/unstage actions.
  func patchIndexFile(path: String, hunk: DiffHunk, stage: Bool) throws
  {
    guard let index = GitIndex(repository: gitRepo)
    else { throw RepoError.unexpected }
    
    if let entry = index.entry(at: path) {
      if (hunk.newStart == 1) || (hunk.oldStart == 1) {
        let status = try self.status(file: path)
        
        if stage {
          if status.0 == .deleted {
            try self.stage(file: path)
            return
          }
        }
        else {
          switch status.1 {
            case .added, .deleted:
              // If it's added/deleted in the index, and we're unstaging, then
              // the hunk must cover the whole file
              try unstage(file: path)
              return
            default:
              break
          }
        }
      }
      
      guard let blob = GitBlob(repository: gitRepo,
                               oid: entry.oid)
      else { throw RepoError.unexpected }
      
      try blob.withData {
        (data) in
        guard let text = String(data: data, encoding: .utf8),
              let patchedText = hunk.applied(to: text, reversed: !stage)
        else { throw RepoError.patchMismatch }
        
        guard let patchedData = patchedText.data(using: .utf8)
        else { throw RepoError.unexpected }
        
        try index.add(data: patchedData, path: path)
      }
      try index.save()
      return
    }
    else {
      let status = try self.status(file: path)
      
      // Assuming the hunk covers the whole file
      if stage && status.0 == .untracked && hunk.newStart == 1 {
        try self.stage(file: path)
        return
      }
      else if !stage && (status.1 == .deleted) && (hunk.oldStart == 1) {
        try unstage(file: path)
        return
      }
    }
    throw RepoError.patchMismatch
  }
  
  class StatusCollection: BidirectionalCollection
  {
    let statusList: OpaquePointer?
    var tree: OpaquePointer?
  
    init(repo: XTRepository, head: Commit?)
    {
      let headTree = (head?.tree as? GitTree)?.tree
      var options = git_status_options()
      
      git_status_init_options(&options, UInt32(GIT_STATUS_OPTIONS_VERSION))
      options.flags = GIT_STATUS_OPT_INCLUDE_UNTRACKED.rawValue |
                      GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS.rawValue
      if let tree = headTree {
        options.baseline = tree
      }
      else {
        tree = StatusCollection.emptyTree(repo: repo)
        options.baseline = tree
      }
      
      self.statusList = try? OpaquePointer.from {
        git_status_list_new(&$0, repo.gitRepo, &options)
      }
    }
    
    convenience init(repo: XTRepository)
    {
      self.init(repo: repo,
                head: repo.headSHA.flatMap { repo.commit(forSHA: $0) })
    }
  
    static func emptyTree(repo: XTRepository) -> OpaquePointer?
    {
      guard let emptyOID = GitOID(sha: kEmptyTreeHash)
      else { return nil }
      
      return try? OpaquePointer.from {
        (tree) in
        emptyOID.withUnsafeOID { git_tree_lookup(&tree, repo.gitRepo, $0) }
      }
    }
  
    subscript(position: Int) -> FileStagingChange
    {
      guard let statusList = self.statusList,
            let entry = git_status_byindex(statusList, position)?.pointee,
            let delta = entry.head_to_index ?? entry.index_to_workdir
      else { return FileStagingChange(path: "", destinationPath: "") }
      
      let path = String(cString: delta.pointee.old_file.path)
      let newPath = String(cString: delta.pointee.new_file.path)
      let stagedChange = (entry.head_to_index?.pointee.status)
            .map { DeltaStatus(gitDelta: $0) } ?? .unmodified
      
      return FileStagingChange(
          path: path,
          destinationPath: newPath,
          change: stagedChange)
    }
    
    public var startIndex: Int { 0 }
    public var endIndex: Int
    { statusList.map { git_status_list_entrycount($0) } ?? 0 }
    
    func index(before i: Int) -> Int { return i - 1 }
    func index(after i: Int) -> Int { return i + 1 }
    
    deinit
    {
      tree.map { git_tree_free($0) }
      statusList.map { git_status_list_free($0) }
    }
  }
  
  var stagingChanges: StatusCollection
  { StatusCollection(repo: self) }
  
  func amendingChanges(parent: Commit?) -> StatusCollection
  {
    return StatusCollection(repo: self, head: parent)
  }
}
