import SwiftData

@Model
final class Fact: Codable, Hashable {
  var text: String
  var number: Int
  var year: Int?
  var date: String?
  var kind: Kind
  
  var isFavorite: Bool
  
  enum CodingKeys: String, CodingKey {
    case text
    case number
    case year
    case date
    case found
    case kind = "type"
    case isFavorite
  }
 
  enum Kind: String, Codable, CaseIterable {
    case trivia
    case year
    case date
    case math
  }
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.text = try container.decode(String.self, forKey: .text)
    self.number = try container.decode(Int.self, forKey: .number)
    self.year = try container.decodeIfPresent(Int.self, forKey: .year)
    self.date = try container.decodeIfPresent(String.self, forKey: .date)
    self.kind = try container.decode(Kind.self, forKey: .kind)
    
    self.isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
  }
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.text, forKey: .text)
    try container.encode(self.number, forKey: .number)
    try container.encodeIfPresent(self.year, forKey: .year)
    try container.encodeIfPresent(self.date, forKey: .date)
    try container.encode(self.kind, forKey: .kind)
    
    try container.encode(self.isFavorite, forKey: .isFavorite)
  }
  
  init(
    text: String = "",
    number: Int = 0,
    year: Int? = nil,
    date: String? = nil,
    kind: Kind = Kind.trivia,
    isFavorite: Bool = false
  ) {
    self.text = text
    self.number = number
    self.year = year
    self.date = date
    self.kind = kind
    self.isFavorite = isFavorite
  }
}
