class CorrectLabelSelector {
    
    let threshold: Float = 0.6
    
    let wordsToIgnore = [ "PRODUCT", "BLUE" ]
    
    func getCorrectLabel(from labelList: [ImageLabel], startFrom firstLetter: Character) -> String? {
        
        var upperCasedLabelList = [ImageLabel]()
        
        labelList.forEach { (label) in
            let label = ImageLabel(
                Score: label.Score,
                Topicality: label.Topicality,
                description: label.description.uppercased())
            upperCasedLabelList.append(label)
        }
        
        let labelFilteredList = filter(labelList: upperCasedLabelList)
        
        let labelsStartingFromCorrectLetter = labelFilteredList
            .filter { $0.description.first == firstLetter}
            .logArray("Filtered for starting word")
        
        if labelsStartingFromCorrectLetter.count > 0 {
            return chooseMostAppropriateLabel(from: labelsStartingFromCorrectLetter).description
        }
        
        log.verbose("No words from the correct letter after filtering")
        if labelFilteredList.count > 0 {
            return chooseMostAppropriateLabel(from: labelFilteredList).description
        }
        
        log.verbose("No possible words after filtering")
        return nil
    }
    
    private func filter(labelList: [ImageLabel]) -> [ImageLabel] {
         let labelFilteredList = labelList
            .filter { $0.Score > threshold }
            .logArray("Filtered for probability")
            
            .filter { $0.description.components(separatedBy: " ").count == 1 }
            .logArray("Filtered for single words")
            
            .filter { !wordsToIgnore.contains($0.description) }
            .logArray("Filtered for ignore words")
        
          return labelFilteredList
    }
    
    private func chooseMostAppropriateLabel(from labelList: [ImageLabel]) -> ImageLabel {
        return labelList.reduce(labelList[0], chooseWordBetween)
    }
    
    private func chooseWordBetween(first: ImageLabel, second: ImageLabel) -> ImageLabel {
        if first.description.count > second.description.count {
            return first
        }
        if first.description.count == second.description.count && first.Score > second.Score {
            return first
        }
        return second
    }
}

let labelSelector = CorrectLabelSelector()

extension Array {
    func logArray(_ name: String) -> Array {
        log.debug([name, self])
        return self
    }
}
