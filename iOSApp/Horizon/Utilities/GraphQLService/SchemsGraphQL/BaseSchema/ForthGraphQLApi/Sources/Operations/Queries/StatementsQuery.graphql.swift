// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class StatementsQuery: GraphQLQuery {
  public static let operationName: String = "StatementsQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query StatementsQuery { statements { __typename title link } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("statements", [Statement].self),
    ] }

    public var statements: [Statement] { __data["statements"] }

    /// Statement
    ///
    /// Parent Type: `StatementResponseDto`
    public struct Statement: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.StatementResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String?.self),
        .field("link", String?.self),
      ] }

      public var title: String? { __data["title"] }
      public var link: String? { __data["link"] }
    }
  }
}
