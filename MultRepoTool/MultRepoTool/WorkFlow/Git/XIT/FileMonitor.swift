import Foundation


class FileMonitor
{
  let path: String
  private var sourceMutex = Mutex()
  var fd: CInt = -1
  var source: DispatchSourceFileSystemObject?
  
  var notifyBlock: ((_ path: String, _ flags: UInt) -> Void)?
  
  init?(path: String)
  {
    self.path = path
    
    makeSource()
    if sourceMutex.withLock({ self.source }) == nil {
      return nil
    }
  }
  
  func makeSource()
  {
    fd = open(path, O_EVTONLY)
    guard fd >= 0
    else { return }
    
    let source = DispatchSource.makeFileSystemObjectSource(
        fileDescriptor: fd,
        eventMask: [.delete, .write, .extend, .attrib, .link, .rename, .revoke],
        queue: DispatchQueue.global())
    
    source.setEventHandler {
      [weak self] in
      guard let self = self
      else { return }
      
      self.sourceMutex.lock()
      defer { self.sourceMutex.unlock() }
      
      guard let source = self.source
      else { return }
      
      DispatchQueue.main.async {
        self.notifyBlock?(self.path, source.data)
      }
      if source.data.contains(.delete) {
        source.cancel()
        close(self.fd)
        self.sourceMutex.withLock {
          self.source = nil
        }
        self.makeSource()
      }
    }
    source.resume()
    sourceMutex.withLock {
      self.source = source
    }
  }
  
  deinit
  {
    source?.cancel()
    close(fd)
  }
}
