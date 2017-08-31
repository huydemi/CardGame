/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

enum CardLevel :CGFloat {
  case board = 10
  case moving = 100
  case enlarged = 200
}

class GameScene: SKScene {
  
  override func didMove(to view: SKView) {
    let bg = SKSpriteNode(imageNamed: "bg_blank")
    bg.anchorPoint = CGPoint.zero
    bg.position = CGPoint.zero
    addChild(bg)
    
    let wolf = Card(cardType: .wolf)
    wolf.position = CGPoint(x: 100, y: 200)
    addChild(wolf)
    
    let bear = Card(cardType: .bear)
    bear.position = CGPoint(x: 300, y: 200)
    addChild(bear)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      // The location(in:) method converts the touch location into the scene coordinates.
      let location = touch.location(in: self)
      // Use atPoint(_:) to determine which node was touched. This method will always return a value, even if you didn’t touch any of the cards. In that case, you get some other SKNode class. The as? Card keyword then either returns a Card object, or nil if that node isn’t a Card. The if let then guarantees that card contains an actual Card, and not anything else. Without this step, you might accidentally move the background node, which is amusing, but not what you want.
      if let card = atPoint(location) as? Card {
        if card.enlarged { return }
        card.position = location
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      if let card = atPoint(location) as? Card {
        if touch.tapCount > 1 {
          card.enlarge()
          return
        }
        
        if card.enlarged { return }
        
        let wiggleIn = SKAction.scaleX(to: 1.0, duration: 0.2)
        let wiggleOut = SKAction.scaleX(to: 1.2, duration: 0.2)
        let wiggle = SKAction.sequence([wiggleIn, wiggleOut])
        
        card.run(SKAction.repeatForever(wiggle), withKey: "wiggle")
        
        card.zPosition = CardLevel.moving.rawValue
        
        card.removeAction(forKey: "drop")
        card.run(SKAction.scale(to: 1.3, duration: 0.25), withKey: "pickup")
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      if let card = atPoint(location) as? Card {
        if card.enlarged { return }
        
        card.zPosition = CardLevel.board.rawValue
        card.removeFromParent()
        addChild(card)
        
        card.removeAction(forKey: "wiggle")
        
        card.removeAction(forKey: "pickup")
        card.run(SKAction.scale(to: 1.0, duration: 0.25), withKey: "drop")
      }
    }
  }
  
}
