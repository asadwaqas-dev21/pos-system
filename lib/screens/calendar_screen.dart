import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/models/order_model.dart';
import 'package:pos_app/screens/daily_activities_screen.dart';
import 'package:pos_app/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime? _selectedDateForDetails;

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDateForDetails != null) {
      return DailyActivitiesScreen(
        date: _selectedDateForDetails!,
        onBack: () => setState(() => _selectedDateForDetails = null),
      );
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Calendar',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, Box<OrderModel> box, _) {
                // Group sales by day
                final Map<int, double> dailySales = {};
                for (var order in box.values) {
                  if (order.date.year == _currentMonth.year &&
                      order.date.month == _currentMonth.month) {
                    dailySales[order.date.day] =
                        (dailySales[order.date.day] ?? 0) + order.total;
                  }
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Calendar Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 20),
                              onPressed: _previousMonth,
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(_currentMonth),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                      ),
                      // Days of week header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:
                              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                  .map(
                                    (day) => Expanded(
                                      child: Center(
                                        child: Text(
                                          day,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Calendar Grid
                      Expanded(child: _buildCalendarGrid(dailySales, context)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Map<int, double> dailySales, BuildContext context) {
    final int daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final DateTime firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );

    // weekday is 1 for Mon, 7 for Sun
    final int firstWeekdayOffset = firstDayOfMonth.weekday - 1;

    final int totalCells = daysInMonth + firstWeekdayOffset;
    final int rowCount = (totalCells / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: MediaQuery.of(context).size.width > 900 ? 1.5 : 1.0,
      ),
      itemCount: rowCount * 7,
      itemBuilder: (context, index) {
        if (index < firstWeekdayOffset ||
            index >= firstWeekdayOffset + daysInMonth) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }

        final int day = index - firstWeekdayOffset + 1;
        final double sales = dailySales[day] ?? 0.0;
        final DateTime cellDate = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          day,
        );

        final bool isToday =
            cellDate.year == DateTime.now().year &&
            cellDate.month == DateTime.now().month &&
            cellDate.day == DateTime.now().day;

        final theme = Theme.of(context);

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDateForDetails = cellDate;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.primaryColor.withAlpha(20)
                  : theme.scaffoldBackgroundColor,
              border: Border.all(
                color: isToday
                    ? AppTheme.primaryColor
                    : Colors.grey.withAlpha(40),
                width: isToday ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                    color: isToday
                        ? AppTheme.primaryColor
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                if (sales > 0)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'PKR ${sales.toStringAsFixed(sales.truncateToDouble() == sales ? 0 : 2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}
