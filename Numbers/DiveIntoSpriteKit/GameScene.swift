//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene {
    
    var level: Int = 1
    var scorelabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    var score = 0 {
        didSet {
            scorelabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background-pattern")
        background.name = "background"
        background.zPosition = -1
        addChild(background)
        
        let music = SKAudioNode(fileNamed: "truth-in-the-stones")
        background.addChild(music)
        
        scorelabel.position = CGPoint(x: -480, y: 330)
        scorelabel.horizontalAlignmentMode = .left
        scorelabel.zPosition = 1
        background.addChild(scorelabel)
        
        score = 0
        
        createGrid()
        createLevel()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        guard let tapped = tappedNodes.first else { return }
        if tapped.name == "correct" {
            correctAnswer(tapped)
        } else if tapped.name == "wrong" {
            wrongAnswer(tapped)
        }
    }
    
    func wrongAnswer(_ node: SKNode) {
        run(SKAction.playSoundFileNamed("wrong-1", waitForCompletion: false))
        score -= 1
        
        let wrong = SKSpriteNode(imageNamed: "wrong")
        wrong.position = node.position
        wrong.zPosition = 1
        addChild(wrong)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            wrong.removeFromParent()
            self.level -= 1
            
            if self.level == 0 {
                self.level = 1
            }
            
            self.createLevel()
        }
    }
    
    func correctAnswer(_ node: SKNode) {
        run(SKAction.playSoundFileNamed("correct-1", waitForCompletion: false))
        score += 1
        
        let sparks = SKEmitterNode(fileNamed: "Spark.sks")!
        sparks.position = node.position
        sparks.zPosition = 1
        addChild(sparks)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sparks.removeFromParent()
            self.level += 1
            self.createLevel()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
    }
    
    func createGrid() {
        let xOffset = -440
        let yOffset = -320
        
        for row in 0..<8 {
            for col in 0 ..< 12 {
                let item = SKSpriteNode(imageNamed: "1")
                item.position = CGPoint(x: xOffset + (col*80), y: yOffset + (row*80))
                addChild(item)
            }
        }
    }
    
    func createLevel() {
        var itemsToShow = 4 + (level * 4)
        let items = children.filter { $0.name != "background" }
        
        let shuffled = items.shuffled() as! [SKSpriteNode]
        for item in shuffled {
            item.alpha = 0
        }
        
        let highest = Int.random(in: 5...15)
        var others = [Int]()
        
        for _ in 1 ..< itemsToShow {
            let num = Int.random(in: 0 ..< highest)
            others.append(num)
        }
        
        for (index, number) in others.enumerated() {
            let item = shuffled[index]
            item.texture = SKTexture(imageNamed: String(number))
            item.alpha = 1
            item.name = "wrong"
        }
        
        shuffled.last?.texture = SKTexture(imageNamed: String(highest))
        shuffled.last?.alpha = 1
        shuffled.last?.name = "correct"
    }
}

