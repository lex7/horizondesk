// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FaqQuery: GraphQLQuery {
  public static let operationName: String = "FaqQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FaqQuery { faq { __typename question answer } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("faq", [Faq].self),
    ] }

    public var faq: [Faq] { __data["faq"] }

    /// Faq
    ///
    /// Parent Type: `FaqResponseDto`
    public struct Faq: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.FaqResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("question", String.self),
        .field("answer", String.self),
      ] }

      public var question: String { __data["question"] }
      public var answer: String { __data["answer"] }
    }
  }
}
