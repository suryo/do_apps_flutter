import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderApprovedPage extends StatefulWidget {
  @override
  _OrderApprovedPageState createState() => _OrderApprovedPageState();
}

class _OrderApprovedPageState extends State<OrderApprovedPage> {
  Future<List<dynamic>?> _fetchApprovedOrders() async {
    final response = await http.get(
        Uri.parse('http://testdo.zonainformatika.com/api/deliveryorders?status=approve'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load approved orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: _fetchApprovedOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: Failed to load approved orders'));
        } else {
          List<dynamic> orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var total = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                  .format(double.parse(order['ordertotal']));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Order: ${order['nomerorder']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total: $total'),
                        Text('Status: ${order['status']}'),
                        Text('Add Catatan: ${order['addcatatan'] ?? "-"}'),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              );
            },
          );
        }
      },
    );
  }
}