import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/sales_modal.dart';
import '../database/db_helper.dart';

class PendingSalesScreen extends StatefulWidget {
  @override
  _PendingSalesScreenState createState() => _PendingSalesScreenState();
}

class _PendingSalesScreenState extends State<PendingSalesScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> _events = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSalesFromDatabase();
  }

  Future<void> _loadSalesFromDatabase() async {
    final sales = await DBHelper.fetchSales();
    print('Ventas obtenidas de la base de datos: $sales'); // Depuración inicial

    Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var sale in sales) {
      final date = DateTime.parse(sale['date']);
      final day = DateTime.utc(
          date.year, date.month, date.day); // Normalizar fecha a UTC

      if (events[day] == null) {
        events[day] = [];
      }

      events[day]!.add({
        'id': sale['id'], // ID necesario para actualizar estado
        'status': sale['status'],
        'title': 'Venta ${sale['id']}',
        'total': sale['total'],
      });
    }

    setState(() {
      _events = events;
      print('Eventos agrupados por fecha: $_events'); // Confirmar agrupación
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay =
        DateTime.utc(day.year, day.month, day.day); // Normalizar fecha a UTC
    return _events[normalizedDay] ?? [];
  }

  Color _getDotColor(String status) {
    switch (status) {
      case 'por cumplir':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'completada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSalesFromDatabase,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2050),
            eventLoader: (day) {
              final events = _getEventsForDay(day);
              print('Eventos para el día $day: $events'); // Depuración
              return events;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              showSalesModal(
                context,
                _getEventsForDay(selectedDay),
                _loadSalesFromDatabase, // Callback para recargar los datos
              );
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return SizedBox();

                // Limitar los eventos a mostrar
                final maxMarkers = 3;
                final displayEvents = events.take(maxMarkers).toList();
                final remainingCount = events.length - displayEvents.length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...displayEvents.map((event) {
                      if (event is Map<String, dynamic> &&
                          event['status'] != null) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getDotColor(event['status'] as String),
                            shape: BoxShape.circle,
                          ),
                        );
                      }
                      return SizedBox();
                    }).toList(),
                    if (remainingCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          '+$remainingCount',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
