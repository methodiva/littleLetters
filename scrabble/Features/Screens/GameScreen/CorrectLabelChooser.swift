class CorrectLabelChooser {
    
    let threshold: Float = 0.6
    
    let wordsToIgnore = [ "product", "blue" ]
    
    func getCorrectLabel(from labelList: [ImageLabel], startFrom firstLetter: Character) -> String? {
        
        let labelFilteredList = filter(labelList: labelList)
        
        // Filtering for correct first letter
        let labelsStartingFromCorrectLetter = labelFilteredList.filter { (label) -> Bool in
            return label.description.first == firstLetter
        }
        log.debug("list here 5\(labelsStartingFromCorrectLetter)")
        
        
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
        // Filtering for the minimum probablity allowed
        log.debug("list here 1\(labelList)")
        var labelFilteredList = labelList.filter { (label) -> Bool in
            return label.Score > threshold
        }
        
        log.debug("list here 2\(labelFilteredList)")
        
        // Filtering for labels with more than one word
        labelFilteredList = labelFilteredList.filter { (label) -> Bool in
            let words = label.description.components(separatedBy: " ")
            return words.count == 1
        }
        
        log.debug("list here 3\(labelFilteredList)")
        
        // Filtering for words to ignore
        labelFilteredList = labelFilteredList.filter{ (label) -> Bool in
            for word in wordsToIgnore {
                if word == label.description {
                    return false
                }
            }
            return true
        }
        log.debug("list here 4\(labelFilteredList)")
        
        return labelFilteredList
    }
    
    private func chooseMostAppropriateLabel(from labelList: [ImageLabel]) -> ImageLabel {
        var selectedLabel = ImageLabel(Score: 0, Topicality: 0, description: "")
        for label in labelList {
            selectedLabel = chooseWordBetween(first: label, second: selectedLabel)
        }
        return selectedLabel
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
let labelChooser = CorrectLabelChooser()
