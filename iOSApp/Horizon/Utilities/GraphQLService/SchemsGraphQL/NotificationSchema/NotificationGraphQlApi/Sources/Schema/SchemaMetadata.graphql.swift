// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == NotificationGraphQlApi.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == NotificationGraphQlApi.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == NotificationGraphQlApi.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == NotificationGraphQlApi.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "query": return NotificationGraphQlApi.Objects.Query
    case "MobilePushNotificationsConnection": return NotificationGraphQlApi.Objects.MobilePushNotificationsConnection
    case "PageInfo": return NotificationGraphQlApi.Objects.PageInfo
    case "MobilePushLogResponseDto": return NotificationGraphQlApi.Objects.MobilePushLogResponseDto
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
