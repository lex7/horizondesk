// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NotificationQuery: GraphQLQuery {
  public static let operationName: String = "NotificationQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query NotificationQuery($first: Int = 10, $after: String) { mobilePushNotifications(first: $first, after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename id createdAt isRead actionType title body } totalCount } }"#
    ))

  public var first: GraphQLNullable<Int>
  public var after: GraphQLNullable<String>

  public init(
    first: GraphQLNullable<Int> = 10,
    after: GraphQLNullable<String>
  ) {
    self.first = first
    self.after = after
  }

  public var __variables: Variables? { [
    "first": first,
    "after": after
  ] }

  public struct Data: NotificationGraphQlApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { NotificationGraphQlApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("mobilePushNotifications", MobilePushNotifications?.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after")
      ]),
    ] }

    public var mobilePushNotifications: MobilePushNotifications? { __data["mobilePushNotifications"] }

    /// MobilePushNotifications
    ///
    /// Parent Type: `MobilePushNotificationsConnection`
    public struct MobilePushNotifications: NotificationGraphQlApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { NotificationGraphQlApi.Objects.MobilePushNotificationsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node]?.self),
        .field("totalCount", Int.self),
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A flattened list of the nodes.
      public var nodes: [Node]? { __data["nodes"] }
      /// Identifies the total count of items in the connection.
      public var totalCount: Int { __data["totalCount"] }

      /// MobilePushNotifications.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: NotificationGraphQlApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { NotificationGraphQlApi.Objects.PageInfo }
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

      /// MobilePushNotifications.Node
      ///
      /// Parent Type: `MobilePushLogResponseDto`
      public struct Node: NotificationGraphQlApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { NotificationGraphQlApi.Objects.MobilePushLogResponseDto }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", String.self),
          .field("createdAt", NotificationGraphQlApi.DateTime.self),
          .field("isRead", Bool.self),
          .field("actionType", Int.self),
          .field("title", String.self),
          .field("body", String.self),
        ] }

        public var id: String { __data["id"] }
        public var createdAt: NotificationGraphQlApi.DateTime { __data["createdAt"] }
        public var isRead: Bool { __data["isRead"] }
        public var actionType: Int { __data["actionType"] }
        public var title: String { __data["title"] }
        public var body: String { __data["body"] }
      }
    }
  }
}
