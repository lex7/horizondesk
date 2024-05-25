// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TransactionTypesQuery: GraphQLQuery {
  public static let operationName: String = "TransactionTypesQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query TransactionTypesQuery { transactionTypes }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("transactionTypes", [GraphQLEnum<ForthGraphQLApi.ConsumerTransactionType>].self),
    ] }

    @available(*, deprecated, message: "Use dictionary instead")
    public var transactionTypes: [GraphQLEnum<ForthGraphQLApi.ConsumerTransactionType>] { __data["transactionTypes"] }
  }
}
