// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ShortQuery: GraphQLQuery {
  public static let operationName: String = "ShortQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ShortQuery { creditors { __typename debtId transactions { __typename amount date status number } } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("creditors", [Creditor].self),
    ] }

    public var creditors: [Creditor] { __data["creditors"] }

    /// Creditor
    ///
    /// Parent Type: `CreditorResponseDto`
    public struct Creditor: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.CreditorResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("debtId", Int.self),
        .field("transactions", [Transaction].self),
      ] }

      public var debtId: Int { __data["debtId"] }
      public var transactions: [Transaction] { __data["transactions"] }

      /// Creditor.Transaction
      ///
      /// Parent Type: `DebtTransactionDto`
      public struct Transaction: ForthGraphQLApi.SelectionSet {
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
    }
  }
}
