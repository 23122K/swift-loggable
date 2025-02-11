import SwiftSyntax

@dynamicMemberLookup
struct FunctionSyntax {
  let syntax: FunctionDeclSyntax
  let signature: Signature

  subscript<T>(dynamicMember keyPath: KeyPath<Signature, T>) -> T {
    get { signature[keyPath: keyPath] }
  }

  /// Returns a description of the original function's signature.
  var description: String {
    var syntax = self.syntax
    syntax.attributes = []
    syntax.body = nil
    return syntax.trimmedDescription
  }

  /// Creates an `InitializerClauseSyntax` that initializes a copy of the called function with an `_` prefix,
  /// appending `try` and/or `await`  as needed based on function's declaration.
  var initializer: InitializerClauseSyntax {
    let expression = FunctionCallExprSyntax(
      calledExpression: DeclReferenceExprSyntax(
        baseName: .identifier("_\(self.syntax.name.text)")
      ),
      leftParen: .leftParenToken(),
      arguments: self.signature.arguments,
      rightParen: .rightParenToken()
    )

    switch (self.signature.isThrowing, self.signature.isAsync) {
    case (true, true):
      let awaitExprSyntax = AwaitExprSyntax(expression)
      let tryExprSyntax = TryExprSyntax(awaitExprSyntax)
      return InitializerClauseSyntax(value: tryExprSyntax)

    case (true, false):
      let tryExprSyntax = TryExprSyntax(expression)
      return InitializerClauseSyntax(value: tryExprSyntax)

    case (false, true):
      let awaitExprSyntax = AwaitExprSyntax(expression)
      return InitializerClauseSyntax(value: awaitExprSyntax)

    case (false, false):
      return InitializerClauseSyntax(value: expression)
    }
  }

  /// Returns `true` if the function includes any generic parameters, otherwise returns `false`.
  var isGeneric: Bool { self.syntax.genericParameterClause != nil }

  /// Produces a `FunctionDeclSyntax` that is prefixed with `_`, has all attributes, modifiers, and generic declarations removed.
  /// Uses the signature provided by the `plain` property of `Signature`.
  var plain: FunctionDeclSyntax {
    var syntax = self.syntax
    syntax.attributes = []
    syntax.modifiers = []
    syntax.name = .identifier("_\(self.syntax.name.text)")
    syntax.signature = self.signature.plain
    syntax.genericParameterClause = nil
    syntax.genericWhereClause = nil
    return syntax
  }

  struct Signature {
    let syntax: FunctionSignatureSyntax
    let parameters: [Parameter]

    /// Returns `true` if the function signature does not include a return clause, otherwise returns `false`.
    var isVoid: Bool { self.syntax.returnClause == nil }

    /// Returns `true` if the function is marked `async`, otherwise, returns `false`.
    var isAsync: Bool { self.syntax.effectSpecifiers?.asyncSpecifier != nil }

    /// Returns `true` if the function is marked `throwing`, otherwise, returns `false`.
    var isThrowing: Bool { self.syntax.effectSpecifiers?.throwsClause != nil }

    /// Produces a `LabeledExprListSyntax` containing all parameters required by the copy of the original function.
    /// Handles cases where a parameter is preceded by the `@autoclosure` attribute or the `inout` keyword.
    /// Otherwise, a parameter is returned without any wrapping.
    var arguments: LabeledExprListSyntax {
      LabeledExprListSyntax(
        self.parameters.map { parameter in
          let presence: SourcePresence =
            self.parameters.last == parameter
            ? .missing
            : .present
          return parameter.asLabeledExprSyntax(trailingComma: presence)
        }
      )
    }

    /// Returns a `FunctionSignatureSyntax` by mapping parameters via `plain` representation from `Parameter`.
    var plain: FunctionSignatureSyntax {
      var syntax = self.syntax
      syntax.parameterClause.parameters = FunctionParameterListSyntax(self.parameters.map(\.plain))
      return syntax
    }

    struct Parameter: Equatable {
      let syntax: FunctionParameterSyntax

      /// Returns `true` if parameter is marked as `inout`, otherwise returns `false`.
      var isInout: Bool {
        guard let attributedType = AttributedTypeSyntax(self.syntax.type)
        else { return false }

        return attributedType.specifiers.contains { specifierType in
          switch specifierType {
          case let .simpleTypeSpecifier(syntax) where syntax.specifier.tokenKind == .keyword(.inout):
            return true

          default:
            return false
          }
        }
      }

      /// Returns `true` when parameter is preceded with `@autoclosure` attribute, otherwise returns `false`.
      var isAutoclosure: Bool {
        guard let attributedType = AttributedTypeSyntax(self.syntax.type)
        else { return false }

        return attributedType.attributes.contains { attribute in
          guard case let .attribute(syntax) = attribute else { return false }
          guard let name = syntax.attributeName.as(IdentifierTypeSyntax.self) else { return false }
          return name.name.tokenKind == .autoclosure
        }
      }

      func asLabeledExprSyntax(trailingComma presence: SourcePresence) -> LabeledExprSyntax {
        switch (self.isInout, self.isAutoclosure) {
        case (true, false):
          return LabeledExprSyntax(
            label: self.name,
            colon: .colonToken(),
            expression: InOutExprSyntax(
              expression: DeclReferenceExprSyntax(baseName: self.name)
            ),
            trailingComma: .commaToken(presence: presence)
          )

        case (false, true):
          return LabeledExprSyntax(
            label: self.name,
            colon: .colonToken(),
            expression: FunctionCallExprSyntax(
              calledExpression: DeclReferenceExprSyntax(baseName: self.name),
              leftParen: .leftParenToken(),
              arguments: [],
              rightParen: .rightParenToken()
            ),
            trailingComma: .commaToken(presence: presence)
          )

        default:
          return LabeledExprSyntax(
            label: self.name,
            colon: .colonToken(),
            expression: DeclReferenceExprSyntax(baseName: self.name),
            trailingComma: .commaToken(presence: presence)
          )
        }
      }

      /// Returns the function's parameter name, disregarding any provided label.
      /// eg.  `name` for `func foo(bar baz: Biz)` signature will return `baz`.
      var name: TokenSyntax {
        guard let identifer = self.syntax.secondName
        else { return self.syntax.firstName }
        return identifer
      }

      /// Returns `FunctionParameterSyntax` stripped of any parameter label, default values and types.
      var plain: FunctionParameterSyntax {
        var syntax = self.syntax
        syntax.firstName = self.name
        syntax.secondName = nil
        syntax.defaultValue = nil
        syntax.type = self.syntax.type.trimmed
        return syntax
      }
    }

    init(syntax: FunctionSignatureSyntax) {
      self.syntax = syntax
      self.parameters = syntax.parameterClause.parameters.map(Parameter.init)
    }
  }

  init(_ syntax: FunctionDeclSyntax) {
    self.syntax = syntax
    self.signature = Signature(syntax: syntax.signature)
  }

  init?(from syntax: some DeclSyntaxProtocol) {
    guard let syntax = syntax.as(FunctionDeclSyntax.self)
    else { return nil }
    self.init(syntax)
  }
}
