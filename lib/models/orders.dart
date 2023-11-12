class Orders {
  String orderID;
  String supplierID;
  String customerID;
  String? shipperID;
  String? pickupStaffID;

  String orderDay;

  String status;

  String payments;
  String paymentStatus;

  num orderTotal;
  num transportFee;
  num total;

  String? delayPickupReason;
  String? rePickupDay;
  String? pickupImg;

  String? cancelReason;

  String? delayDeliveryReason;
  String? reDeliveryDay;
  String? suscessfullDeliveryImg;
  String? suscessfullDeliveryDay;

  bool isNewOrder;
  List<String> deliveryHistory;

  Orders({
    required this.orderID,
    required this.supplierID,
    required this.customerID,
    required this.orderDay,
    required this.status,
    required this.payments,
    required this.paymentStatus,
    required this.orderTotal,
    required this.transportFee,
    required this.total,
    required this.deliveryHistory,
    required this.isNewOrder,
  });

  Map<String, Object?> toJson() {
    return {
      'orderID': orderID,
      'customerID': customerID,
      'supplierID': supplierID,
      'shipperID': "",
      'pickupStaffID': "",
      'orderDay': orderDay,
      'status': status,
      'payments': payments,
      'paymentStatus': paymentStatus,
      'orderTotal': orderTotal,
      'transportFee': transportFee,
      'total': total,
      'delayPickupReason': "",
      'rePickupDay': "",
      'pickupImg': "",
      'cancelReason': "",
      'delayDeliveryReason': "",
      'reDeliveryDay': "",
      'suscessfullDeliveryDay': "",
      'suscessfullDeliveryImg': "",
      'deliveryHistory': deliveryHistory,
      'isNewOrder': isNewOrder,
    };
  }
}
