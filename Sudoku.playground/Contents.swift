import Foundation

extension Sequence {
    func eachSlice(_ clump:Int) -> [[Self.Element]] {
        return self.reduce(into:[]) { memo, cur in
            if memo.count == 0 {
                return memo.append([cur])
            }
            if memo.last!.count < clump {
                memo.append(memo.removeLast() + [cur])
            } else {
                memo.append([cur])
            }
        }
    }
}


struct Sudoku {
    private(set) var solutionMatrix: [Int]
    private(set) var initialMatrix: [Int]
    var workingMatrix: [Int]
    
    init(base: Int, percent: Float = 0.44) {
        let matrix = [Int](repeating: 0, count: base*base)
        
        self.workingMatrix = matrix
        self.solutionMatrix = matrix
        self.initialMatrix = matrix
        if self.solve(random: true) {
            self.solutionMatrix = workingMatrix
            self.clear(percent: percent)
            self.initialMatrix = workingMatrix
        }
    }
    
    mutating func solve(random: Bool = false) -> Bool {
        let size = workingMatrix.count
        guard size > 0 else { return false }
        let base = Int(sqrt(Double(size)))
        
        var candidateMatrix: [[Int]] = [[Int]](repeating: [Int](), count: size) // if random array of candidate used - else 1 only element is the last candidate used
        var solvedMatrix: [Int] = [Int](repeating: 0, count: size)
        
        var pos = 0
        while pos < size {
            if workingMatrix[pos] == 0 {
                var candidate = 0
                if random {
                    if candidateMatrix[pos].count < base {
                        candidate = Int(arc4random_uniform(UInt32(base))+1)
                        while candidateMatrix[pos].contains(candidate) {
                            candidate = Int(arc4random_uniform(UInt32(base))+1)
                        }
                        candidateMatrix[pos].append(candidate)
                    }
                }
                else {
                    if candidateMatrix[pos].count == 0 {
                        candidateMatrix[pos].append(1)
                        candidate = 1
                    }
                    else {
                        candidate = candidateMatrix[pos][0] + 1
                        if candidate <= base {
                            candidateMatrix[pos][0] = candidate
                        }
                        else {
                            candidate = 0
                        }
                    }
                }
                
                if candidate == 0 {
                    repeat {
                        solvedMatrix[pos] = 0
                        candidateMatrix[pos] = [Int]()
                        pos -= 1
                    }
                    while pos > 0 && workingMatrix[pos] > 0
                    
                    if pos < 0 {
                        print("NO SOLUTION !!!")
                        return false
                    }
                }
                else if checkCandidate(candidate, position: pos, base: base, solvedMatrix: solvedMatrix) {
                    solvedMatrix[pos] = candidate
                    pos += 1
                }
            }
            else {
                solvedMatrix[pos] = workingMatrix[pos]
                pos += 1
            }
        }
            
        workingMatrix = solvedMatrix
        return true
    }
    
    func checkCandidate(_ candidate: Int, position: Int, base: Int, solvedMatrix: [Int]) -> Bool {
        let row = position / base
        let col = position - (row * base)
        
        var rowValues = [Int]()
        var colValues = [Int]()
        var squareValues = [Int]()
        
        for c in 0..<base {
            let p = (row * base) + c
            if workingMatrix[p] > 0 {
                rowValues.append(workingMatrix[p])
            }
            else if solvedMatrix[p] > 0 {
                rowValues.append(solvedMatrix[p])
            }
        }
        
        for r in 0..<base {
            let p = (r * base) + col
            if workingMatrix[p] > 0 {
                colValues.append(workingMatrix[p])
            }
            else if solvedMatrix[p] > 0 {
                colValues.append(solvedMatrix[p])
            }
        }
        
        let square = 3
        let xSquare = row / square
        let ySquare = col / square
        for r in 0..<square {
            for c in 0..<square {
                let realSquareRow = (xSquare * square) + r
                let realSquareCol = (ySquare * square) + c
                
                let p = (realSquareRow * base) + realSquareCol
                if workingMatrix[p] > 0 {
                    squareValues.append(workingMatrix[p])
                }
                else if solvedMatrix[p] > 0 {
                    squareValues.append(solvedMatrix[p])
                }
            }
        }
        
        if checkInArray(candidate, array: rowValues) || checkInArray(candidate, array: colValues) || checkInArray(candidate, array: squareValues) {
            return false
        }
        
        return true
    }

    enum KindOfMatrix {
        case solution
        case initial
        case working
    }
    
    func display(_ kindOfMatrix: KindOfMatrix = .solution) {
        var matrix: [Int]!
        
        switch(kindOfMatrix) {
        case .solution:
            matrix = solutionMatrix
        case .initial:
            matrix = initialMatrix
        case .working:
            matrix = workingMatrix
        }
        
        matrix.eachSlice(Int(sqrt(Double(matrix.count)))).map{$0.map{$0 > 0 ? String($0) : " "}.joined(separator: " ")}.forEach{print($0)}
    }
    
    internal func checkInArray(_ candidate: Int, array: [Int]) -> Bool {
        for v in array {
            if v == candidate {
                return true
            }
        }
        
        return false
    }
    
    internal mutating func clear(percent: Float) {
        let base = Int(sqrt(Double(workingMatrix.count)))
        let square = 3
        
        for row in stride(from: 0, to: base, by: square) {
            for col in stride(from: 0, to: base, by: square) {
                let rowLenght = row+square > base ? base-row : square
                let colLenght = col+square > base ? base-col : square
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
                    
                    workingMatrix[(rowToHide*base) + colToHide] = 0
                }
            }
        }
        
        self.initialMatrix = workingMatrix
    }
}


var startTime = CFAbsoluteTimeGetCurrent()
var s = Sudoku(base: 9, percent: 0.5)
var timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
print("Time elapsed for Generating: \(timeElapsed) s.")

s.display()
print("")

s.display(.initial)
print("")
s.display(.working)
print("")

let backup = s.workingMatrix
startTime = CFAbsoluteTimeGetCurrent()
print(s.solve(random: false))
timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
print("Time elapsed for Solving Sequential: \(timeElapsed) s.")

s.workingMatrix = backup
startTime = CFAbsoluteTimeGetCurrent()
print(s.solve(random: true))
timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
print("Time elapsed for Solving Random: \(timeElapsed) s.")

print("")
s.display(.working)

