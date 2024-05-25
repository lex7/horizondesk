// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DictVarityQuery: GraphQLQuery {
  public static let operationName: String = "DictVarityQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query DictVarityQuery { dictionaries { __typename transactionTypes { __typename stringId name } transactionStatuses { __typename intId name } documentTypes { __typename intId name showInFilter useForCreating } errorTypes { __typename errorCode httpCode defaultMessage rpcStatusCode } } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("dictionaries", Dictionaries.self),
    ] }

    public var dictionaries: Dictionaries { __data["dictionaries"] }

    /// Dictionaries
    ///
    /// Parent Type: `DictionariesQuery`
    public struct Dictionaries: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DictionariesQuery }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("transactionTypes", [TransactionType].self),
        .field("transactionStatuses", [TransactionStatus].self),
        .field("documentTypes", [DocumentType_SelectionSet].self),
        .field("errorTypes", [ErrorType].self),
      ] }

      public var transactionTypes: [TransactionType] { __data["transactionTypes"] }
      public var transactionStatuses: [TransactionStatus] { __data["transactionStatuses"] }
      public var documentTypes: [DocumentType_SelectionSet] { __data["documentTypes"] }
      public var errorTypes: [ErrorType] { __data["errorTypes"] }

      /// Dictionaries.TransactionType
      ///
      /// Parent Type: `DictionaryMember`
      public struct TransactionType: ForthGraphQLApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DictionaryMember }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("stringId", String?.self),
          .field("name", String.self),
        ] }

        public var stringId: String? { __data["stringId"] }
        public var name: String { __data["name"] }
      }

      /// Dictionaries.TransactionStatus
      ///
      /// Parent Type: `DictionaryMember`
      public struct TransactionStatus: ForthGraphQLApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DictionaryMember }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("intId", Int?.self),
          .field("name", String.self),
        ] }

        public var intId: Int? { __data["intId"] }
        public var name: String { __data["name"] }
      }

      /// Dictionaries.DocumentType_SelectionSet
      ///
      /// Parent Type: `DictionaryMember`
      public struct DocumentType_SelectionSet: ForthGraphQLApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.DictionaryMember }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("intId", Int?.self),
          .field("name", String.self),
          .field("showInFilter", Bool.self),
          .field("useForCreating", Bool.self),
        ] }

        public var intId: Int? { __data["intId"] }
        public var name: String { __data["name"] }
        public var showInFilter: Bool { __data["showInFilter"] }
        public var useForCreating: Bool { __data["useForCreating"] }
      }

      /// Dictionaries.ErrorType
      ///
      /// Parent Type: `ExceptionDto`
      public struct ErrorType: ForthGraphQLApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.ExceptionDto }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("errorCode", Int.self),
          .field("httpCode", Int.self),
          .field("defaultMessage", String.self),
          .field("rpcStatusCode", GraphQLEnum<ForthGraphQLApi.StatusCode>.self),
        ] }

        public var errorCode: Int { __data["errorCode"] }
        public var httpCode: Int { __data["httpCode"] }
        public var defaultMessage: String { __data["defaultMessage"] }
        public var rpcStatusCode: GraphQLEnum<ForthGraphQLApi.StatusCode> { __data["rpcStatusCode"] }
      }
    }
  }
}
