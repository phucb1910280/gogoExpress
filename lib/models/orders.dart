class Orders {
  String iD;
  String customerID;
  String? deliverID;
  String orderDay;
  String status;
  String totalAmount;
  String transportFee;
  String? delayReason;
  String? cancelReason;
  String? redeliveryDate;
  String? deliveredImg;
  String payments;
  String paymentStatus;

  Orders({
    required this.iD,
    required this.customerID,
    this.deliverID,
    required this.orderDay,
    required this.status,
    required this.totalAmount,
    required this.transportFee,
    this.cancelReason,
    this.delayReason,
    this.redeliveryDate,
    this.deliveredImg,
    required this.payments,
    required this.paymentStatus,
  });
}
