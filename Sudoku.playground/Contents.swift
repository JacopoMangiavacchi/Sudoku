import Foundation

struct Sudoku {
    var matrix: [[Int]]

    init(matrix: [[Int]]) {
        self.matrix = matrix
    }
    
    init(size: Int) {
        matrix = [[Int]]()

        for row in 0..<size {
            var thisRow = [Int]()
            var colsCandidateUsed = [[Int]](repeating: [Int](), count: size)
            while thisRow.count < size {
                let col = thisRow.count

                var thisCol = [Int]()
                for r in 0..<row {
                    thisCol.append(matrix[r][col])
                }
                
                var rowsCandidateUsed = thisRow
                for c in colsCandidateUsed[col] {
                    rowsCandidateUsed.append(c)
                }
                
                var candidate = Int(arc4random_uniform(UInt32(size))+1)
                var foundCandidate = false

                while rowsCandidateUsed.count < size {
                    while rowsCandidateUsed.contains(candidate) {
                        candidate = Int(arc4random_uniform(UInt32(size))+1)
                    }
                    rowsCandidateUsed.append(candidate)
                    
                    if !thisCol.contains(candidate) {
                        foundCandidate = true
                        break
                    }
                }
                
                if foundCandidate {
                    thisRow.append(candidate)
                }
                else {
                    let last = thisRow.removeLast()
                    colsCandidateUsed[col].removeAll()
                    colsCandidateUsed[col-1].append(last)
                }
            }
            matrix.append(thisRow)
        }
    }
    
    mutating func clean(percent: Float = 0.44) {
        
    }

    func check() {
        
    }
    
    func display() {
        matrix.map{$0.map{String($0)}.joined(separator: " ")}.forEach{print($0)}
    }
}

var s = Sudoku(size: 9)
s.display()

