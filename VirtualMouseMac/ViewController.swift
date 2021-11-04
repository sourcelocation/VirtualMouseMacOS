//
//  ViewController.swift
//  VirtualMouseMac
//
//  Created by exerhythm on 11/2/21.
//

import Cocoa
import PeertalkManager

class ViewController: NSViewController, PTManagerDelegate {
    
    var sensivity: Double = 35
    var acc = 1.2
    
    var leftMouseHeld = false
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data?, ofType type: UInt32) {
        switch type {
        case PTType.pos.rawValue:
            guard let str = String(data: data!, encoding: .utf8) else { return }
            let pos = str.components(separatedBy: ";").map { Double($0)! }
            mouseMoveBy(x: pos[1], y: pos[0])
        case PTType.clickleft.rawValue, PTType.clickright.rawValue:
            guard let str = String(data: data!, encoding: .utf8) else { return }
            print(str)
            switch str {
            case "down":
                mouseDown(point: CGPoint(x: NSEvent.mouseLocation.x, y: NSScreen.main!.frame.size.height - NSEvent.mouseLocation.y), mouseButton: type == 101 ? .left : .right)
                leftMouseHeld = true
            case "up":
                mouseUp(point: CGPoint(x: NSEvent.mouseLocation.x, y: NSScreen.main!.frame.size.height - NSEvent.mouseLocation.y), mouseButton: type == 101 ? .left : .right)
                leftMouseHeld = false
            default:
                break
            }
        default:
            break
        }
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print(connected)
    }
    
    
    let mngr = PTManager()
    
    @IBAction func start(_ sender: NSButton) {
        mngr.delegate = self
        mngr.connect(portNumber: 2345)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func mouseDown(point: CGPoint, mouseButton: CGMouseButton = CGMouseButton.left) {
        CGEvent(mouseEventSource: nil, mouseType: mouseButton == .left ? .leftMouseDown : .rightMouseDown, mouseCursorPosition: point, mouseButton: mouseButton)?.post(tap: CGEventTapLocation.cghidEventTap)
    }
    func mouseDrag(point: CGPoint, mouseButton: CGMouseButton = CGMouseButton.left) {
        CGEvent(mouseEventSource: nil, mouseType: mouseButton == .left ? .leftMouseDragged : .rightMouseDragged, mouseCursorPosition: point, mouseButton: mouseButton)?.post(tap: CGEventTapLocation.cghidEventTap)
    }
    func mouseUp(point: CGPoint, mouseButton: CGMouseButton = CGMouseButton.left) {
        CGEvent(mouseEventSource: nil, mouseType: mouseButton == .left ? .leftMouseUp : .rightMouseUp, mouseCursorPosition: point, mouseButton: mouseButton)?.post(tap: CGEventTapLocation.cghidEventTap)
    }

    func moveMouseTo(point: CGPoint) {
        CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: point, mouseButton: CGMouseButton.left)?.post(tap: CGEventTapLocation.cghidEventTap)
    }
    func mouseMoveBy(x: Double, y: Double) {
//        print(x,y)
        let screenSize = NSScreen.main?.frame.size
        let currentLocation = NSEvent.mouseLocation
        let destination = CGPoint(x: currentLocation.x + x * sensivity, y: screenSize!.height - (currentLocation.y - y * sensivity))
        
        if !leftMouseHeld {
            moveMouseTo(point: destination)
        } else {
            mouseDrag(point: destination)
        }
    }
}


enum PTType: UInt32 {
    case pos = 100
    case clickleft = 101
    case clickright = 102
}
