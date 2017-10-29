import Foundation

struct Sudoku {
    let solutionMatrix: [[Int]]
    private(set) var initialMatrix: [[Int]]
    var workingMatrix: [[Int]]

    init(matrix: [[Int]], percent: Float = 0.44) {
        self.solutionMatrix = matrix
        self.initialMatrix = matrix
        self.workingMatrix = matrix
        self.clear(percent: percent)
    }
    
    init(size: Int, percent: Float = 0.44) {
        var matrix = [[Int]]()

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
        
        self.solutionMatrix = matrix
        self.initialMatrix = matrix
        self.workingMatrix = matrix
        self.clear(percent: percent)
    }
    
    internal mutating func clear(percent: Float) {
        let size = workingMatrix.count
        let square = 3
        
        for row in stride(from: 0, to: size, by: square) {
            for col in stride(from: 0, to: size, by: square) {
                let rowLenght = row+square > size ? size-row : square
                let colLenght = col+square > size ? size-col : square
                let squareSize = rowLenght * colLenght
                let toHide = Int(Float(squareSize) * percent)
                var hidePositions = [Int]()
                for _ in 0..<toHide {
                    var candidate = Int(arc4random_uniform(UInt32(squareSize)))
                    while hidePositions.contains(candidate) {
                        candidate = Int(arc4random_uniform(UInt32(squareSize)))
                    }
                    hidePositions.append(candidate)
                }
             
                for posToHide in hidePositions {
                    let rowToHide = row + (posToHide / colLenght)
                    let colToHide = col + (posToHide % colLenght)
                    workingMatrix[rowToHide][colToHide] = 0
                }
            }
        }
        
        self.initialMatrix = workingMatrix
    }

    
    enum KindOfMatrix {
        case solution
        case initial
        case working
    }
    
    func display(_ kindOfMatrix: KindOfMatrix = .solution) {
        var matrix: [[Int]]!
        
        switch(kindOfMatrix) {
        case .solution:
            matrix = solutionMatrix
        case .initial:
            matrix = initialMatrix
        case .working:
            matrix = workingMatrix
        }

        matrix.map{$0.map{$0 > 0 ? String($0) : " "}.joined(separator: " ")}.forEach{print($0)}
    }
}

var s = Sudoku(size: 9, percent: 0.5)
s.display()
print("")
s.display(.initial)
print("")
s.display(.working)

