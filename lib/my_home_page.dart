import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_order_tracking/add_order/add_order_page.dart';
import 'package:live_order_tracking/delivery_boy/delivery_boy_page.dart';
import 'package:live_order_tracking/order_list/order_list_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(const OrderListPage());
              },
              icon: const Icon(Icons.list)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(const AddOrderPage());
              },
              child: const Text("Client App"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.to(const DeliveryBoyPage());
              },
              child: const Text("Delivery Boy App"),
            ),
          ],
        ),
      ),
    );
  }
}
