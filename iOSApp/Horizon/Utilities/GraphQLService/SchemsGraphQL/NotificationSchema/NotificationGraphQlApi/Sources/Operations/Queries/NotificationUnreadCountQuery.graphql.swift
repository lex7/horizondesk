// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NotificationUnreadCountQuery: GraphQLQuery {
  public static let operationName: String = "NotificationUnreadCountQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query NotificationUnreadCountQuery { mobilePushNotifications { __typename unreadCount } }"#
    ))

  public init() {}

  public struct Data: NotificationGraphQlApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { NotificationGraphQlApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("mobilePushNotifications", MobilePushNotifications?.self),
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
        .field("unreadCount", Int.self),
      ] }

      public var unreadCount: Int { __data["unreadCount"] }
    }
  }
}
