// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TransactionFilterMaxQuery: GraphQLQuery {
  public static let operationName: String = "TransactionFilterMaxQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query TransactionFilterMaxQuery($processDate: SortEnumType! = ASC, $showFuture: Boolean! = true, $processDateFrom: Date = null, $processDateTo: Date = null, $transactionIntStatuses: [Int!] = null, $transactionTypes: [String!] = null, $first: Int = 1000, $after: String) { transactions( first: $first filter: { showFuture: $showFuture, processDateFrom: $processDateFrom, processDateTo: $processDateTo, transactionIntStatuses: $transactionIntStatuses, transactionTypes: $transactionTypes } order: { processDate: $processDate } after: $after ) { __typename pageInfo { __typename hasNextPage endCursor } totalCount nodes { __typename transactionAmount transactionStatusName transactionTypeName processDate transactionId memo transactionSubType transactionSubTypeName checkImgUri } } }"#
    ))

  public var processDate: GraphQLEnum<SortEnumType>
  public var showFuture: Bool
  public var processDateFrom: GraphQLNullable<Date>
  public var processDateTo: GraphQLNullable<Date>
  public var transactionIntStatuses: GraphQLNullable<[Int]>
  public var transactionTypes: GraphQLNullable<[String]>
  public var first: GraphQLNullable<Int>
  public var after: GraphQLNullable<String>

  public init(
    processDate: GraphQLEnum<SortEnumType> = .init(.asc),
    showFuture: Bool = true,
    processDateFrom: GraphQLNullable<Date> = .null,
    processDateTo: GraphQLNullable<Date> = .null,
    transactionIntStatuses: GraphQLNullable<[Int]> = .null,
    transactionTypes: GraphQLNullable<[String]> = .null,
    first: GraphQLNullable<Int> = 1000,
    after: GraphQLNullable<String>
  ) {
    self.processDate = processDate
    self.showFuture = showFuture
    self.processDateFrom = processDateFrom
    self.processDateTo = processDateTo
    self.transactionIntStatuses = transactionIntStatuses
    self.transactionTypes = transactionTypes
    self.first = first
    self.after = after
  }

  public var __variables: Variables? { [
    "processDate": processDate,
    "showFuture": showFuture,
    "processDateFrom": processDateFrom,
    "processDateTo": processDateTo,
    "transactionIntStatuses": transactionIntStatuses,
    "transactionTypes": transactionTypes,
    "first": first,
    "after": after
  ] }

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("transactions", Transactions?.self, arguments: [
        "first": .variable("first"),
        "filter": [
          "showFuture": .variable("showFuture"),
          "processDateFrom": .variable("processDateFrom"),
          "processDateTo": .variable("processDateTo"),
          "transactionIntStatuses": .variable("transactionIntStatuses"),
          "transactionTypes": .variable("transactionTypes")
        ],
        "order": ["processDate": .variable("processDate")],
        "after": .variable("after")
      ]),
    ] }

    public var transactions: Transactions? { __data["transactions"] }

    /// Transactions
    ///
    /// Parent Type: `TransactionsConnection`
    public struct Transactions: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.TransactionsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("totalCount", Int.self),
        .field("nodes", [Node]?.self),
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Identifies the total count of items in the connection.
      public var totalCount: Int { __data["totalCount"] }
      /// A flattened list of the nodes.
      public var nodes: [Node]? { __data["nodes"] }

      /// Transactions.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: ForthGraphQLApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self),
        ] }

        /// Indicates whether more edges exist following the set defined by the clients arguments.
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// Transactions.Node
      ///
      /// Parent Type: `TransactionResponseDto`
      public struct Node: ForthGraphQLApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.TransactionResponseDto }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("transactionAmount", Double.self),
          .field("transactionStatusName", String.self),
          .field("transactionTypeName", String?.self),
          .field("processDate", ForthGraphQLApi.Date?.self),
          .field("transactionId", Int.self),
          .field("memo", String?.self),
          .field("transactionSubType", Int?.self),
          .field("transactionSubTypeName", String?.self),
          .field("checkImgUri", String?.self),
        ] }

        public var transactionAmount: Double { __data["transactionAmount"] }
        public var transactionStatusName: String { __data["transactionStatusName"] }
        public var transactionTypeName: String? { __data["transactionTypeName"] }
        public var processDate: ForthGraphQLApi.Date? { __data["processDate"] }
        public var transactionId: Int { __data["transactionId"] }
        public var memo: String? { __data["memo"] }
        public var transactionSubType: Int? { __data["transactionSubType"] }
        public var transactionSubTypeName: String? { __data["transactionSubTypeName"] }
        public var checkImgUri: String? { __data["checkImgUri"] }
      }
    }
  }
}
