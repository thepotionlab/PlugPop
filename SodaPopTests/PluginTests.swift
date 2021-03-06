//
//  FileSystemTests.swift
//  FileSystemTests
//
//  Created by Roben Kleene on 9/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

@testable import SodaPop
import SodaPopTestHarness
import XCTest

class PluginTests: PluginTestCase {
    func testPlugin() {
        var isDir: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: plugin.resourcePath, isDirectory: &isDir)
        XCTAssertTrue(fileExists)
        XCTAssertTrue(isDir.boolValue)
        XCTAssertEqual(plugin.resourcePath, plugin.resourceURL.path)
    }
}

extension PluginInfoContentsType {
    static func contentsOfPluginInfoWithConfirmation(for plugin: Plugin) -> String {
        let pluginInfoPath: String
        if type(of: plugin) == XMLPlugin.self {
            pluginInfoPath = XMLPlugin.urlForInfoDictionary(for: plugin).path
        } else if let plugin = plugin as? JSONPlugin {
            pluginInfoPath = plugin.infoPath
        } else {
            XCTFail()
            pluginInfoPath = ""
        }

        var infoDictionaryContents: String!
        do {
            infoDictionaryContents = try String(contentsOfFile: pluginInfoPath,
                                                encoding: String.Encoding.utf8)
        } catch {
            XCTAssertTrue(false, "Getting the info dictionary contents should succeed")
        }

        return infoDictionaryContents
    }
}

protocol PluginInfoContentsType {
    static func contentsOfPluginInfoWithConfirmation(for plugin: Plugin) -> String
}

class MakeTemporaryPluginsManagerTests: TemporaryPluginsManagerDependenciesTestCase, PluginInfoContentsType {
    func testEditPluginProperties() {
        let states = [true, false]
        for state in states {
            Plugin.forceXML = state
            let pluginsManager = makePluginsManager()
            guard let plugin = pluginsManager.plugin(withName: testPluginName) else {
                XCTFail()
                return
            }
            XCTAssertEqual(type(of: plugin) == XMLPlugin.self, state)
            XCTAssertTrue(isTemporaryItem(at: plugin.resourceURL))
            plugin.editable = true

            let contents = type(of: self).contentsOfPluginInfoWithConfirmation(for: plugin)

            plugin.name = testPluginNameTwo
            let contentsTwo = type(of: self).contentsOfPluginInfoWithConfirmation(for: plugin)
            XCTAssertNotEqual(contents, contentsTwo, "The contents should not be equal")

            plugin.command = testPluginCommandTwo
            let contentsThree = type(of: self).contentsOfPluginInfoWithConfirmation(for: plugin)
            XCTAssertNotEqual(contentsTwo, contentsThree, "The contents should not be equal")

            let uuid = UUID()
            let uuidString = uuid.uuidString
            plugin.identifier = uuidString
            let contentsFour = type(of: self).contentsOfPluginInfoWithConfirmation(for: plugin)
            XCTAssertNotEqual(contentsThree, contentsFour, "The contents should not be equal")

            plugin.suffixes = testPluginSuffixesTwo
            let contentsFive = type(of: self).contentsOfPluginInfoWithConfirmation(for: plugin)
            XCTAssertNotEqual(contentsFour, contentsFive, "The contents should not be equal")
            let newPlugin: Plugin! = Plugin.makePlugin(url: tempPluginURL)

            XCTAssertEqual(plugin.name, newPlugin.name, "The names should be equal")
            XCTAssertEqual(plugin.command!, newPlugin.command!, "The commands should be equal")
            XCTAssertEqual(plugin.identifier, newPlugin.identifier, "The identifiers should be equal")
            XCTAssertEqual(plugin.suffixes, newPlugin.suffixes, "The file extensions should be equal")

            // Making a `pluginsManager` will implicitly create the
            // `userPluginsURL`. So that needs to be cleaned up here.
            do {
                try removeTemporaryItem(at: temporaryApplicationSupportDirectoryURL)
            } catch {
                XCTFail()
            }
        }

        // Clean Up
        Plugin.forceXML = defaultForceXML
    }
}

class TemporaryPluginTests: TemporaryPluginTestCase, PluginInfoContentsType {
    func testEquality() {
        let pluginMaker = pluginsManager.pluginsDataController.pluginMaker
        let samePlugin = pluginMaker.makePlugin(url: tempPluginURL)!
        XCTAssertNotEqual(plugin, samePlugin, "The plugins should not be equal")
        XCTAssertTrue(plugin.isEqual(toOther: samePlugin), "The plugins should be equal")

        // Duplicate the plugins folder, this should not cause a second plugin
        // to be added to the plugin manager since the copy originated from the
        // same process
        let destinationPluginFilename = DuplicatePluginController.pluginFilename(fromName: plugin.identifier)
        let destinationPluginURL: URL! = tempPluginURL.deletingLastPathComponent()
            .appendingPathComponent(destinationPluginFilename)
        do {
            try FileManager.default.copyItem(at: tempPluginURL as URL, to: destinationPluginURL)
        } catch {
            XCTAssertTrue(false, "The copy should succeed")
        }

        let newPlugin = pluginMaker.makePlugin(url: destinationPluginURL)
        XCTAssertNotEqual(plugin, newPlugin, "The plugins should not be equal")
        // This fails because the bundle URL and commandPath are different
        XCTAssertFalse(plugin.isEqual(to: newPlugin), "The plugins should be equal")

        // TODO: It would be nice to test modifying properties, but there isn't
        // a way to do that because with two separate plugin directories the
        // command paths and info dictionary URLs will be different
    }
}

class DuplicatePluginNameValidationTests: PluginTestCase {
    var mockPluginsManager: MockPluginsManager {
        guard let mockPluginsManager = pluginsManager as? MockPluginsManager else {
            XCTFail()
            abort()
        }
        return mockPluginsManager
    }

    class NameBlocker: NSObject {
        let name: String
        init(name: String) {
            self.name = name
        }
    }

    override func setUp() {
        pluginsManagerType = MockPluginsManager.self
        super.setUp()
    }

    func testPluginNames() {
        // Setup
        let fromName = testPluginNameNonexistent
        let blockingPlugin = pluginsManager.plugin(withName: testPluginNameTwo)!
        XCTAssertNotEqual(fromName, plugin.name)
        XCTAssertNotEqual(plugin, blockingPlugin)

        for index in 0 ... 105 {
            // Calculate the current suffixed name
            let suffix = index + 1
            let suffixedName = "\(fromName) \(suffix)"
            var testName: String!
            switch index {
            case 0:
                testName = fromName
            case let x where x > 98:
                testName = plugin.identifier
            default:
                testName = suffixedName
            }

            let name = pluginsManager.pluginsController.uniquePluginName(fromName: fromName,
                                                                         for: plugin)
            XCTAssertEqual(name, testName)

            // Block more names for the next iteration
            if index == 0 {
                mockPluginsManager.mockPluginsController.override(name: fromName, with: blockingPlugin)
            } else {
                mockPluginsManager.mockPluginsController.override(name: suffixedName, with: blockingPlugin)
            }
        }
    }
}

// TODO: Test trying to run a plugin that has been unloaded? After deleting it's resources
// TODO: Add tests for invalid plugin info dictionaries, e.g., file extensions and commands can be nil
