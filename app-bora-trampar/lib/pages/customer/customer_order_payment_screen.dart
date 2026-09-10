import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';

class CustomerOrderPaymentScreen extends StatefulWidget {
  final String appointmentId;

  const CustomerOrderPaymentScreen({super.key, required this.appointmentId});

  @override
  State<CustomerOrderPaymentScreen> createState() =>
      _CustomerOrderPaymentScreenState();
}

class _CustomerOrderPaymentScreenState
    extends State<CustomerOrderPaymentScreen> {
  late HubConnection _connection;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _setupSignalR();
  }

  Future<void> _setupSignalR() async {
    try {
      _connection = HubConnectionBuilder()
          .withUrl('http://192.168.18.72:5067/hubs/appointment')
          .withAutomaticReconnect()
          .build();

      _connection.on('AppointmentUpdated', (arguments) {
        final data = arguments![0] as Map;
        if (data['status'] == 'Accepted' && mounted) {
          setState(() {
            _isConfirmed = true;
          });
        }
      });

      await _connection.start();
      debugPrint('SignalR conectado! Estado: ${_connection.state}');

      await _connection.invoke(
        'JoinAppointmentGroup',
        args: [widget.appointmentId],
      );
    } catch (e) {
      debugPrint('ERRO ao conectar SignalR: $e');
    }
  }

  @override
  void dispose() {
    _connection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Text(
              _isConfirmed
                  ? "Profissional confirmado!"
                  : "Aguardando confirmação...",
            ),
          ],
        ),
      ),
    );
  }
}
