//
//  XCTestCase+Snapshot.swift
//  SnappyV2SnapshotTests
//
//  Created by Henrik Gustavii on 02/12/2021.
//

import XCTest

// Lifted from previous projects
extension XCTestCase {
    
    func assert<T>(snapshot: Snapshot, sut: T, file: StaticString = #filePath, line: UInt = #line, function: String = #function) {
        privateAssert(snapshot: snapshot, name: stringNameFor(sut), file: file, line: line, function: function)
    }
    
    func assert(snapshot: Snapshot, name: String, file: StaticString = #filePath, line: UInt = #line, function: String = #function) {
        privateAssert(snapshot: snapshot, name: name, file: file, line: line, function: function)
    }
    
    func record<T>(snapshot: Snapshot, sut: T, file: StaticString = #filePath, line: UInt = #line, function: String = #function) {
        privateRecord(snapshot: snapshot, name: stringNameFor(sut), file: file, line: line, function: function)
    }
    
    func record(snapshot: Snapshot, name: String, file: StaticString = #filePath, line: UInt = #line, function: String = #function) {
        privateRecord(snapshot: snapshot, name: name, file: file, line: line, function: function)
    }
    
    private func privateAssert(snapshot: Snapshot, name: String, file: StaticString, line: UInt, function: String) {
        let snapshotURL = makeSnapshotURL(name: name,
                                          file: file,
                                          testFunction: function,
                                          snapshotName: snapshot.name)
        let snapshotData = makeSnapshotData(snapshotImage: snapshot.image, file: file, line: line)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }

        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)

            try? snapshotData?.write(to: temporarySnapshotURL)

            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    private func privateRecord(snapshot: Snapshot, name: String, file: StaticString, line: UInt, function: String) {
        let snapshotURL = makeSnapshotURL(name: name, file: file, testFunction: function, snapshotName: snapshot.name)
        let snapshotData = makeSnapshotData(snapshotImage: snapshot.image, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    // Helpers
    private func makeSnapshotURL(name: String, file: StaticString, testFunction: String, snapshotName: String) -> URL {
        
        let folderName = String(describing: file)
        let functionNameFormatted = testFunction.replacingOccurrences(of: "test", with: "", options: .caseInsensitive)
        
        return URL(fileURLWithPath: folderName)
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
            .appendingPathComponent("\(name)\(functionNameFormatted)_\(snapshotName).png")
    }
    
    private func makeSnapshotData(snapshotImage snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
    
    private func stringNameFor<T>(_ type: T) -> String {
        String(describing: Mirror(reflecting: type).subjectType)
    }
}
