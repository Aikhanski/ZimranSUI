//
//  FileStorageTests.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Testing
import Foundation
@testable import ZimranSUI

@Suite(.serialized)
struct FileStorageTests {
    
    // MARK: - Тестовые модели
    
    private struct TestModel: Codable, Equatable {
        let id: Int
        let name: String
        let value: Double
    }
    
    private struct TestArray: Codable, Equatable {
        let items: [String]
    }
    
    // MARK: - Тесты бизнес-логики
    
    @Test("Сохранение и загрузка простой модели")
    func testSaveAndLoadSimpleModel() {
        let testModel = TestModel(id: 1, name: "Test", value: 3.14)
        let uniquePath = "test_model_\(UUID().uuidString)"
        var storage = FileStorage<TestModel>(directory: .caches, path: uniquePath)

        storage.wrappedValue = testModel

        let newStorage = FileStorage<TestModel>(directory: .caches, path: uniquePath)

        #expect(newStorage.wrappedValue != nil)
        #expect(newStorage.wrappedValue?.id == 1)
        #expect(newStorage.wrappedValue?.name == "Test")
        #expect(newStorage.wrappedValue?.value == 3.14)
    }
    
    @Test("Сохранение и загрузка массива")
    func testSaveAndLoadArray() async throws {
        let testArray = TestArray(items: ["item1", "item2", "item3"])
        var storage = FileStorage<TestArray>(directory: .caches, path: "test_array")
        
        storage.wrappedValue = testArray

        let newStorage = FileStorage<TestArray>(directory: .caches, path: "test_array")
        
        #expect(newStorage.wrappedValue != nil)
        #expect(newStorage.wrappedValue?.items.count == 3)
        #expect(newStorage.wrappedValue?.items[0] == "item1")
        #expect(newStorage.wrappedValue?.items[1] == "item2")
        #expect(newStorage.wrappedValue?.items[2] == "item3")
    }
    
    @Test("Обновление значения перезаписывает старое")
    func testUpdateValueOverwritesOld() async throws {
        let initialModel = TestModel(id: 1, name: "Initial", value: 1.0)
        let updatedModel = TestModel(id: 2, name: "Updated", value: 2.0)
        var storage = FileStorage<TestModel>(directory: .caches, path: "test_update")
        
        storage.wrappedValue = initialModel
        storage.wrappedValue = updatedModel

        let newStorage = FileStorage<TestModel>(directory: .caches, path: "test_update")
        
        #expect(newStorage.wrappedValue != nil)
        #expect(newStorage.wrappedValue?.id == 2)
        #expect(newStorage.wrappedValue?.name == "Updated")
        #expect(newStorage.wrappedValue?.value == 2.0)
    }
    
    @Test("Установка nil удаляет сохраненное значение")
    func testSetNilRemovesSavedValue() async throws {
        let testModel = TestModel(id: 1, name: "Test", value: 3.14)
        var storage = FileStorage<TestModel>(directory: .caches, path: "test_nil")
        
        storage.wrappedValue = testModel
        storage.wrappedValue = nil

        let newStorage = FileStorage<TestModel>(directory: .caches, path: "test_nil")
        
        #expect(newStorage.wrappedValue == nil)
    }
    
    @Test("Сохранение одинакового значения не вызывает обновление")
    func testSaveSameValueDoesNotTriggerUpdate() async throws {
        let testModel = TestModel(id: 1, name: "Test", value: 3.14)
        var storage = FileStorage<TestModel>(directory: .caches, path: "test_same")
        
        storage.wrappedValue = testModel
        let firstValue = storage.wrappedValue
        
        storage.wrappedValue = testModel
        let secondValue = storage.wrappedValue
        
        #expect(firstValue == secondValue)
        #expect(firstValue?.id == 1)
        #expect(firstValue?.name == "Test")
    }
    
    @Test("Работа с разными директориями")
    func testWorkWithDifferentDirectories() async throws {
        let testModel = TestModel(id: 1, name: "Test", value: 3.14)
        var documentsStorage = FileStorage<TestModel>(directory: .documents, path: "test_documents")
        var cachesStorage = FileStorage<TestModel>(directory: .caches, path: "test_caches")
        
        documentsStorage.wrappedValue = testModel
        cachesStorage.wrappedValue = testModel

        let newDocumentsStorage = FileStorage<TestModel>(directory: .documents, path: "test_documents")
        let newCachesStorage = FileStorage<TestModel>(directory: .caches, path: "test_caches")
        
        #expect(newDocumentsStorage.wrappedValue != nil)
        #expect(newCachesStorage.wrappedValue != nil)
        #expect(newDocumentsStorage.wrappedValue?.id == 1)
        #expect(newCachesStorage.wrappedValue?.id == 1)
    }
    
    @Test("Сохранение и загрузка сложной структуры")
    func testSaveAndLoadComplexStructure() {
        let complexModel = TestModel(id: 999, name: "Complex Test", value: 3.14159265359)
        let uniquePath = "complex_test_\(UUID().uuidString)"
        var storage = FileStorage<TestModel>(directory: .caches, path: uniquePath)

        storage.wrappedValue = complexModel

        let newStorage = FileStorage<TestModel>(directory: .caches, path: uniquePath)

        #expect(newStorage.wrappedValue != nil)
        #expect(newStorage.wrappedValue?.id == 999)
        #expect(newStorage.wrappedValue?.name == "Complex Test")
        #expect(newStorage.wrappedValue?.value == 3.14159265359)
    }
    
    @Test("Работа с пустыми значениями")
    func testWorkWithEmptyValues() async throws {
        let emptyModel = TestModel(id: 0, name: "", value: 0.0)
        var storage = FileStorage<TestModel>(directory: .caches, path: "empty_test")
        
        storage.wrappedValue = emptyModel

        let newStorage = FileStorage<TestModel>(directory: .caches, path: "empty_test")
        
        #expect(newStorage.wrappedValue != nil)
        #expect(newStorage.wrappedValue?.id == 0)
        #expect(newStorage.wrappedValue?.name == "")
        #expect(newStorage.wrappedValue?.value == 0.0)
    }
    
    @Test("Сохранение и загрузка с разными путями")
    func testSaveAndLoadWithDifferentPaths() async throws {
        let model1 = TestModel(id: 1, name: "Model1", value: 1.0)
        let model2 = TestModel(id: 2, name: "Model2", value: 2.0)
        var storage1 = FileStorage<TestModel>(directory: .caches, path: "path1")
        var storage2 = FileStorage<TestModel>(directory: .caches, path: "path2")
        
        storage1.wrappedValue = model1
        storage2.wrappedValue = model2

        let newStorage1 = FileStorage<TestModel>(directory: .caches, path: "path1")
        let newStorage2 = FileStorage<TestModel>(directory: .caches, path: "path2")
        
        #expect(newStorage1.wrappedValue != nil)
        #expect(newStorage2.wrappedValue != nil)
        #expect(newStorage1.wrappedValue?.id == 1)
        #expect(newStorage2.wrappedValue?.id == 2)
        #expect(newStorage1.wrappedValue?.name == "Model1")
        #expect(newStorage2.wrappedValue?.name == "Model2")
    }
}
