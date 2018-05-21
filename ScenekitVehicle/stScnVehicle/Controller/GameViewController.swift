//
//  GameViewController.swift
//  stScnVehicle
//
//  Created by sj on 27/03/2018.
//  Copyright © 2018 sj. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import SceneKit
import simd
import CoreMotion
import GameController
import CoreML
import CoreData
import Speech
import Vision
import CoreLocation


//helper
func SCNVector3ToFloat3(_ v: SCNVector3)-> float3 {
    return float3(v.x, v.y, v.z)
}

func SCNVector3FromFloat3(_ f3: float3) -> SCNVector3 {
    return SCNVector3(f3.x, f3.y, f3.z)
}

func SCNVector3FromFloat3(_ f1: Float, _ f2: Float, _ f3: Float) -> SCNVector3 {
    return SCNVector3(f1, f2, f3)
}




class GameViewController: UIViewController, SCNSceneRendererDelegate {

    
    //basoc 3 scene elems: 1 here, 1 light 1 camera
    var _spotLightNode: SCNNode!
    var _cameraNode: SCNNode!
    var _vehicleNode: SCNNode!
    
    var _vehicle: SCNPhysicsVehicle!
    var _reactor: SCNParticleSystem!
    
    //accelerator
    var _motionManager: CMMotionManager!
    var _accelerometer: [UIAccelerationValue]!
    var _orientation: CGFloat = 0
    
    var _reactorDefaultBirthRate: CGFloat = 0

    var _vehicleSteering: CGFloat = 0
    
    var _deviceName: String? {
        var deviceName: String? = nil
        if deviceName == nil {
            return UIDevice.current.name
        }
        
        return deviceName
    }
    
    /*
     * 为VC创建view
     * 1）找初始化中指定的xib
     * 2）没有，找VC同名的xib
     * 3）没有，为VC创建空的UIView
     * 4）如果自定义VC的view，不需要super，因为不需要默认的空UIView；直接self.view = 。。。即可
     */
    override func loadView() {
        self.view = GameView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    var gameView: GameView {
        return self.view as! GameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameView.backgroundColor = UIColor.blue

        gameView.scene = setupScene()
        
        gameView.scene?.physicsWorld.speed = 4.0
      
        gameView.overlaySKScene = Overlay(size: gameView.frame.size)

        gameView.pointOfView = _cameraNode
        
        gameView.delegate = self
        
        //add tap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2    //tap几下
        doubleTap.numberOfTouchesRequired = 2 //几根手指
        gameView.addGestureRecognizer(doubleTap)
        

    }

    
    override func viewDidDisappear(_ animated: Bool) {
        _motionManager.stopAccelerometerUpdates()
        _motionManager = nil

    }
    

    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
        let defaultEngineForce: CGFloat = 300
        let defaultBrakingForce: CGFloat = 3.0
        let steeingClamp: CGFloat = 0.6
        let cameraDamping: CGFloat = 0.3
        
        let scnView: GameView = self.view as! GameView
        var engineForce: CGFloat = 0
        var brakingForce: CGFloat = 0
        let controllers = [GCController]()
        var orientation = Float(_orientation)
        
        //drive:  1 touch = accelerate, 2 touches = backward, 3 touches = brake
        if scnView.touchCount == 1 {
            print("1 touche" )
            engineForce = defaultEngineForce
            
            //show vehicle fire
            _reactor.birthRate = _reactorDefaultBirthRate
            
            //2 fingers together
        } else if scnView.touchCount == 2 {
            
            engineForce = -defaultEngineForce
            _reactor.birthRate = 0
            
            
            //three fingers together - brake
        } else if scnView.touchCount == 3 {
            brakingForce = 100
            _reactor.birthRate = 0
            
        } else {
            //no touch
            brakingForce = defaultBrakingForce
            _reactor.birthRate = 0
        }
        
        
        //controller support
        if (controllers != nil) && controllers.count > 0 {
            let c = controllers[0]
            let pad: GCGamepad = c.gamepad!
            let dpad: GCControllerDirectionPad = pad.dpad
            
            var orientationCum: Float = 0
            let INCR_ORIENTATION: Float = 0.03
            let DECR_ORIENTATION: Float = 0.9
            
            if dpad.right.isPressed {
                if orientationCum < 0 {
                    orientationCum *= DECR_ORIENTATION
                    orientationCum += INCR_ORIENTATION
                    if orientationCum > 1 {
                        orientationCum = 1
                    }
                }
            } else if dpad.left.isPressed {
                if orientationCum > 0 {
                    orientationCum *= DECR_ORIENTATION
                    orientationCum -= INCR_ORIENTATION
                    if orientationCum < -1 {
                        orientationCum = -1
                    }
                }
            } else {
                orientationCum *= DECR_ORIENTATION
            }
            
            orientation = orientationCum
            
            
            if pad.buttonX.isPressed {
                engineForce = defaultEngineForce
                _reactor.birthRate = _reactorDefaultBirthRate
            } else if pad.buttonA.isPressed {
                engineForce = -defaultEngineForce
                _reactor.birthRate = 0
            } else if pad.buttonB.isPressed {
                brakingForce = 100
                _reactor.birthRate = 0
            } else {
                brakingForce = defaultBrakingForce
                _reactor.birthRate = 0
            }
        }
        
        
        
        _vehicleSteering = -CGFloat(orientation)
        if orientation == 0 {
            _vehicleSteering *= CGFloat(0.9)
                
            //_vehicleSteering = [-steeringClamp, steeringClamp]
            if _vehicleSteering < -steeingClamp {
                _vehicleSteering = -steeingClamp
            }
            if _vehicleSteering > steeingClamp {
                _vehicleSteering = steeingClamp
            }
                
            //update the vehicle steering and acceleration
            _vehicle.setSteeringAngle(_vehicleSteering, forWheelAt: 0)
            _vehicle.setSteeringAngle(_vehicleSteering, forWheelAt: 1)
                
            _vehicle.applyEngineForce(engineForce, forWheelAt: 2)
            _vehicle.applyEngineForce(engineForce, forWheelAt: 3)
                
            _vehicle.applyBrakingForce(brakingForce, forWheelAt: 2)
            _vehicle.applyBrakingForce(brakingForce, forWheelAt: 3)
                
            //check if the car is upside down
            self.reorientCarIfNeed()
                
            //make camera follow the car node
            let car = _vehicleNode.presentation
            let carPos = car.position
            var targetPos = vector_float3(carPos.x, 30, carPos.z + 25)
            var cameraPos: vector_float3 = SCNVector3ToFloat3(_cameraNode.position)
            
            //origin ov version is vector_mix
            cameraPos = mix(cameraPos, targetPos, t: vector_float3(Float(cameraDamping), Float(cameraDamping), Float(cameraDamping)))
            _cameraNode.position = SCNVector3FromFloat3(cameraPos)
                
            if scnView.inCarView {
                //move spotlight in front of the camera
                let frontPosition = scnView.pointOfView!.presentation.convertPosition(SCNVector3(0, 0, -30), to: nil)
                _spotLightNode.position = SCNVector3(frontPosition.x, 80, frontPosition.z)
                _spotLightNode.rotation = SCNVector4(1, 0, 0, -Double.pi / 2)
            } else {
                //move spot light on top of the car
                _spotLightNode.position = SCNVector3(carPos.x, 80, carPos.z + 30)
                _spotLightNode.rotation = SCNVector4(1, 0, 0, -Double.pi / 2)
            }
                
            //speed gauge
            let MAX_SPEED: CGFloat = 250
            let overlay = scnView.overlaySKScene as! Overlay
            overlay.speedHandle.zRotation = -(_vehicle.speedInKilometersPerHour * CGFloat.pi / MAX_SPEED)
      
        }
        
    
        
    }
    
    
        

    




    
    @objc func handleDoubleTap(){
        
        //reset
        let scene = setupScene()
        let scnView: GameView = self.view as! GameView
        scnView.scene = scene
        scnView.scene?.physicsWorld.speed = 4.0
        scnView.pointOfView = _cameraNode
        scnView.touchCount = 0
        
    }
    
    

    
    func addTrain(scene: SCNScene, pos: SCNVector3){
        let train = SCNScene(named: "train_flat.dae")
        
        //physicalize the train with simple boxes
        train?.rootNode.enumerateChildNodes({ (node, stop) in
            
            if node.geometry != nil {
                
                ///move every train parts together
                //method2: wrap componets with a root node
                node.position = SCNVector3(node.position.x + pos.x, node.position.y + pos.y, node.position.z + pos.z)
                
                
                var min, max: SCNVector3
                (min, max) = node.boundingBox
                
                let body = SCNPhysicsBody.dynamic()
                let boxShape = SCNBox(width: CGFloat(max.x - min.x), height: CGFloat(max.y - min.y), length: CGFloat(max.z - min.z), chamferRadius: 0)
                body.physicsShape = SCNPhysicsShape(geometry: boxShape, options: [:])
                
                node.pivot = SCNMatrix4MakeTranslation(0, -min.y, 0)
                node.physicsBody = body
                scene.rootNode.addChildNode(node)
            }
        })
        
        //add smoke
        //about why scene instead of train?
        //interestingly, when all nodes of train are added to the scene, they are also removed from train
        //that meas, train has no more node
        //so use "train.rootNode.childNode..." will find nothing, creating error
        let smokeHandle = scene.rootNode.childNode(withName: "Smoke", recursively: true)
        smokeHandle?.addParticleSystem(SCNParticleSystem(named: "smoke", inDirectory: nil)!)
        
        
        //add physics constraints between engine and wagons
        let engine = scene.rootNode.childNode(withName: "EngineCar", recursively: false)
        let wagon1 = scene.rootNode.childNode(withName: "Wagon1", recursively: false)
        let wagon2 = scene.rootNode.childNode(withName: "Wagon2", recursively: false)
        
        var emin, emax: SCNVector3
        (emin, emax) = engine!.boundingBox
        
        var wmin, wmax: SCNVector3
        (wmin, wmax) = wagon1!.boundingBox
        
        var wwmin, wwmax: SCNVector3
        (wwmin, wwmax) = wagon2!.boundingBox

        //boudingBox是在模型空间里
        //因为wagon1 和 wagon2 是一样的模型，所以boundingBox值一样，只取一个就好
        //在joing中bodyB指明了哪个物体的boundingBox
        
        //engin & wagon1
        var joint1 = SCNPhysicsBallSocketJoint(bodyA: engine!.physicsBody!,
                                      anchorA: SCNVector3(emax.x, emin.y, 0),
                                      bodyB: wagon1!.physicsBody!,
                                      anchorB: SCNVector3(wmin.x, wmin.y, 0))
        //wagon1 & wagon2
        var joint2 = SCNPhysicsBallSocketJoint(bodyA: wagon1!.physicsBody!,
                                      anchorA: SCNVector3(wmax.x + 0.1, wmin.y, 0),
                                      bodyB: wagon2!.physicsBody!,
                                      anchorB: SCNVector3(wmin.x - 0.1, wmin.y, 0))
        
        scene.physicsWorld.addBehavior(joint1)
        scene.physicsWorld.addBehavior(joint2)
 
    }
    
    
    func addWoodenBlocks(scene: SCNScene, imageName: String, pos: SCNVector3){
        let block = SCNNode()
        scene.rootNode.addChildNode(block)
        block.position = pos
        block.geometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0)
        block.geometry?.firstMaterial?.diffuse.contents = imageName
        block.geometry?.firstMaterial?.diffuse.mipFilter = .linear
        block.physicsBody = SCNPhysicsBody.dynamic()
    }

    
    
    /*
     * setup funcs
     */
    func setupScene() -> SCNScene {
        let scene = SCNScene()
        
        setupEnvironment(scene: scene)
        setupSceneElements(scene: scene)
        
        _vehicleNode = setupVehicle(scene: scene)
        
        //create a camera
        _cameraNode = SCNNode()
        _cameraNode.camera = SCNCamera()
        _cameraNode.camera?.zFar = 500
        _cameraNode.position = SCNVector3(0, 60, 50)
        _cameraNode.rotation = SCNVector4(1, 0, 0, -Double.pi / 4 * 0.75)
        scene.rootNode.addChildNode(_cameraNode)
        
        //add a secondary camera to the car
        let frontCameraNode = SCNNode()
        frontCameraNode.position = SCNVector3(0, 3.5, 2.5)
        frontCameraNode.rotation = SCNVector4(0, 1, 0, Double.pi)
        frontCameraNode.camera = SCNCamera()
        frontCameraNode.camera?.fieldOfView = 75
        frontCameraNode.camera?.zFar = 500
        _vehicleNode.addChildNode(frontCameraNode)
        
        return scene
        
    }

    
    func setupEnvironment(scene: SCNScene) {
        //add an ambient Light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        //add a key light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .spot
        lightNode.light?.castsShadow = true
        //default shadowSampleCount 1 is not enough, lines happen
        lightNode.light?.shadowSampleCount = 10
        lightNode.light?.color = UIColor(white: 0.8, alpha: 1.0)
        lightNode.position = SCNVector3(0, 80, 30)
        lightNode.rotation = SCNVector4(1, 0, 0, -Double.pi / 2)
        lightNode.light?.spotInnerAngle = 0
        lightNode.light?.spotOuterAngle = 50
        lightNode.light?.zFar = 500
        lightNode.light?.zNear = 50
        scene.rootNode.addChildNode(lightNode)
        
        //late change the light position
        _spotLightNode = lightNode
        
        
        //add floor
        let a = SCNFloor()
        a.reflectionFalloffEnd = 10
        let floor = SCNNode(geometry: a)
        scene.rootNode.addChildNode(floor)
        
        floor.geometry?.firstMaterial?.diffuse.contents = "wood.png"
        floor.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 1)
        floor.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        
        floor.physicsBody = SCNPhysicsBody.static()
 
    }
    

    func setupSceneElements(scene: SCNScene ){
        //add a train
        addTrain(scene: scene, pos: SCNVector3(-5, 20, -40))
        
        //add wooden blocks
        addWoodenBlocks(scene: scene, imageName: "WoodCubeA.jpg", pos: SCNVector3(-10, 15, 10))
        addWoodenBlocks(scene: scene, imageName: "WoodCubeB.jpg", pos: SCNVector3(-9, 10, 10))
        addWoodenBlocks(scene: scene, imageName: "WoodCubeC.jpg", pos: SCNVector3(20, 15, -11))
        addWoodenBlocks(scene: scene, imageName: "WoodCubeA.jpg", pos: SCNVector3(25, 5, -20))
        
        //add wall
        let wall = SCNNode(geometry: SCNBox(width: 400, height: 100, length: 4, chamferRadius: 0))
        wall.geometry?.firstMaterial?.diffuse.contents = "wall.jpg"
        wall.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Mult(SCNMatrix4MakeScale(24, 2, 1), SCNMatrix4MakeTranslation(0, 1, 0))
        wall.geometry?.firstMaterial?.diffuse.wrapS = .repeat
        wall.geometry?.firstMaterial?.diffuse.wrapT = .mirror
        wall.castsShadow = true
        wall.position = SCNVector3(0, 50, -92)
        wall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(wall)

        let wall2 = wall.clone()
        scene.rootNode.addChildNode(wall2)
        wall2.position = SCNVector3(-202, 50, 0)
        wall2.rotation = SCNVector4(0, 1, 0, Double.pi / 2)
        
        let wall3 = wall.clone()
        scene.rootNode.addChildNode(wall3)
        wall3.position = SCNVector3(202, 50, 0)
        wall3.rotation = SCNVector4(0, 1, 0, -Double.pi / 2)
        
        let backWall = SCNNode(geometry: SCNPlane(width: 400, height: 100))
        scene.rootNode.addChildNode(backWall)
        backWall.position = SCNVector3(0, 50, 200)
        backWall.rotation = SCNVector4(0, 1, 0, Double.pi)
        backWall.castsShadow = false
        backWall.physicsBody? = SCNPhysicsBody.static()
        backWall.geometry?.firstMaterial = wall.geometry?.firstMaterial
       
        
        //add ceil
        let ceil = SCNNode(geometry: SCNPlane(width: 400, height: 400))
        scene.rootNode.addChildNode(ceil)
        ceil.position = SCNVector3(0, 100, 0)
        ceil.rotation = SCNVector4(1, 0, 0, Double.pi / 2)
        ceil.geometry?.firstMaterial?.isDoubleSided = false
        ceil.castsShadow = false
        ceil.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        
        
        //add more blocks
        for _ in 0..<4 {
            let r = GKRandomSource.sharedRandom().nextInt()
            self.addWoodenBlocks(scene: scene, imageName: "WoodCubeA.jpg", pos: SCNVector3(r % 60 - 30, 20, r % 40 - 20))
            self.addWoodenBlocks(scene: scene, imageName: "WoodCubeB.jpg", pos: SCNVector3(r % 60 - 30, 20, r % 40 - 20))
            self.addWoodenBlocks(scene: scene, imageName: "WoodCubeC.jpg", pos: SCNVector3(r % 60 - 30, 20, r % 40 - 20))
            
        }
  
        //add cartoom book
        let block =  SCNNode()
        block.position = SCNVector3(20, 10, -16)
        block.rotation = SCNVector4(0, 1, 0, -Double.pi)
        block.geometry = SCNBox(width: 22, height: 0.2, length: 34, chamferRadius: 0)
            
        let frontMat = SCNMaterial()
        frontMat.diffuse.contents = "book_front.jpg"
        frontMat.diffuse.mipFilter = .linear
        frontMat.locksAmbientWithDiffuse = true
            
        let backMat = SCNMaterial()
        backMat.diffuse.contents = "book_back.jpg"
        backMat.diffuse.mipFilter = .linear
        backMat.locksAmbientWithDiffuse = true
        
        block.geometry?.materials = [frontMat, backMat]
        block.physicsBody = SCNPhysicsBody.dynamic()
        scene.rootNode.addChildNode(block)
            
            
        //add carpet
        let rug = SCNNode()
        scene.rootNode.addChildNode(rug)
        rug.position = SCNVector3(0, 0.01, 0)
        rug.rotation = SCNVector4(1, 0, 0, Double.pi / 2)
        let path = UIBezierPath(roundedRect: CGRect(x: -50, y: -30, width: 100, height: 50), cornerRadius: 2.5)
        path.flatness = 0.1
        rug.geometry = SCNShape(path: path, extrusionDepth: 0.05)
        rug.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        rug.geometry?.firstMaterial?.diffuse.contents = "carpet.jpg"
        
        
        //add ball
        let ball = SCNNode()
        ball.position = SCNVector3(-5, 5, -18)
        ball.geometry = SCNSphere(radius: 5)
        ball.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        ball.geometry?.firstMaterial?.diffuse.contents = "ball.jpg"
        ball.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 1, 1)
        ball.geometry?.firstMaterial?.diffuse.wrapS = .mirror
        ball.physicsBody = SCNPhysicsBody.dynamic()
        ball.physicsBody?.restitution = 0.9
        scene.rootNode.addChildNode(ball)
            
            
    }
    
    

    func setupVehicle(scene: SCNScene) -> SCNNode {
        let car = SCNScene(named: "rc_car.scn")
        
        let chassis = car?.rootNode.childNode(withName: "rccarBody", recursively: false)
        
        //setup chassis
        chassis?.position = SCNVector3(0, 10, 30)
        chassis?.rotation = SCNVector4(0, 1, 0, Double.pi)
        
        let body = SCNPhysicsBody.dynamic()
        body.allowsResting = false
        body.mass = 80
        body.restitution = 0.1
        body.friction = 0.5
        body.rollingFriction = 0
        
        chassis?.physicsBody = body
        scene.rootNode.addChildNode(chassis!)
        
        //pipe add reactor
        let pipe = scene.rootNode.childNode(withName: "pipe", recursively: true)
        _reactor = SCNParticleSystem(named: "reactor", inDirectory: nil)
        _reactorDefaultBirthRate = _reactor.birthRate
        _reactor.birthRate = 0
        pipe?.addParticleSystem(_reactor)
        
        //add wheel
        let wheel0Node = scene.rootNode.childNode(withName: "wheelLocator_FL", recursively: true)
        let wheel1Node = scene.rootNode.childNode(withName: "wheelLocator_FR", recursively: true)
        let wheel2Node = scene.rootNode.childNode(withName: "wheelLocator_RL", recursively: true)
        let wheel3Node = scene.rootNode.childNode(withName: "wheelLocator_RR", recursively: true)
        
        
        let wheel0 = SCNPhysicsVehicleWheel(node: wheel0Node!)
        let wheel1 = SCNPhysicsVehicleWheel(node: wheel1Node!)
        let wheel2 = SCNPhysicsVehicleWheel(node: wheel2Node!)
        let wheel3 = SCNPhysicsVehicleWheel(node: wheel3Node!)
        
        
        var min, max: SCNVector3
        (min, max) = wheel0Node!.boundingBox
        let wheelHalfWidth = 0.5 * (max.x - min.x)
        
        //wheel origin can be known by clicking each wheel in the car model
        //coordinate is also know, when facing the car, x axis is to right
        //so for left wheels, we plus
        //for right wheels, we minus
        //connection point is the center of wheel
        wheel0.connectionPosition = SCNVector3FromFloat3(SCNVector3ToFloat3(wheel0Node!.convertPosition(SCNVector3Zero, to: chassis)) + vector_float3(wheelHalfWidth, 0, 0))
        wheel1.connectionPosition = SCNVector3FromFloat3(SCNVector3ToFloat3(wheel1Node!.convertPosition(SCNVector3Zero, to: chassis)) - vector_float3(wheelHalfWidth, 0, 0))
        wheel2.connectionPosition = SCNVector3FromFloat3(SCNVector3ToFloat3(wheel2Node!.convertPosition(SCNVector3Zero, to: chassis)) + vector_float3(wheelHalfWidth, 0, 0))
        wheel3.connectionPosition = SCNVector3FromFloat3(SCNVector3ToFloat3(wheel3Node!.convertPosition(SCNVector3Zero, to: chassis)) - vector_float3(wheelHalfWidth, 0, 0))
        
        let vehicle = SCNPhysicsVehicle(chassisBody: chassis!.physicsBody!, wheels: [wheel0, wheel1, wheel2, wheel3])
        scene.physicsWorld.addBehavior(vehicle)
        
        //this is same object, not duplicate a second object
        _vehicle = vehicle
        
        
        return chassis!
        
        
    }
    
    
    func reorientCarIfNeed(){
        let car = _vehicleNode.presentation
        var carPos = car.position
        
        // make sure the car isn't upside down, and fix it if it is
        var ticks: Int = 0
        var check: Int = 0
        ticks += 1
        if ticks == 30 {
            let t: SCNMatrix4 = car.worldTransform
            
            if t.m22 <= 0.1 {
                check += 1
                if check == 3 {
                    var tr: Int = 0
                    tr += 1
                    if tr == 3 {
                        tr = 0
                        
                        //hard reset
                        _vehicleNode.rotation = SCNVector4(0, 0, 0, 0)
                        _vehicleNode.position = SCNVector3(carPos.x, carPos.y + 10, carPos.z)
                        _vehicleNode.physicsBody?.resetTransform()
                    } else {
                        //try to upturn with random impulse
                        let r = Double(GKRandomSource.sharedRandom().nextInt() / Int(RAND_MAX))
                        let pos = SCNVector3(-10 * r - 0.5, 0.0, -10 * r - 0.5)
                        _vehicleNode.physicsBody?.applyForce(SCNVector3(0, 300, 0), at: pos, asImpulse: true)
                        check = 0
                    }
                } else {
                    check = 0
                }
            } else {
                ticks = 0
            }
        }
        
        
        
        
    }
    

    
    


        
   
   
        
        
        
        
        
        
    
    //不懂
    func setupAccelerometer() {
        _motionManager = CMMotionManager()
        let weakSelf = self
        let controllers = [GCController]()
        if controllers.count == 0 && _motionManager.isAccelerometerAvailable == true {
            _motionManager.accelerometerUpdateInterval = 1 / 60.0
            _motionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                weakSelf.accelerometerDidChange(a: data!.acceleration)
            })
        }
        
    }
    
    
    func accelerometerDidChange(a: CMAcceleration){
        let kFilteringFactor = 0.5
        //Use a basic low-pass filter to only keep the gravity in the accelerometer values
        _accelerometer[0] = a.x * kFilteringFactor + _accelerometer[0] * (1.0 - kFilteringFactor)
        _accelerometer[1] = a.x * kFilteringFactor + _accelerometer[1] * (1.0 - kFilteringFactor)
        _accelerometer[2] = a.x * kFilteringFactor + _accelerometer[2] * (1.0 - kFilteringFactor)
        
        if _accelerometer[0] > 0 {
            _orientation = CGFloat(_accelerometer[1] * 1.3)
        } else {
            _orientation = -CGFloat(_accelerometer[1] * 1.3)
        }
    }
    

    
    
    
 
    
    

    //nothing
    func isHighEndDevice() -> Bool {
        if self._deviceName!.hasPrefix("iPad4") || self._deviceName!.hasPrefix("iPhone6"){
            return true;
        }
        return false
    }
    
    
    
    
    
    //helpers
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
