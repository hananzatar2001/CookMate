import 'package:flutter/material.dart';
import '../constants.dart';

const Color selectionColor = Color(0xFF9575CD);
const Color headerTextColor = Colors.black;

class TableCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime currentDay;
  final bool Function(DateTime)? selectedDayPredicate;
  final void Function(DateTime, DateTime)? onDaySelected;
  final bool headerVisible;
  final CalendarFormat calendarFormat;
  final DaysOfWeekStyle daysOfWeekStyle;
  final CalendarStyle calendarStyle;
  final double rowHeight;

  const TableCalendar({
    super.key,
    required this.focusedDay,
    required this.firstDay,
    required this.lastDay,
    required this.currentDay,
    this.selectedDayPredicate,
    this.onDaySelected,
    this.headerVisible = true,
    this.calendarFormat = CalendarFormat.month,
    this.daysOfWeekStyle = const DaysOfWeekStyle(),
    this.calendarStyle = const CalendarStyle(),
    this.rowHeight = 30.0,
  });

  @override
  State<TableCalendar> createState() => _TableCalendarState();
}

class _TableCalendarState extends State<TableCalendar> {
  late DateTime _focusedDay;
  late Map<int, int> _daysInMonth;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _daysInMonth = _calculateDaysInMonths();
  }

  @override
  void didUpdateWidget(TableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.focusedDay, widget.focusedDay)) {
      _focusedDay = widget.focusedDay;
    }
  }

  Map<int, int> _calculateDaysInMonths() {
    Map<int, int> daysInMonth = {};
    final year = DateTime.now().year;

    for (int month = 1; month <= 12; month++) {
      final lastDay = DateTime(year, month + 1, 0);
      daysInMonth[month] = lastDay.day;
    }

    return daysInMonth;
  }

  void _onLeftArrowTap() {
    setState(() {
      if (_focusedDay.month == 1) {
        _focusedDay = DateTime(_focusedDay.year - 1, 12, 1);
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      }
    });
  }

  void _onRightArrowTap() {
    setState(() {
      if (_focusedDay.month == 12) {
        _focusedDay = DateTime(_focusedDay.year + 1, 1, 1);
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      }
    });
  }

  String _getMonthYearText(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _onLeftArrowTap,
          ),
          Expanded(
            child: Text(
              _getMonthYearText(_focusedDay),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: headerTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _onRightArrowTap,
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final List<String> daysOfWeek = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            daysOfWeek
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: widget.daysOfWeekStyle.weekdayStyle,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);

    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    print('Month: ${_focusedDay.month}, Days: ${lastDayOfMonth.day}');

    final firstDayOfCalendar = _getFirstDayOfCalendar(firstDayOfMonth);

    final lastDayOfCalendar = _getLastDayOfCalendar(lastDayOfMonth);

    final List<TableRow> rows = [];
    List<Widget> currentRow = [];
    DateTime day = firstDayOfCalendar;

    while (day.isBefore(lastDayOfCalendar.add(const Duration(days: 1)))) {
      if (currentRow.length == 7) {
        rows.add(TableRow(children: currentRow));
        currentRow = [];
      }

      bool isSelected = widget.selectedDayPredicate?.call(day) ?? false;
      bool isToday = _isSameDay(day, widget.currentDay);
      bool isCurrentMonth = _isSameMonth(day, _focusedDay);

      BoxDecoration? decoration;
      TextStyle? textStyle;

      if (isSelected) {
        decoration = widget.calendarStyle.selectedDecoration;
        textStyle = widget.calendarStyle.selectedTextStyle;
      } else if (isToday) {
        decoration = widget.calendarStyle.todayDecoration;
        textStyle = widget.calendarStyle.todayTextStyle;
      } else {
        textStyle =
            isCurrentMonth
                ? widget.calendarStyle.defaultTextStyle
                : TextStyle(color: Colors.grey.withValues(alpha: 0.5));
      }

      final DateTime tempDay = day;

      currentRow.add(
        TableCell(
          child: GestureDetector(
            onTap: () {
              if (widget.onDaySelected != null) {
                widget.onDaySelected!(tempDay, tempDay);
              }
            },
            child: Container(
              height: widget.rowHeight,
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 40,
                decoration: decoration,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${tempDay.day}', style: textStyle),
                    if (isSelected)
                      Container(
                        height: 2,
                        width: 20,
                        margin: const EdgeInsets.only(top: 2),
                        color: widget.calendarStyle.selectedUnderlineColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      day = day.add(const Duration(days: 1));
    }

    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const TableCell(child: SizedBox()));
      }
      rows.add(TableRow(children: currentRow));
    }

    return Table(children: rows);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  DateTime _getFirstDayOfCalendar(DateTime firstDayOfMonth) {
    final weekday = firstDayOfMonth.weekday;

    final daysBefore = weekday == 1 ? 0 : weekday - 1;
    return firstDayOfMonth.subtract(Duration(days: daysBefore));
  }

  DateTime _getLastDayOfCalendar(DateTime lastDayOfMonth) {
    final weekday = lastDayOfMonth.weekday;

    final daysAfter = weekday == 7 ? 0 : 7 - weekday;
    return lastDayOfMonth.add(Duration(days: daysAfter));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.headerVisible) _buildHeader(),
        _buildDaysOfWeek(),
        _buildCalendarDays(),
      ],
    );
  }
}

class CalendarStyle {
  final BoxDecoration? todayDecoration;
  final TextStyle? todayTextStyle;
  final BoxDecoration? selectedDecoration;
  final TextStyle? selectedTextStyle;
  final TextStyle? defaultTextStyle;
  final TextStyle? weekendTextStyle;
  final Color selectedUnderlineColor;

  const CalendarStyle({
    this.todayDecoration = const BoxDecoration(color: Colors.transparent),
    this.todayTextStyle = const TextStyle(
      color: textColor,
      fontWeight: FontWeight.bold,
    ),
    this.selectedDecoration = const BoxDecoration(
      color: selectionColor,
      shape: BoxShape.rectangle,
    ),
    this.selectedTextStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.normal,
    ),
    this.defaultTextStyle = const TextStyle(color: textColor),
    this.weekendTextStyle = const TextStyle(color: textColor),
    this.selectedUnderlineColor = Colors.white,
  });
}

class DaysOfWeekStyle {
  final TextStyle? weekdayStyle;
  final TextStyle? weekendStyle;

  const DaysOfWeekStyle({
    this.weekdayStyle = const TextStyle(
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
    this.weekendStyle = const TextStyle(
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
  });
}
