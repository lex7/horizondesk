// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DocumentsQuery: GraphQLQuery {
  public static let operationName: String = "DocumentsQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query DocumentsQuery($documentIntTypes: [Int!] = null, $createdDateFrom: DateTime = null, $createdDateTo: DateTime = null, $first: Int = 1000, $after: String, $orderProcessDate: SortEnumType = DESC) { documents( first: $first after: $after filter: { documentIntTypes: $documentIntTypes, createdDateFrom: $createdDateFrom, createdDateTo: $createdDateTo } order: { createdDate: $orderProcessDate } ) { __typename pageInfo { __typename hasNextPage endCursor } totalCount nodes { __typename documentId documentTitle documentTypeId documentTypeName documentFileName description createdDate createdBy createdByName } } }"#
    ))

  public var documentIntTypes: GraphQLNullable<[Int]>
  public var createdDateFrom: GraphQLNullable<DateTime>
  public var createdDateTo: GraphQLNullable<DateTime>
  public var first: GraphQLNullable<Int>
  public var after: GraphQLNullable<String>
  public var orderProcessDate: GraphQLNullable<GraphQLEnum<SortEnumType>>

  public init(
    documentIntTypes: GraphQLNullable<[Int]> = .null,
    createdDateFrom: GraphQLNullable<DateTime> = .null,
    createdDateTo: GraphQLNullable<DateTime> = .null,
    first: GraphQLNullable<Int> = 1000,
    after: GraphQLNullable<String>,
    orderProcessDate: GraphQLNullable<GraphQLEnum<SortEnumType>> = .init(.desc)
  ) {
    self.documentIntTypes = documentIntTypes
    self.createdDateFrom = createdDateFrom
    self.createdDateTo = createdDateTo
    self.first = first
    self.after = after
    self.orderProcessDate = orderProcessDate
  }

  public var __variables: Variables? { [
    "documentIntTypes": documentIntTypes,
    "createdDateFrom": createdDateFrom,
    "createdDateTo": createdDateTo,
    "first": first,
    "after": after,
    "orderProcessDate": orderProcessDate
  ] }

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("documents", Documents?.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after"),
        "filter": [
          "documentIntTypes": .variable("documentIntTypes"),
          "createdDateFrom": .variable("createdDateFrom"),
          "createdDateTo": .variable("createdDateTo")
        ],
        "order": ["createdDate": .variable("orderProcessDate")]
      ]),
    ] }

    public var documents: Documents? { __data["documents"] }

    /// Documents
    ///
    /// Parent Type: `DocumentsConnection`
    public struct Documents: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DocumentsConnection }
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

      /// Documents.PageInfo
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

      /// Documents.Node
      ///
      /// Parent Type: `DocumentResponseDto`
      public struct Node: ForthGraphQLApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DocumentResponseDto }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("documentId", Int.self),
          .field("documentTitle", String?.self),
          .field("documentTypeId", Int.self),
          .field("documentTypeName", String?.self),
          .field("documentFileName", String?.self),
          .field("description", String.self),
          .field("createdDate", ForthGraphQLApi.DateTime.self),
          .field("createdBy", Int.self),
          .field("createdByName", String?.self),
        ] }

        public var documentId: Int { __data["documentId"] }
        public var documentTitle: String? { __data["documentTitle"] }
        public var documentTypeId: Int { __data["documentTypeId"] }
        public var documentTypeName: String? { __data["documentTypeName"] }
        public var documentFileName: String? { __data["documentFileName"] }
        public var description: String { __data["description"] }
        public var createdDate: ForthGraphQLApi.DateTime { __data["createdDate"] }
        public var createdBy: Int { __data["createdBy"] }
        public var createdByName: String? { __data["createdByName"] }
      }
    }
  }
}
