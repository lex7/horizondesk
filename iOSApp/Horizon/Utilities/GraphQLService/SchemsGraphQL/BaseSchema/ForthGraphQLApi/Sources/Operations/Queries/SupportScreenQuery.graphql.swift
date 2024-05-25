// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SupportScreenQuery: GraphQLQuery {
  public static let operationName: String = "SupportScreenQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SupportScreenQuery { helpInfo { __typename email phone1 phone2 fax address } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("helpInfo", HelpInfo?.self),
    ] }

    public var helpInfo: HelpInfo? { __data["helpInfo"] }

    /// HelpInfo
    ///
    /// Parent Type: `HelpResponseDto`
    public struct HelpInfo: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.HelpResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("email", String?.self),
        .field("phone1", String?.self),
        .field("phone2", String?.self),
        .field("fax", String?.self),
        .field("address", String?.self),
      ] }

      public var email: String? { __data["email"] }
      public var phone1: String? { __data["phone1"] }
      public var phone2: String? { __data["phone2"] }
      public var fax: String? { __data["fax"] }
      public var address: String? { __data["address"] }
    }
  }
}
