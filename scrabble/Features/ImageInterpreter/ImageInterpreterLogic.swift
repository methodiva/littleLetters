import SwiftyJSON
import Foundation

protocol ImageInterpreterLogicProtocol: FeatureLogicProtocol {
    func getLabel(for image: CameraImageProtocol, startingFrom letter: Character) -> String?
}

// This feature uses Google Vision API to detect objects in the image,
// And further analyses the results

class ImageInterpreterLogic: ImageInterpreterLogicProtocol {
    
    let urlSession = URLSession.shared
    var googleAPIKey = "AIzaSyCwZptA29KD3UpFDIStXIcGihVaU9z2lNE"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
    }
    
    func getLabel(for image: CameraImageProtocol, startingFrom letter: Character) -> String? {
        getDataFromVisionAPI(for: image, dataInterpreterCallback: { (data) in
            // Analyse data
            let labelList = self.getLabelList(for: data)
            log.debug(labelList)
        })
        return nil
    }
   
    private func getLabelList(for dataToParse: Data) -> [String]?{
        do {
            let json = try JSON(data: dataToParse)
            let errorObj: JSON =  json["error"]
            
            if (errorObj.dictionaryValue != [:]) {
                log.error("Error code \(errorObj["code"]): \(errorObj["message"])")
                return nil
            } else {
                let responses: JSON = json["responses"][0]
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    return labels
                } else {
                    log.warning("No Label found")
                    return nil
                }
            }
        } catch {
            log.error("Error, couldnt parse json")
            return nil
        }
     }
}
/// Networking
extension ImageInterpreterLogic {
    private func getDataFromVisionAPI(for image: CameraImageProtocol, dataInterpreterCallback:((Data) -> Void)?) {
        guard let imageForRequest = imageConverter.toString(for: image, compressionFactor: 8) else {
            return
        }
        guard let request = createRequest(with: imageForRequest) else {
            return
        }
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequest(request, dataInterpreterCallback: dataInterpreterCallback)}
    }
    
    func createRequest(with imageBase64: String) -> URLRequest? {
        // Create our request URL
        print("Creating request")
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            log.error("Couldn't create a request")
            return nil
        }
        request.httpBody = data
        return request
    }
    
    func runRequest(_ request: URLRequest, dataInterpreterCallback:((Data) -> Void)?) {
        // run the request
        print("About to run request")
        let task: URLSessionDataTask = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Ran request")
            dataInterpreterCallback?(data)
        }
        task.resume()
    }
}


