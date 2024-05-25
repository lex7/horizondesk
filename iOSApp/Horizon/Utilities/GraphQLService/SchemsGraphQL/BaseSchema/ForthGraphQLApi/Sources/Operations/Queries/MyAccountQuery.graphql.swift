// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MyAccountQuery: GraphQLQuery {
  public static let operationName: String = "MyAccountQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MyAccountQuery { contact { __typename customerId userId username firstname lastname middlename city address1 state zip email dob phone enrolledDate isPaperStatements } bankAccount { __typename bankName routingNum accountNum } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("contact", Contact?.self),
      .field("bankAccount", BankAccount?.self),
    ] }

    public var contact: Contact? { __data["contact"] }
    public var bankAccount: BankAccount? { __data["bankAccount"] }

    /// Contact
    ///
    /// Parent Type: `ContactResponseDto`
    public struct Contact: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.ContactResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("customerId", String?.self),
        .field("userId", Int?.self),
        .field("username", String?.self),
        .field("firstname", String?.self),
        .field("lastname", String?.self),
        .field("middlename", String?.self),
        .field("city", String?.self),
        .field("address1", String?.self),
        .field("state", String?.self),
        .field("zip", String?.self),
        .field("email", String?.self),
        .field("dob", ForthGraphQLApi.Date?.self),
        .field("phone", String?.self),
        .field("enrolledDate", ForthGraphQLApi.Date?.self),
        .field("isPaperStatements", Bool.self),
      ] }

      public var customerId: String? { __data["customerId"] }
      public var userId: Int? { __data["userId"] }
      public var username: String? { __data["username"] }
      public var firstname: String? { __data["firstname"] }
      public var lastname: String? { __data["lastname"] }
      public var middlename: String? { __data["middlename"] }
      public var city: String? { __data["city"] }
      public var address1: String? { __data["address1"] }
      public var state: String? { __data["state"] }
      public var zip: String? { __data["zip"] }
      public var email: String? { __data["email"] }
      public var dob: ForthGraphQLApi.Date? { __data["dob"] }
      public var phone: String? { __data["phone"] }
      public var enrolledDate: ForthGraphQLApi.Date? { __data["enrolledDate"] }
      public var isPaperStatements: Bool { __data["isPaperStatements"] }
    }

    /// BankAccount
    ///
    /// Parent Type: `BankAccountResponseDto`
    public struct BankAccount: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.BankAccountResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("bankName", String.self),
        .field("routingNum", String.self),
        .field("accountNum", String.self),
      ] }

      public var bankName: String { __data["bankName"] }
      public var routingNum: String { __data["routingNum"] }
      public var accountNum: String { __data["accountNum"] }
    }
  }
}
