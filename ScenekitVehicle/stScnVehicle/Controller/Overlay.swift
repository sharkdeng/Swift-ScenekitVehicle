//
//  Overlay.swift
//  stScnVehicle
//
//  Created by sj on 27/03/2018.
//  Copyright © 2018 sj. All rights reserved.
//

import Foundation
import SpriteKit

class Overlay: SKScene {
    //VC need
    
    var speedHandle: SKNode!
    
    override init(size: CGSize) {
        super.init(size: size)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.scaleMode = .resizeFill
        
        //ipad?
        let ipad: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
        //let scale: Float = ipad? 1.5:1
        let scale: Float = 1
        
        //add gauge
        let gauge: SKSpriteNode = SKSpriteNode(imageNamed: "speedGauge.png")
        addChild(gauge)
        gauge.anchorPoint = CGPoint(x: 0.5, y: 0)
        gauge.position = CGPoint(x: size.width * 0.33, y: -size.height * 0.5)
        gauge.xScale = CGFloat(0.8 * scale)
        gauge.yScale = CGFloat(0.8 * scale)
        
        //add needle
        let needleHandle = SKNode()
        let needle = SKSpriteNode(imageNamed: "needle.png")
        gauge.addChild(needleHandle)
        needleHandle.addChild(needle)
        
        needleHandle.position = CGPoint(x: 0, y: 16)
        needle.anchorPoint = CGPoint(x: 0.5, y: 0)
        needle.xScale = 0.7
        needle.yScale = 0.7
        needle.zRotation = CGFloat.pi / 2
        
        speedHandle = needleHandle
       
        //add camera
        let camera = SKSpriteNode(imageNamed: "video_camera.png")
        addChild(camera)
        camera.name = "camera"
        camera.xScale = CGFloat(0.6 * scale)
        camera.yScale = CGFloat(0.6 * scale)
        camera.position = CGPoint(x: -size.width * 0.4, y: -size.height * 0.4)
        
        
        //add intro
        //added by shark
        let intro = SKShapeNode(ellipseIn: CGRect(x: 0, y: 0, width: 30, height: 30))
        addChild(intro)
        intro.strokeColor = SKColor.black
        intro.fillColor = SKColor.clear
        intro.position = CGPoint(x: camera.position.x - 20, y: camera.position.y + camera.size.height / 2 + 10)
        intro.name = "intro"
        
        let inner = SKShapeNode(ellipseIn: CGRect(x: 0, y: 0, width: 30, height: 30))
        intro.addChild(inner)
        inner.alpha = 0.8
        inner.fillColor = SKColor.white
       
        let label = SKLabelNode(text: "介绍")
        intro.addChild(label)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position.x += 15
        label.position.y += 15
        label.fontSize = 13
        label.fontColor = SKColor.black
       
    
        
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
