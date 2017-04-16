//
//  RemoteControllableApp.swift
//  Transmit screenshot
//
//  Created by Thomas Gilbert on 12/11/15.
//  Copyright © 2015 Thomas Gilbert. All rights reserved.
//

import Foundation
import SocketIO

public final class RemoteControllableApp {
    
    public static let sharedInstance = RemoteControllableApp()
    
    fileprivate var remoteOverlay: UIView?
    fileprivate var socket: SocketIOClient?
    fileprivate var vendorId: String = UIDevice().identifierForVendor!.uuidString
    
    fileprivate init() {}
    
    public func startConnection(_ url: String = "localhost:8006", uuid: String = UIDevice().identifierForVendor!.uuidString) {
        debugPrint("Remote Connection called at: \(url)")
        vendorId = uuid;
        socket = SocketIOClient(socketURL: URL(string: url)!, config: [.log(true), .forcePolling(true)])
        setupHandlers()
    }
    
    /**
     Checks the status of the socket connection.
     Returns true if there is an active connection, false if there is none.
     */
    public func isConnected() -> Bool {
        debugPrint("Remote Connection Status Asked")
        if let socket = socket {
            return socket.status == SocketIOClientStatus.connected ? true : false
        } else {
            return false
        }
    }
    
    /**
     Closes the connection. Will stop transmitting screen and removes the ui overlay.
     Will turn off automatic reconnects.
     */
    public func stopConnection() {
        debugPrint("Remote Connection Closing")
        socket?.disconnect()
        socket = nil
    }
    
    fileprivate func setupHandlers() {
        socket?.on("draw dot") { [weak self] data, ack in
            debugPrint("Remote Connection Draw Dot \(data)")
            if let coords = data[0] as? NSDictionary, let x = coords["x"] as? Double, let y = coords["y"] as? Double  {
                self?.drawCircleOnOverlay(x, y: y)
            }
        }
        
        socket?.on("connect") {[weak self] data, ack in
            debugPrint("Remote Connection Connected")
            self?.requestSupport()
            self?.transmitScreen()
            self?.addRemotePresentationOverlay()
        }
        
        socket?.on("error") { ack in
            debugPrint("Remote Connection Error: \(ack)")
        }
        
        socket?.on("disconnect") {[weak self] data, ack in
            debugPrint("Remote Connection Disconnected")
            self?.removeRemotePresentationOverlay()
        }
        socket?.connect()
    }
    
    fileprivate func addRemotePresentationOverlay() {
        var window = UIApplication.shared.keyWindow
        if window == nil {
            window = UIApplication.shared.windows.first
        }
        
        if let overlay = remoteOverlay {
            overlay.removeFromSuperview()
            remoteOverlay = nil
        }
        
        if let window = window, remoteOverlay == nil {
            let overlay = UIView(frame: window.frame)
            overlay.layer.cornerRadius=2
            overlay.layer.borderWidth=5
            overlay.layer.borderColor = UIColor.red.cgColor
            overlay.isOpaque = true
            overlay.isUserInteractionEnabled = false
            overlay.layer.zPosition = CGFloat(CGFloat.greatestFiniteMagnitude)
            remoteOverlay = overlay
        }
        
        if let overlay = remoteOverlay, let window = window {
            window.addSubview(overlay)
        }
    }
    
    fileprivate func removeRemotePresentationOverlay() {
        if let overlay = remoteOverlay {
            overlay.removeFromSuperview()
            remoteOverlay = nil
        }
    }
    
    fileprivate func drawCircleOnOverlay(_ x: Double, y: Double) {
        if let overlay = remoteOverlay {
            let pointX = overlay.frame.size.width * CGFloat(x)
            let pointY = overlay.frame.size.height * CGFloat(y)
            
            let circle = Circle(frame: CGRect(x: pointX - 50, y: pointY - 50 ,width: 50,height: 50))
            circle.isOpaque = true
            circle.layer.cornerRadius = 25
            circle.clipsToBounds = true
            overlay.addSubview(circle)
            
            UIView.animate(withDuration: 0.8, animations: { () -> Void in
                circle.alpha = 0
                circle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { (ok) -> Void in
                circle.removeFromSuperview()
            })
        }
    }
    
    fileprivate func captureScreen() -> UIImage? {
        let windows = UIApplication.shared.windows
        
        if let _ = windows.first {
            UIGraphicsBeginImageContextWithOptions(windows.first!.frame.size, windows.first!.isOpaque, 0.0)
            for window in windows {
                UIGraphicsGetCurrentContext()
                window.drawHierarchy(in: CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height), afterScreenUpdates: false)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            return nil
        }
    }
    
    fileprivate func requestSupport() {
        guard socket?.status == SocketIOClientStatus.connected else {
            debugPrint("Remote Connection Not Connected - Will not transmit request support")
            return
        }
        
        let message = ["vendorid" : "\(vendorId)"]
        
        DispatchQueue.global(qos: .default).async {
            self.socket?.emit("request support", message)
            
            // Dispatch after sending the last request
            // this will make sure that we dont accumilate too many
            // requests on a slow connection
            let q_background = DispatchQueue.global(qos: .background)
            let delayInSeconds:Int64 = 5
            let popTime = DispatchTime.now() + Double(delayInSeconds * 1000000000) / Double(NSEC_PER_SEC)
            
            q_background.asyncAfter(deadline: popTime) { () -> Void in
                self.requestSupport()
            }
        }
    }
    
    fileprivate func transmitScreen() {
        guard socket?.status == SocketIOClientStatus.connected else {
            debugPrint("Remote Connection Not Connected - Will not transmit screenshot")
            return
        }
        
        if let image = captureScreen() {
            let smallerImage = UIImageJPEGRepresentation(image, 0.0)
            let base64String = smallerImage?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            if let base64String = base64String {
                let message = ["vendorid" : "\(vendorId)", "image" : base64String]
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.socket?.emit("upload image", message)
                    
                    // Dispatch after sending the image
                    // this will make sure that we dont accumilate too many
                    // images on a slow connection
                    let q_queue = DispatchQueue.main
                    let delayInSeconds:Int64 = 1
                    let popTime = DispatchTime.now() + Double(delayInSeconds * 1000000000) / Double(NSEC_PER_SEC)
                    
                    q_queue.asyncAfter(deadline: popTime) { () -> Void in
                        self.transmitScreen()
                    }
                }
            }
        }
    }
}

private class Circle: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        UIColor.blue.setFill()
        path.fill()
    }
}
