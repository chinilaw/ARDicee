//
//  ViewController.swift
//  ARDicee
//
//  Created by Jules Lee on 18/07/2019.
//  Copyright © 2019 Jules Lee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Plane detection for debug use
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        creates a cube that is color red
//        dimensions in centimeters
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        cube.materials = [material]
        
//        let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/venus.jpg")
//        sphere.materials = [material]
//
//
//
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
        
        // adds light to make it more 3Dish
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // 2D coordinate
            let touchLocation = touch.location(in: sceneView)
            // test:: touch on the plane
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            //  Set the scene to the view
            let pos = location.worldTransform.columns.3
            // from half of the plane, the dice sits on top of the plane
            diceNode.position = SCNVector3(pos.x , pos.y + diceNode.boundingSphere.radius, pos.z)
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            let randomX = (Float(Int.random(in: 0..<4)) * Float.pi / 2)
            let randomZ = (Float(Int.random(in: 0..<4)) * Float.pi / 2)
            
            diceNode.runAction(
                SCNAction.rotateBy(
                    x: CGFloat(randomX*5),
                    y: 0,
                    z: CGFloat(randomZ*5),
                    duration: 0.5)
            )
            
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = (Float(Int.random(in: 0..<4)) * Float.pi / 2)
        let randomZ = (Float(Int.random(in: 0..<4)) * Float.pi / 2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX*5),
                y: 0,
                z: CGFloat(randomZ*5),
                duration: 0.5)
        )
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    //MARK: - ARSCNViewDelegateMethods
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createPlane(with: planeAnchor)
        node.addChildNode(planeNode)
    }

    //MARK: - Plane Rendering Methods
    func createPlane(with planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
    }
}
