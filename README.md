# SceneKitVehicle-Oc-to-Swift

# Important
This is an Apple official example.
I just change it from objective-c version to swift,
and added a very little in it: 
a button introducing how to interacte

# Undone works
I left 2 parts untangled:
1) how to control car direction
2) keep car not upside

3) I want to add a control pad like in "Terminator", cos 2 fingers are not always recognized



# What the example brings you
1) car-->
Scenekit is very strong!
a) assemble a car 
b) forward
c) backward
d) brake

2) ballSocket joint-->
to keep every wagon of a train connected all the time 

3) static & dynamic-->
here are some details:
let floor = SCNNode(geometry: SCNFloor())
scene.rootNode.addChildNode(floor)

floor.physicsBody = SCNPhysicsBody.static()

//floor.physicsBody.type = .static() //only this has no effect

//floor.physicsBody? = SCNPhysicsBody.static() //sometimes weird things happen, you may check whether you add "?" It cost me serveral hours.

