import SwiftyJSON
import Foundation

struct ImageLabel {
    let Score: Float
    let Topicality: Float
    let label: String
}

protocol ImageInterpreterLogicProtocol: FeatureLogicProtocol {
    func getLabel(for image: CameraImageProtocol, startingFrom letter: Character, labelCallBack: ((String) -> Void)?)
}

// This feature uses Google Vision API to detect objects in the image,
// And further interprets the results

class ImageInterpreterLogic: ImageInterpreterLogicProtocol {
    
    private let urlSession = URLSession.shared
    private var googleAPIKey = "AIzaSyCwZptA29KD3UpFDIStXIcGihVaU9z2lNE"
    private var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
    }
    
    func getLabel(for image: CameraImageProtocol, startingFrom letter: Character, labelCallBack: ((String) -> Void)?) {
        // Send Data to Google Vision API
        getDataFromVisionAPI(for: image, dataInterpreterCallback: { (data) in
            // Interpret data
            guard let labelList = self.getLabelList(for: data) else { return }
            guard let label = self.chooseLabel(from: labelList, startFrom: letter) else {
                log.error("Couldn't find a label for the image")
                return
            }
            labelCallBack?(label)
        })
    }
}

// Image Interpretation
extension ImageInterpreterLogic {
    private func getLabelList(for dataToParse: Data) -> [ImageLabel]?{
        do {
            let json = try JSON(data: dataToParse)
            let errorObj: JSON =  json["error"]
            
            if (errorObj.dictionaryValue != [:]) {
                log.error("Error code \(errorObj["code"]): \(errorObj["message"])")
                return nil
            } else {
                let responses: JSON = json["responses"][0]
                let labelAnnotations: JSON = responses["labelAnnotations"]
                log.debug(labelAnnotations)
                let numLabels: Int = labelAnnotations.count
                var labels: Array<ImageLabel> = []
                if numLabels > 0 {
                    for index in 0..<numLabels {
                        let label = ImageLabel(
                            Score: Float(labelAnnotations[index]["score"].stringValue)!,
                            Topicality: Float(labelAnnotations[index]["topicality"].stringValue)!,
                            label: labelAnnotations[index]["description"].stringValue)
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
    
    private func chooseLabel(from labelList: [ImageLabel], startFrom letter: Character) -> String? {
        // TODO: Sophesticated logic to choose the label
        return labelList.first?.label
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


