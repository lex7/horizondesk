// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DebtsQuery: GraphQLQuery {
  public static let operationName: String = "DebtsQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query DebtsQuery { creditors { __typename debtId orgCreditorName paid settlementAmount debtBuyerName nextPayDate nextPayment numTotalPayments numPayMade settlementPercent originalDebtAmount settlementFee settlementFeePercent hasSummons paidPercent isSettled isNeedAction offerId transactions { __typename ...TransactionDetails } } }"#,
      fragments: [TransactionDetails.self]
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
        .field("orgCreditorName", String?.self),
        .field("paid", Double.self),
        .field("settlementAmount", Double?.self),
        .field("debtBuyerName", String?.self),
        .field("nextPayDate", ForthGraphQLApi.Date?.self),
        .field("nextPayment", Double?.self),
        .field("numTotalPayments", Int.self),
        .field("numPayMade", Int.self),
        .field("settlementPercent", Double?.self),
        .field("originalDebtAmount", Double?.self),
        .field("settlementFee", Double?.self),
        .field("settlementFeePercent", Double?.self),
        .field("hasSummons", Bool.self),
        .field("paidPercent", Double?.self),
        .field("isSettled", Bool.self),
        .field("isNeedAction", Bool.self),
        .field("offerId", Int?.self),
        .field("transactions", [Transaction].self),
      ] }

      public var debtId: Int { __data["debtId"] }
      public var orgCreditorName: String? { __data["orgCreditorName"] }
      public var paid: Double { __data["paid"] }
      public var settlementAmount: Double? { __data["settlementAmount"] }
      public var debtBuyerName: String? { __data["debtBuyerName"] }
      public var nextPayDate: ForthGraphQLApi.Date? { __data["nextPayDate"] }
      public var nextPayment: Double? { __data["nextPayment"] }
      public var numTotalPayments: Int { __data["numTotalPayments"] }
      public var numPayMade: Int { __data["numPayMade"] }
      public var settlementPercent: Double? { __data["settlementPercent"] }
      public var originalDebtAmount: Double? { __data["originalDebtAmount"] }
      public var settlementFee: Double? { __data["settlementFee"] }
      public var settlementFeePercent: Double? { __data["settlementFeePercent"] }
      public var hasSummons: Bool { __data["hasSummons"] }
      public var paidPercent: Double? { __data["paidPercent"] }
      public var isSettled: Bool { __data["isSettled"] }
      public var isNeedAction: Bool { __data["isNeedAction"] }
      public var offerId: Int? { __data["offerId"] }
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
          .fragment(TransactionDetails.self),
        ] }

        public var amount: Double { __data["amount"] }
        public var date: ForthGraphQLApi.Date? { __data["date"] }
        public var status: String? { __data["status"] }
        public var number: String { __data["number"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var transactionDetails: TransactionDetails { _toFragment() }
        }
      }
    }
  }
}
