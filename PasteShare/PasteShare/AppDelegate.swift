//
//  AppDelegate.swift
//  PasteShare
//
//  Created by Floris-Jan Willemsen on 25-09-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let priority = DispatchQueue.GlobalQueuePriority.default
    var receivedString = ""

    @IBOutlet weak var imageView: NSImageView!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            let icon = NSImage(named: "MenuBarIcon")
            icon?.isTemplate = true
            button.image = icon
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Re-copy to clipboard", action: #selector(stringToPasteBoard(send:)), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Connect", action: #selector(connect(send:)), keyEquivalent: "d"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit ClipShare", action: #selector(AppDelegate.exitApp(send:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        DispatchQueue.global().async {
            self.runServer()
        }
        
        print(getIFAddresses())
        connect()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func echoService(client c:TCPClient){
        print("new client from: \(c.addr) [\(c.port)]")
        let d=c.read(1024*10)
        print(d)
        c.send(data: d!)
        c.close()
    }
    
    func getString(rawData: Array<UInt8>) -> String {
        let data = Data(bytes: rawData, count: Int(rawData.count))
        return String(data: data, encoding: String.Encoding.utf8)!
    }
    
    func getString(client c:TCPClient) -> String {
        let data = c.read(1024*10)
        return getString(rawData: data!)
    }
    
    func runServer(){
        let server:TCPServer = TCPServer(addr: getIFAddresses()[0], port: 60200)
        let (success,msg)=server.listen()
        if success{
            while true {
                if let client=server.accept(){
                    let data=client.read(1024*10)
                    print(data)
                    receivedString = getString(rawData: data!)
                    stringToPasteBoard(string: getString(rawData: data!))
                } else {
                    print("Error accepting the client")
                }
            }
        } else{
            print(msg)
        }
    }
    
    func stringToPasteBoard(string: String) {
        
        if string.characters.count >= 27 {
            let index = string.index(string.startIndex, offsetBy: 27)
            let substring = string.substring(to: index)
            if substring == "Succesful connection with;+" {
                let index = string.index(string.startIndex, offsetBy: 27)
                let model = string.substring(from: index)
                showNotification(title: "Connected", body: model)
                print("Connected to " + model)
            }
        } else {
            let pasteBoard = NSPasteboard.general()
            pasteBoard.clearContents()
            pasteBoard.writeObjects([string as NSPasteboardWriting])
            showNotification(title: "Copied to Clipboard", body: string)
            print("Copied to Clipboard: ", string)
        }
    }
    
    func stringToPasteBoard(send: AnyObject) {
        stringToPasteBoard(string: receivedString)
    }
    
    func connect() {
        let qrImage = generateQRCode(from: getIFAddresses()[0])
        qrImage?.size = NSSize(width: 500, height: 500)
        imageView.image = qrImage
        window.makeKeyAndOrderFront(nil)
    }
    
    func connect(send: AnyObject) {
        connect()
    }
    
    func exitApp(send: AnyObject) {
        exit(0)
    }

    func showNotification(title: String, body: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }
    
    func generateQRCode(from string: String) -> NSImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                let rep: NSCIImageRep = NSCIImageRep(ciImage: output)
                let nsImage: NSImage = NSImage(size: rep.size)
                nsImage.addRepresentation(rep)
                return nsImage
            }
        }
        
        return nil
    }
}

