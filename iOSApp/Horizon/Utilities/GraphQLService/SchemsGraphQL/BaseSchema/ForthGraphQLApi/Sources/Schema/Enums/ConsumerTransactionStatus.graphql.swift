// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum ConsumerTransactionStatus: String, EnumType {
  /// Scheduled
  case open = "OPEN"
  /// Pending
  case pending = "PENDING"
  /// Pending For Batch
  case pendingForBatch = "PENDING_FOR_BATCH"
  /// Cancel
  case cancel = "CANCEL"
  /// Cleared
  case cleared = "CLEARED"
  /// Pending For Journal
  case pendingForJournal = "PENDING_FOR_JOURNAL"
  /// Void
  case void = "VOID"
  /// Returned / NSF
  case returnedNsf = "RETURNED_NSF"
  /// Correction
  case correction = "CORRECTION"
  /// Rejected
  case rejected = "REJECTED"
  /// Resubmitted
  case resubmitted = "RESUBMITTED"
  /// Reversed
  case reversed = "REVERSED"
  /// Low Balance
  case lowBalance = "LOW_BALANCE"
  /// Error Processing
  case errorProcessing = "ERROR_PROCESSING"
  /// Shipped
  case shipped = "SHIPPED"
  /// Pending Approval
  case pendingApproval = "PENDING_APPROVAL"
  /// Stop Payment
  case stopPayment = "STOP_PAYMENT"
  /// Authorized
  case authorized = "AUTHORIZED"
  /// On Hold
  case onHold = "ON_HOLD"
  /// Pending Update
  case pendingUpdate = "PENDING_UPDATE"
  /// Delivered
  case delivered = "DELIVERED"
  /// Unauthorized Return
  case unauthReturn = "UNAUTH_RETURN"
  /// Undefined
  case undefined = "UNDEFINED"
}
