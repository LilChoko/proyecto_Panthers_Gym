import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
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

    Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var sale in sales) {
      final date = DateTime.parse(sale['date']);
      final day = DateTime.utc(date.year, date.month, date.day);

      if (events[day] == null) {
        events[day] = [];
      }

      events[day]!.add({
        'id': sale['id'],
        'status': sale['status'],
        'title': 'Venta ${sale['id']}',
        'total': sale['total'],
      });
    }

    setState(() {
      _events = events;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
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

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
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
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return SizedBox();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(3).map((event) {
                    if (event is Map<String, dynamic> &&
                        event['status'] != null) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getDotColor(event['status']!),
                          shape: BoxShape.circle,
                        ),
                      );
                    }
                    return SizedBox(); // Si el evento no tiene la clave 'status', retorna un espacio vacío
                  }).toList(),
                );
              },
            ),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              showSalesModal(
                context,
                _getEventsForDay(selectedDay),
                _loadSalesFromDatabase,
              );
            },
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          ),
          Expanded(
            child: _getEventsForDay(_selectedDay).isEmpty
                ? Center(child: Text('No hay eventos para este día.'))
                : ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: _getEventsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(_selectedDay)[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getDotColor(event['status']),
                            child: Icon(
                              Icons.event,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            event['title'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Total: \$${event['total'].toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            _formatDate(_selectedDay),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
