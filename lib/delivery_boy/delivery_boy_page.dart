import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_order_tracking/delivery_boy/delivery_boy_controller.dart';

class DeliveryBoyPage extends StatefulWidget {
  const DeliveryBoyPage({super.key});

  @override
  State<DeliveryBoyPage> createState() => _DeliveryBoyPageState();
}

class _DeliveryBoyPageState extends State<DeliveryBoyPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryBoyController>(
      init: DeliveryBoyController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Delivery Boy App"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView(
              children: [
                const Icon(
                  Icons.delivery_dining,
                  size: 200,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),
                const Text("Enter Order ID"),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.orderIdController,
                  decoration: const InputDecoration(
                    labelText: "Order ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: !controller.showDeliveryInfo,
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      controller.getOrderById();
                    },
                    child: const Text("Submit"),
                  ),
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: controller.showDeliveryInfo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Delivery Address: ${controller.deliveryAddress}"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Phone number: ${controller.phoneNumber}"),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.phone),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          "Amount to collect: \$ ${controller.amountToCollect}"),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.location_on),
                            label: const Text("show location"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.startDelivery();
                            },
                            child: const Text("Start delivery"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
