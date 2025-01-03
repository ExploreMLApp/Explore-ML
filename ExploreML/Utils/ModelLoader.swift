//
//  ModelLoader.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 5/5/23.
//

import CoreML
import Foundation
import SwiftUI
import Models

enum ModelError: Error {
    case modelNotFound(String)
    case invalidModelURL
    case loadError(Error)
}

class ModelLoader {
    // Singleton instance for shared access
    static let shared = ModelLoader()
    
    // Cache to store loaded models
    private var modelCache: [String: LanguageModel] = [:]
    
    private init() {}
    
    /// Loads a CoreML model from the app bundle
    /// - Parameter url: The url of the model
    /// - Returns: The loaded MLModel
    /// - Throws: ModelError if loading fails
    func loadModel(url: URL?) async throws -> LanguageModel {
        // Check cache first
        if let fileName = url?.lastPathComponent, let cachedModel = modelCache[fileName] {
            return cachedModel
        }
        
        if let url = url, url.startAccessingSecurityScopedResource() {
            defer {
                url.stopAccessingSecurityScopedResource()
            }
        
            let model: LanguageModel?
            
            do {
                if url.pathExtension == "mlmodelc" {
                    model = try LanguageModel.loadCompiled(url: url)
                } else {
                    // Compile model URL
                    guard let compiledModelURL = try? await MLModel.compileModel(at: url) else {
                        throw ModelError.invalidModelURL
                    }
                    let precompiled = try MLModel(contentsOf: compiledModelURL)
                    model = LanguageModel(model: precompiled)
                }
            
                // Cache the loaded model
                modelCache[url.lastPathComponent] = model
                
                return model!
            } catch {
                throw ModelError.loadError(error)
            }
        } else {
            throw ModelError.invalidModelURL
        }
    }
    
    /// Removes a model from the cache
    /// - Parameter name: Name of the model to remove
    func clearModelFromCache(named name: String) {
        modelCache.removeValue(forKey: name)
    }
    
    /// Clears all models from the cache
    func clearAllModelsFromCache() {
        modelCache.removeAll()
    }
}

import Combine

// extension LanguageModel: ObservableObject {}
