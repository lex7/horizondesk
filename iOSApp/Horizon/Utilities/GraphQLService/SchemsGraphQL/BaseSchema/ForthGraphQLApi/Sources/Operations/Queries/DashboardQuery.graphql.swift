// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DashboardQuery: GraphQLQuery {
  public static let operationName: String = "DashboardQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query DashboardQuery { dashboard { __typename balance nextPayment nextPaymentDate totalOriginalDebtAmount totalSettledAmount totalSettledPercent totalPaid totalPaymentsCount totalPaymentsMadeCount totalPaymentsPercent creditors { __typename debtId orgCreditorName paid settlementAmount debtBuyerName nextPayDate nextPayment numTotalPayments numPayMade settlementPercent originalDebtAmount settlementFee settlementFeePercent hasSummons paidPercent totalPaidPercent isSettled isNeedAction offerId transactions { __typename amount date status number } } } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("dashboard", Dashboard.self),
    ] }

    public var dashboard: Dashboard { __data["dashboard"] }

    /// Dashboard
    ///
    /// Parent Type: `DashboardResponseDto`
    public struct Dashboard: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DashboardResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("balance", Double.self),
        .field("nextPayment", Double.self),
        .field("nextPaymentDate", ForthGraphQLApi.Date?.self),
        .field("totalOriginalDebtAmount", Double?.self),
        .field("totalSettledAmount", Double?.self),
        .field("totalSettledPercent", Double?.self),
        .field("totalPaid", Double.self),
        .field("totalPaymentsCount", Int.self),
        .field("totalPaymentsMadeCount", Int.self),
        .field("totalPaymentsPercent", Double.self),
        .field("creditors", [Creditor].self),
      ] }

      public var balance: Double { __data["balance"] }
      public var nextPayment: Double { __data["nextPayment"] }
      public var nextPaymentDate: ForthGraphQLApi.Date? { __data["nextPaymentDate"] }
      public var totalOriginalDebtAmount: Double? { __data["totalOriginalDebtAmount"] }
      public var totalSettledAmount: Double? { __data["totalSettledAmount"] }
      public var totalSettledPercent: Double? { __data["totalSettledPercent"] }
      public var totalPaid: Double { __data["totalPaid"] }
      public var totalPaymentsCount: Int { __data["totalPaymentsCount"] }
      public var totalPaymentsMadeCount: Int { __data["totalPaymentsMadeCount"] }
      public var totalPaymentsPercent: Double { __data["totalPaymentsPercent"] }
      public var creditors: [Creditor] { __data["creditors"] }

      /// Dashboard.Creditor
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
          .field("totalPaidPercent", Double?.self),
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
        public var totalPaidPercent: Double? { __data["totalPaidPercent"] }
        public var isSettled: Bool { __data["isSettled"] }
        public var isNeedAction: Bool { __data["isNeedAction"] }
        public var offerId: Int? { __data["offerId"] }
        public var transactions: [Transaction] { __data["transactions"] }

        /// Dashboard.Creditor.Transaction
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
}
