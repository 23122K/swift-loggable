import SwiftSyntaxMacros

extension AbstractSourceLocation {
  var findable: String {
    let _file = self.file
      .trimmedDescription
      .replacingOccurrences(of: #"""#, with: "")
    
    let _line = self.line
      .trimmedDescription
    
    let _column = self.column
      .trimmedDescription
    
    return "\(_file):\(_line):\(_column)"
  }
}
