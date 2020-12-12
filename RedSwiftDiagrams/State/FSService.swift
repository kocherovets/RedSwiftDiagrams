import Foundation
import UIKit

class FSService {
    var saveDelegate: SaveDelegate?
    var loadDelegate: LoadDelegate?

    func save(value: FSDiagram) -> Error? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(value)

        guard let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("Export.json") else { return nil }

        try? data.write(to: url)

        ui {
            let controller = UIDocumentPickerViewController(forExporting: [url])
            controller.shouldShowFileExtensions = true
            self.saveDelegate = SaveDelegate(data: data, url: url)
            controller.delegate = self.saveDelegate
            UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true) {
            }
        }
        return nil
    }

    class SaveDelegate: NSObject, UIDocumentPickerDelegate {
        var data: Data
        var url: URL

        init(data: Data, url: URL) {
            self.data = data
            self.url = url
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let exportURL = urls.first {
                try? data.write(to: exportURL)
                try? FileManager.default.removeItem(at: url)
            }
        }
    }

    func load(complete: @escaping (Result<FSDiagram, Error>) -> Void) {
        ui {
            let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
            controller.shouldShowFileExtensions = true
            controller.allowsMultipleSelection = false
            self.loadDelegate = LoadDelegate(complete: complete)
            controller.delegate = self.loadDelegate
            UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true) {
            }
        }
    }

    class LoadDelegate: NSObject, UIDocumentPickerDelegate {
        var complete: (Result<FSDiagram, Error>) -> Void

        init(complete: @escaping (Result<FSDiagram, Error>) -> Void) {
            self.complete = complete
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            do {
                if let url = urls.first {
                    let decoder = JSONDecoder()

                    let data = try Data(contentsOf: url)
                    let result = try decoder.decode(FSDiagram.self, from: data)
                    
                    complete(.success(result))
                }
            } catch {
                complete(.failure(error))
            }
        }
    }
}
