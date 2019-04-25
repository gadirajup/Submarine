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
    
    var cols = [[Item]]()
    let itemSize: CGFloat = 50
    let itemsPerColumn = 12
    let itemsPerRow = 18
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "night")
        background.zPosition = -2
        addChild(background)
        
        for x in 0 ..< itemsPerRow {
            var col = [Item]()
            for y in 0 ..< itemsPerColumn {
                let item = createItem(row: y, col: x)
                col.append(item)
            }
            cols.append(col)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
    }
    
    func position(for item: Item) -> CGPoint {
        let xOffset: CGFloat = -430
        let yOffset: CGFloat = -300
        
        let x = xOffset + itemSize * CGFloat(item.col)
        let y = yOffset + itemSize * CGFloat(item.row)
        
        return CGPoint(x: x, y: y)
    }
    
    func createItem(row: Int, col: Int, startOffScreen: Bool = false) -> Item {
        
        let itemImages = ["alien-blue", "alien-green", "alien-gray", "alien-pink", "alien-purple", "alien-yellow"]
        
        let itemImage = itemImages.randomElement()!
        let item = Item(imageNamed: itemImage)
        item.name = itemImage
        item.row = row
        item.col = col
        item.position = position(for: item)
        addChild(item)
        return item
    }
    
    func item(at point: CGPoint) -> Item {
        let items = nodes(at: point).compactMap
    }
}

