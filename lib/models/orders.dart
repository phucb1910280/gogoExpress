class Orders {
  String iD;
  String customerID;
  String deliverID;
  String orderDay;
  String status;
  String totalAmount;
  String transportFee;
  String delayReason;
  String cancelReason;
  String redeliveryDate;

  Orders({
    required this.iD,
    required this.customerID,
    required this.deliverID,
    required this.orderDay,
    required this.status,
    required this.totalAmount,
    required this.transportFee,
    required this.cancelReason,
    required this.delayReason,
    required this.redeliveryDate,
  });
}
