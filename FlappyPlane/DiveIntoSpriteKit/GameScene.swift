//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "plane")
    let scoreLabel = SKLabelNode(fontNamed: "Baskerville-Bold")
    let music = SKAudioNode(fileNamed: "salty-ditty.mp3")
    
    var score: Int! {
        didSet {
            scoreLabel.text = "Score: \(score ?? 0)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        addChild(music)
        
        player.position = CGPoint(x: -400, y: 250)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.collisionBitMask = 0
        addChild(player)
        
        if let smoke = SKEmitterNode(fileNamed: "MyParticle.sks") {
            smoke.position = CGPoint(x: -20, y: -20)
            smoke.zPosition = -1
            player.addChild(smoke)
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: -500, y: 320)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontColor = .darkGray
        addChild(scoreLabel)
        
        score = 0
        
        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -340, z: -1, duration: 6, needsPhysics: true)

        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { (_) in
            self.createObstacle()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        
        if player.parent != nil {
            score += 1
        }
        
        if player.position.y > 300 {
            player.position.y = 300
        }
        
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        player.run(rotate)
    }
    
    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needsPhysics: Bool) {
        for i in 0 ... 1 {
            let node = SKSpriteNode(imageNamed: image)
            node.position = CGPoint(x: 1023 * CGFloat(i), y: y)
            node.zPosition = z
            addChild(node)
            
            if needsPhysics {
                node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
                node.physicsBody?.isDynamic = false
                node.physicsBody?.contactTestBitMask = 1
                node.name = "obstacle"
            }
            
            let move = SKAction.moveBy(x: -1024, y: 0, duration: duration)
            let wrap = SKAction.moveBy(x: 1024, y: 0, duration: 0)
            
            let sequence = SKAction.sequence([move, wrap])
            let forever = SKAction.repeatForever(sequence)
            
            node.run(forever)
        }
    }
    
    func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "enemy-bird")
        obstacle.position = CGPoint(x: 768, y: Int.random(in: -300 ..< 350))
        obstacle.zPosition = -2
        addChild(obstacle)
        
        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.name = "obstacle"
        
        let action = SKAction.moveTo(x: -768, duration: 6)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([action, remove])
        obstacle.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerHit(nodeB)
        } else  if nodeB == player {
            playerHit(nodeA)
        }
    }
    
    func playerHit(_ node: SKNode) {
        if node.name == "obstacle" {
            player.removeFromParent()
            
            run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
            music.removeFromParent()
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion.sks") {
                explosion.position = player.position
                addChild(explosion)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if let scene = GameScene(fileNamed: "GameScene") {
                        scene.scaleMode = .aspectFill
                        self.view?.presentScene(scene)
                    }
                }
            }
            
            
        }
    }
}

