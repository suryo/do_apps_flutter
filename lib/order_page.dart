import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Future<List<dynamic>?> _fetchOrders() async {
    final response = await http.get(Uri.parse(
        'http://testdo.zonainformatika.com/public/api/deliveryorders'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  void _updateStatus(int orderId, String status, {String? reason}) async {
    Map<String, String> body = {};
    if (reason != null) {
      body['reason_status'] = reason;
    }
    final response = await http.post(
      Uri.parse(
          'http://testdo.zonainformatika.com/api/deliveryorders/$orderId/$status'),
      body: body,
    );
    if (response.statusCode == 200) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Status updated successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update status'),
      ));
    }
  }

  Future<void> _showRejectDialog(int orderId) async {
    String reason = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reject Order'),
          content: TextField(
            onChanged: (value) {
              reason = value;
            },
            decoration: InputDecoration(labelText: 'Reason for rejection'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateStatus(orderId, 'reject', reason: reason);
                Navigator.of(context).pop();
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRevisiDialog(int orderId) async {
    String reason = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Revisi Order'),
          content: TextField(
            onChanged: (value) {
              reason = value;
            },
            decoration: InputDecoration(labelText: 'Reason for revision'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateStatus(orderId, 'revisi', reason: reason);
                Navigator.of(context).pop();
              },
              child: Text('Revisi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: _fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: Failed to load orders'));
        } else {
          List<dynamic> orders = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var total = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                    .format(double.parse(order['ordertotal']));
                Color statusColor = Colors.black;
                if (order['status'] == 'approve') {
                  statusColor = Colors.green;
                } else if (order['status'] == 'reject') {
                  statusColor = Colors.red;
                } else if (order['status'] == 'revisi') {
                  statusColor = Color.fromARGB(255, 155, 78, 6);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Order: ${order['nomerorder']}',
                        style: TextStyle(color: statusColor),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: $total'),
                          Text(
                            'Status: ${order['status']}',
                            style: TextStyle(color: statusColor),
                          ),
                          Text('Add Catatan: ${order['addcatatan'] ?? "-"}'),
                        ],
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _updateStatus(order['id'], 'approve');
                          },
                          child: Text('Approve'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showRejectDialog(order['id']);
                          },
                          child: Text('Reject'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showRevisiDialog(order['id']);
                          },
                          child: Text('Revisi'),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}