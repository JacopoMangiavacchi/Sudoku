import Foundation

struct Sudoku {
    private(set) var solutionMatrix: [[Int]]
    private(set) var initialMatrix: [[Int]]
    var workingMatrix: [[Int]]
    
    init(matrix: [[Int]], percent: Float = 0.44) {
        self.solutionMatrix = matrix
        self.initialMatrix = matrix
        self.workingMatrix = matrix
        if self.solve() {
            self.clear(percent: percent)
        }
    }
    
    init(size: Int, percent: Float = 0.44) {
        let matrix = [[Int]](repeating: [Int](repeating: 0, count: size), count: size)
        
        self.workingMatrix = matrix
        self.solutionMatrix = matrix
        self.initialMatrix = matrix
        self.solve()
        self.solutionMatrix = workingMatrix
        self.clear(percent: percent)
        self.initialMatrix = workingMatrix
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
    
    mutating func solve() -> Bool {
        let size = workingMatrix.count
        guard size > 0 && (workingMatrix.map{$0.count}.filter{$0 == size}.count == size) else { return false }
        
        var candidateMatrix: [[[Int]]] = [[[Int]]](repeating: [[Int]](repeating: [Int](), count: size), count: size) //candidateMatrix[row][col][candidate]
        var solvedMatrix: [[Int]] = [[Int]]()
        
        while solvedMatrix.count < size {
            var row = solvedMatrix.count
            
            var thisRow = [Int]()
            while thisRow.count < size {
                var col = thisRow.count
                
                var thisCol = [Int]()
                for r in 0..<row {
                    if solvedMatrix[r][col] > 0 {
                        thisCol.append(solvedMatrix[r][col])
                    }
                }
                for r in row..<size {
                    thisCol.append(workingMatrix[r][col])
                }
                
                if workingMatrix[row][col] == 0 {
                    var rowsCandidateUsed = thisRow
                    for c in workingMatrix[row] {
                        if c > 0 && !rowsCandidateUsed.contains(c) {
                            rowsCandidateUsed.append(c)
                        }
                    }
                    for c in candidateMatrix[row][col] {
                        if !rowsCandidateUsed.contains(c) {
                            rowsCandidateUsed.append(c)
                        }
                    }
                    for c in thisCol {
                        if c > 0 && !rowsCandidateUsed.contains(c) {
                            rowsCandidateUsed.append(c)
                        }
                    }
                    
                    if rowsCandidateUsed.count < size {
                        var candidate = Int(arc4random_uniform(UInt32(size))+1)
                        while rowsCandidateUsed.contains(candidate) {
                            candidate = Int(arc4random_uniform(UInt32(size))+1)
                        }
                        
                        thisRow.append(candidate)
                    }
                    else {
                        if col > 0 {
                            //print("3 r=\(row) c=\(col) row=\(thisRow) working=\(workingMatrix[row]) candidates=\(rowsCandidateUsed)")
                            for c in stride(from: col, to: 0, by: -1) {
                                let last = thisRow.removeLast()
                                //print("    remove \(last) from col \(c)")
                                candidateMatrix[row][c].removeAll()
                                candidateMatrix[row][c-1].append(last)
                                
                                if workingMatrix[row][c-1] == 0 {
                                    break
                                }
                            }
                            
                            if thisRow.count == 0 && workingMatrix[row][0] > 0 {
                                col = 0
                            }
                        }
                        
                        if col == 0 && row > 0 {
                            //print("1 r=\(row) c=\(col) row=\(thisRow) working=\(workingMatrix[row]) candidates=\(rowsCandidateUsed)")
                            
                            candidateMatrix[row] = [[Int]](repeating: [Int](), count: size)
                            thisRow = solvedMatrix.removeLast()
                            row -= 1
                            col = size - 1
                            //print("2 r=\(row) c=\(col) row=\(thisRow) working=\(workingMatrix[row])")
                            
                            for c in stride(from: col, to: 0, by: -1) {
                                let last = thisRow.removeLast()
                                //print(" remove \(last) from col \(c)")
                                candidateMatrix[row][c].append(last)
                                
                                if workingMatrix[row][c] == 0 {
                                    break
                                }
                            }
                        }
                    }
                }
                else {
                    thisRow.append(workingMatrix[row][col])
                }
            }
            solvedMatrix.append(thisRow)
        }
        
        
        let expTot = (size * (size+1) / 2)
        for row in solvedMatrix {
            if row.reduce(0, +) != expTot {
                return false
            }
        }
        for c in 0..<size {
            var col = [Int]()
            for r in solvedMatrix {
                col.append(r[c])
            }
            if col.reduce(0, +) != expTot {
                return false
            }
        }
        
        workingMatrix = solvedMatrix
        return true
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
print("")
print(s.solve())
print("")
s.display(.working)

