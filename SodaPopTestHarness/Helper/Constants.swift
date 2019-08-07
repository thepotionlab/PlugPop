//
//  TestConstants.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import SodaFountain
import SodaPop

// MARK: Directories

public let testTrashDirectoryPath = NSSearchPathForDirectoriesInDomains(.trashDirectory, .userDomainMask, true)[0]
public let testTrashDirectoryURL = URL(fileURLWithPath: testTrashDirectoryPath)
public let testPluginsDirectoryPathComponent = "PlugIns"

// MARK: Extensions

public let testPluginSuffix = "html"
public let testPluginSuffixes: [String] = [testPluginSuffix]
public let testPluginSuffixesTwo: [String] = ["html", "md", "js"]
public let testPluginSuffixesEmpty = [String]()

// MARK: `SodaFountain`

// `IRB` is significantly smaller than `HTML`, some of tests copy the plugin,
// so smaller is better.
public let testPluginFileExtension = "replaplugin"
public let testPluginName = TestPlugins.testPluginName
public let testPluginNameTwo = TestPlugins.testPluginNameTwo
public let testPluginExtension = TestPlugins.testPluginFileExtension
public let testPluginCommand = TestPlugins.testPluginCommand
public let testPluginCommandTwo = TestPlugins.testPluginCommandTwo
public let testPluginNameDefault = TestPlugins.testPluginNameCat
public let testPluginNameNotDefault = TestPlugins.testPluginNamePrint
public let testPluginCommandNotDefault = TestPlugins.testPluginCommandPrint
public let testPluginDirectoryName = testPluginName.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNameTwo = testPluginNameTwo.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNoPluginName = "No Plugin".appendingPathExtension(testPluginFileExtension)!
public let testPluginNameNonexistent = TestPlugins.testPluginNameNonexistent
public let testPluginNameHelloWorld = TestPlugins.testPluginNameHelloWorld
public let testPluginNameCat = TestPlugins.testPluginNameCat
public let testPluginNameLog = TestPlugins.testPluginNameTestLog
public let testPluginNamePrint = TestPlugins.testPluginNamePrint
public let testPluginNamePromptInterrupt = TestPlugins.testPluginNameTestPromptInterrupt
public let testPluginOptionsDisabledName = TestPlugins.testPluginOptionsDisabledName
public let testPluginOptionsEnabledName = TestPlugins.testPluginOptionsEnabledName
public let testPluginOptionsNilName = TestPlugins.testPluginOptionsNilName

// MARK: Directories & Files

public let testApplicationSupportDirectoryName = "Application Support"
public let testAppName = "SodaPop"
public let testCopyTempDirectoryName = "Duplicate Plugin Tests"