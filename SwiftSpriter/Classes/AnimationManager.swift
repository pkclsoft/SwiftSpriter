//
//  AnimationManager.swift
//  SwiftSpriter
//
//  Created by Matt on 8/27/16.
//  Copyright © 2016 BiminiRoad. All rights reserved.
//

import Foundation
import SpriteKit

public protocol TextureLoader {
    func textureNamed(_ textureName: String, path: String?) -> SKTexture?
}

public class AnimationManager {
    public let animationData: ModelData
    var animationNodes = [AnimationNode]()
    var lastSystemTime: TimeInterval
    var textureCache: NSCache<NSString, SKTexture>
    let textureLoader: TextureLoader?
    
    public init(animationData: ModelData, textureLoader: TextureLoader?) {
        self.animationData = animationData
        self.textureLoader = textureLoader
        
        self.textureCache = NSCache()
        self.lastSystemTime = 0
    }
    
    public func update(_ currentTime: TimeInterval) {
        var deltaTime: TimeInterval = 0
        if self.lastSystemTime > 0{
            deltaTime = currentTime - self.lastSystemTime
        }
        self.lastSystemTime = currentTime
        
        for node in self.animationNodes {
            node.updateTime(deltaTime: deltaTime)
        }
    }
    
    public func allEntityNames() -> [String] {
        return Array(self.animationData.entitiesByName.keys)
    }
    
    public func allAnimationNamesForEntity(_ entityName: String) -> [String] {
        guard let entity = self.animationData.entitiesByName[entityName] else {
            return []
        }
        return Array(entity.animationsByName.keys)
    }
    
    public func allTextureNames() -> [String: [String]] {
        var paths = [String: [String]]()
        for texture in animationData.texturesByID.values {
            if let relativePath = texture.relativePath {
                var fileNames = paths[relativePath]
                if fileNames == nil {
                    fileNames = []
                    paths[relativePath] = fileNames
                }
                if let fileName = texture.fileName {
                    fileNames!.append(fileName)
                }
            }
        }
        return paths
    }
    
    func entityNamed(_ entityName: String) -> ModelEntity? {
        return self.animationData.entitiesByName[entityName]
    }
    
    func addAnimationNode(_ animationNode: AnimationNode) {
        self.animationNodes.append(animationNode)
    }
    
    func removeAnimationNode(_ animationNode: AnimationNode) {
        if let idx = self.animationNodes.index(of: animationNode) {
            self.animationNodes.remove(at: idx)
        }
    }
    
    func textureNamed(_ textureName: String, path: String?) -> SKTexture? {
        let key: NSString
        if let path = path {
            key = NSString(string: path.appending(textureName))
        } else {
            key = NSString(string: textureName)
        }
        let texture = self.textureCache.object(forKey: key)
        if texture != nil {
           return texture
        }
        
        if let texture = self.textureLoader?.textureNamed(textureName, path: path) {
            self.textureCache.setObject(texture, forKey: key)
            return texture
        }
        
        return nil
    }
}
