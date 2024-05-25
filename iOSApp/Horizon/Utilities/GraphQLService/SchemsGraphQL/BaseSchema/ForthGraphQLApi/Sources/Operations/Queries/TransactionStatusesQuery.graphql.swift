// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TransactionStatusesQuery: GraphQLQuery {
  public static let operationName: String = "TransactionStatusesQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query TransactionStatusesQuery { transactionStatuses(filter: {  }) { __typename name enum } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("transactionStatuses", [TransactionStatus].self, arguments: ["filter": []]),
    ] }

    @available(*, deprecated, message: "Use dictionary instead")
    public var transactionStatuses: [TransactionStatus] { __data["transactionStatuses"] }

    /// TransactionStatus
    ///
    /// Parent Type: `TransactionStatusDto`
    public struct TransactionStatus: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.TransactionStatusDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("enum", GraphQLEnum<ForthGraphQLApi.ConsumerTransactionStatus>.self),
      ] }

      public var name: String { __data["name"] }
      public var `enum`: GraphQLEnum<ForthGraphQLApi.ConsumerTransactionStatus> { __data["enum"] }
    }
  }
}
