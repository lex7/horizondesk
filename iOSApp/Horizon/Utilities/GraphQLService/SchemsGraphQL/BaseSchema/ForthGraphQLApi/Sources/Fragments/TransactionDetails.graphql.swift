// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct TransactionDetails: ForthGraphQLApi.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment TransactionDetails on DebtTransactionDto { __typename amount date status number }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DebtTransactionDto }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", Double.self),
    .field("date", ForthGraphQLApi.Date?.self),
    .field("status", String?.self),
    .field("number", String.self),
  ] }

  public var amount: Double { __data["amount"] }
  public var date: ForthGraphQLApi.Date? { __data["date"] }
  public var status: String? { __data["status"] }
  public var number: String { __data["number"] }
}
