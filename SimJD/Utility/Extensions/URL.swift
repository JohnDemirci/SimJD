//
//  URL.swift
//  SimJD
//
//  Created by John Demirci on 5/19/25.
//

import Foundation

fileprivate extension URL {
    static let defaultDerivedDataURL: URL = .homeDirectory
        .appendingPathComponent("Library")
        .appendingPathComponent("Developer")
        .appendingPathComponent("Xcode")
        .appendingPathComponent("DerivedData")
}

extension URL {
    static var derivedDataURL: URL {
            guard let url = UserDefaults.standard.url(forKey: Setting.derivedDataPath.key) else {
            return .defaultDerivedDataURL
        }
        return url
    }
}

extension URL {
    enum File {
        case generalDerivedData
        case applicationSpecificDerivedData(InstalledAppDetail)
        case infoPlist(String /* Path to the Application's derived data folder */)
        case workspacePath(URL /* url of the plist */ )
        case applicationBinary(
            String, /* Path to the Application's derived data folder */
            String /* Display Name of the Application Binary */
        )
    }

    static func getFilePath(for file: File) -> Result<URL, Failure> {
        switch file {
        case .generalDerivedData:
            return .success(.derivedDataURL)

        case let .applicationSpecificDerivedData(detail):
            do {
                let urls = try FileManager
                    .default
                    .contentsOfDirectory(
                        at: .derivedDataURL,
                        includingPropertiesForKeys: [
                            .isDirectoryKey,
                            .creationDateKey,
                            .contentModificationDateKey,
                            .contentAccessDateKey,
                            .contentTypeKey,
                            .totalFileSizeKey
                        ]
                    )

                let applicationDerivedDataURL = urls.filter { (url: URL) in
                    url.absoluteString.localizedStandardContains(detail.displayName!)
                }
                .sorted { lhsURL, rhsURL in
                    let lhsResourceValues = try! lhsURL.resourceValues(forKeys: [.contentAccessDateKey])
                    let rhsResourceValues = try! rhsURL.resourceValues(forKeys: [.contentAccessDateKey])

                    return lhsResourceValues.contentAccessDate ?? Date() > rhsResourceValues.contentAccessDate ?? Date()
                }
                .first

                guard let applicationDerivedDataURL else {
                    return .failure(Failure.message("url does not exists"))
                }

                return .success(applicationDerivedDataURL)
            } catch {
                return .failure(Failure.message(error.localizedDescription))
            }

        case .infoPlist(let applicationDerivedDataPath):
            let url = URL(filePath: applicationDerivedDataPath)
                .appendingPathComponent(
                    "info.plist",
                    conformingTo: .propertyList
                )

            return .success(url)

        case .workspacePath(let pListURL):
            do {
                let data = try Data(contentsOf: pListURL)
                if let plist = try PropertyListSerialization.propertyList(
                    from: data,
                    options: [],
                    format: nil
                ) as? [String: Any] {
                    guard let path = plist["WorkspacePath"] as? String else {
                        return .failure(Failure.message("Could not find WorkspacePath"))
                    }

                    guard FileManager.default.fileExists(atPath: path) else {
                        let xcodeprojPath = path.replacingOccurrences(of: "xcworkspace", with: "xcodeproj")
                        return .success(URL(fileURLWithPath: xcodeprojPath))
                    }

                    return .success(URL(fileURLWithPath: path))
                } else {
                    return .failure(Failure.message("Failed to cast plist to [String: Any]"))
                }
            } catch {
                return .failure(Failure.message(error.localizedDescription))
            }

        case .applicationBinary(let applicationDerivedDataPath, let displayName):
            let url = URL(filePath: applicationDerivedDataPath)
                .appendingPathComponent("Build")
                .appendingPathComponent("Products")
                .appendingPathComponent("Debug-iphonesimulator")
                .appendingPathComponent("\(displayName).app", conformingTo: .application)

            return .success(url)
        }
    }
}

private extension URL {
    var fileItem: FileItem? {
        guard let resourceValues = try? self.resourceValues(forKeys: .default) else {
            return nil
        }

        return FileItem(
            creationDate: resourceValues.creationDate,
            isDirectory: resourceValues.isDirectory == true,
            modificationDate: resourceValues.contentModificationDate,
            name: self.lastPathComponent,
            size: resourceValues.totalFileSize,
            contentType: resourceValues.contentType?.identifier,
            url: self
        )
    }
}

extension Collection where Element == URL {
    var fileItems: [FileItem] {
        return self.compactMap(\.fileItem)
    }
}
