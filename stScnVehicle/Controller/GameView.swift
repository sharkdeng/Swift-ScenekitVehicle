//
//  GameView.swift
//  stScnVehicle
//
//  Created by sj on 27/03/2018.
//  Copyright © 2018 sj. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit


class GameView: SCNView {
    var touchCount: Int = 0
    var inCarView: Bool = true
    
    func changePOV(){
        //get cameras
        let pointOfViews: [SCNNode] = self.scene!.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            return node.camera != nil
        })
        
        let currentPOV = self.pointOfView
        
        //select next one
        var index: Int = pointOfViews.index(of: currentPOV!)!
        index += 1
        if index >= pointOfViews.count { index = 0 }
        
        //1st camera
        self.inCarView = (index == 0)
        
        //implicit animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 4.0
        self.pointOfView = pointOfViews[index]
        SCNTransaction.commit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touche = touches.first
        
        //whether we touch camera icon
        let skScene = self.overlaySKScene!
        var p = touche!.location(in: self)
        p = skScene.convertPoint(fromView: p)
    
        let nodes = skScene.nodes(at: p)
        for node in nodes {
            
            if node.name == "camera" {
                //play a sound
                node.run(SKAction.playSoundFileNamed("click.caf", waitForCompletion: false))
                self.changePOV()
                return 
            }
            
            //added by shark
            //show mask
            if node.name == "intro" {
                self.toggleIntro()
            }
            
            //hide mask
            if node.name == "mask" {
                node.removeFromParent()
            }
        }
        
        
        touchCount = touches.count
    }
    
    
    
    var introlDisplay: Bool = false
    func toggleIntro(){
        let skScene = self.overlaySKScene
        
        //whether intor is shown
        for node in skScene!.children {
            if node.name == "mask" {
                introlDisplay = true
            } else{
                introlDisplay = false
            }
        }
        
        if !introlDisplay {
            //mask
            let mask = SKSpriteNode(color: .orange, size: self.frame.size)
            mask.alpha = 0.9
            skScene?.addChild(mask)
            mask.name = "mask"
            
            let label = SKLabelNode(text: "1 finger to accelerate\n2 fingers to backward\n3 fingers to brake\n2 taps with 2 fingers to reset")
            label.fontColor = SKColor.black
            label.numberOfLines = 0
            label.verticalAlignmentMode = .center
            mask.addChild(label)
        } else {
            return
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       touchCount = 0
    }
}
