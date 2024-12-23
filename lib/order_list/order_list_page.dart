import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_order_tracking/live_tracking/live_tracking_page.dart';
import 'package:live_order_tracking/order_list/order_list_controller.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderListController>(
      init: OrderListController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Order List"),
          ),
          body: ListView.builder(
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Order ID: ${controller.orders[index].id}"),
                subtitle: Text("Customer: ${controller.orders[index].name}"),
                onTap: () {
                  Get.to(const LiveTrackingPage(),
                      arguments: {'order': controller.orders[index]});
                },
              );
            },
          ),
        );
      },
    );
  }
}
