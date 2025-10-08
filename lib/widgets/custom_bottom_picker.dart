import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Custom Bottom Picker Widget
/// Replicates the functionality of bottom_picker package
class CustomBottomPicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;
  final Function(DateTime)? onSubmit;
  final Function(DateTime)? onChange;
  final Color backgroundColor;
  final Color buttonColor;
  final String? title;
  final Widget Function(BuildContext)? headerBuilder;
  final bool displaySubmitButton;
  final bool use24hFormat;
  final int minuteInterval;
  final CustomBottomPickerType type;
  final CustomTime? initialTime;
  final CustomTime? minTime;
  final CustomTime? maxTime;

  const CustomBottomPicker({
    super.key,
    this.initialDateTime,
    this.minDateTime,
    this.maxDateTime,
    this.onSubmit,
    this.onChange,
    this.backgroundColor = Colors.white,
    this.buttonColor = Colors.blue,
    this.title,
    this.headerBuilder,
    this.displaySubmitButton = true,
    this.use24hFormat = false,
    this.minuteInterval = 1,
    this.type = CustomBottomPickerType.date,
    this.initialTime,
    this.minTime,
    this.maxTime,
  });

  /// Creates a date picker
  static CustomBottomPicker date({
    DateTime? initialDateTime,
    DateTime? minDateTime,
    DateTime? maxDateTime,
    Function(DateTime)? onSubmit,
    Function(DateTime)? onChange,
    Color backgroundColor = Colors.white,
    Color buttonSingleColor = Colors.blue,
    Widget Function(BuildContext)? headerBuilder,
    bool displaySubmitButton = true,
  }) {
    return CustomBottomPicker(
      type: CustomBottomPickerType.date,
      initialDateTime: initialDateTime,
      minDateTime: minDateTime,
      maxDateTime: maxDateTime,
      onSubmit: onSubmit,
      onChange: onChange,
      backgroundColor: backgroundColor,
      buttonColor: buttonSingleColor,
      headerBuilder: headerBuilder,
      displaySubmitButton: displaySubmitButton,
    );
  }

  /// Creates a time picker
  static CustomBottomPicker time({
    required CustomTime initialTime,
    CustomTime? minTime,
    CustomTime? maxTime,
    Function(DateTime)? onSubmit,
    Function(DateTime)? onChange,
    Color backgroundColor = Colors.white,
    Color buttonSingleColor = Colors.blue,
    Widget Function(BuildContext)? headerBuilder,
    bool displaySubmitButton = true,
    bool use24hFormat = false,
    int minuteInterval = 1,
  }) {
    return CustomBottomPicker(
      type: CustomBottomPickerType.time,
      initialTime: initialTime,
      minTime: minTime,
      maxTime: maxTime,
      onSubmit: onSubmit,
      onChange: onChange,
      backgroundColor: backgroundColor,
      buttonColor: buttonSingleColor,
      headerBuilder: headerBuilder,
      displaySubmitButton: displaySubmitButton,
      use24hFormat: use24hFormat,
      minuteInterval: minuteInterval,
    );
  }

  /// Shows the picker as a modal bottom sheet
  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (context) => this,
    );
  }

  @override
  State<CustomBottomPicker> createState() => _CustomBottomPickerState();
}

class _CustomBottomPickerState extends State<CustomBottomPicker> {
  late DateTime selectedDateTime;
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController amPmController;

  @override
  void initState() {
    super.initState();
    
    if (widget.type == CustomBottomPickerType.date) {
      selectedDateTime = widget.initialDateTime ?? DateTime.now();
    } else {
      // For time picker, use today's date with the specified time
      final time = widget.initialTime ?? CustomTime.now();
      selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hours,
        time.minutes,
      );
    }
    
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.type == CustomBottomPickerType.date) {
      dayController = FixedExtentScrollController(initialItem: selectedDateTime.day - 1);
      monthController = FixedExtentScrollController(initialItem: selectedDateTime.month - 1);
      final startYear = widget.minDateTime?.year ?? DateTime.now().year - 100;
      yearController = FixedExtentScrollController(
        initialItem: selectedDateTime.year - startYear,
      );
    } else {
      // For time picker
      final displayHour = widget.use24hFormat 
          ? selectedDateTime.hour
          : (selectedDateTime.hour == 0 ? 12 : selectedDateTime.hour > 12 ? selectedDateTime.hour - 12 : selectedDateTime.hour);
      
      hourController = FixedExtentScrollController(
        initialItem: widget.use24hFormat ? selectedDateTime.hour : displayHour - 1,
      );
      
      minuteController = FixedExtentScrollController(
        initialItem: selectedDateTime.minute ~/ widget.minuteInterval,
      );
      
      if (!widget.use24hFormat) {
        amPmController = FixedExtentScrollController(
          initialItem: selectedDateTime.hour >= 12 ? 1 : 0,
        );
      }
    }
  }

  @override
  void dispose() {
    if (widget.type == CustomBottomPickerType.date) {
      dayController.dispose();
      monthController.dispose();
      yearController.dispose();
    } else {
      hourController.dispose();
      minuteController.dispose();
      if (!widget.use24hFormat) {
        amPmController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            if (widget.headerBuilder != null)
              widget.headerBuilder!(context)
            else
              _buildDefaultHeader(),
            
            // Picker Content
            Container(
              height: 250,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: widget.type == CustomBottomPickerType.date
                  ? _buildDatePicker()
                  : _buildTimePicker(),
            ),
            
            // Submit Button
            if (widget.displaySubmitButton)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal:16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSubmit?.call(selectedDateTime);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Seç',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.buttonColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title ?? (widget.type == CustomBottomPickerType.date ? 'Tarih Seçin' : 'Saat Seçin'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        // Day
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  'Gün',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: dayController,
                  itemExtent: 40,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: widget.buttonColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    _updateSelectedDate(day: index + 1);
                  },
                  children: List.generate(31, (index) {
                    return Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        
        // Month
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  'Ay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: monthController,
                  itemExtent: 40,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: widget.buttonColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    _updateSelectedDate(month: index + 1);
                  },
                  children: List.generate(12, (index) {
                    final monthNames = [
                      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
                    ];
                    return Center(
                      child: Text(
                        monthNames[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        
        // Year
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  'Yıl',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: yearController,
                  itemExtent: 40,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: widget.buttonColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    final startYear = widget.minDateTime?.year ?? DateTime.now().year - 100;
                    _updateSelectedDate(year: startYear + index);
                  },
                  children: List.generate(200, (index) {
                    final startYear = widget.minDateTime?.year ?? DateTime.now().year - 100;
                    final year = startYear + index;
                    return Center(
                      child: Text(
                        '$year',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    final List<Widget> children = [];
    
    // Hour
    children.add(
      Expanded(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(0.0),
              child: Text(
                'Saat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: hourController,
                itemExtent: 40,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: widget.buttonColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  if (widget.use24hFormat) {
                    _updateSelectedTime(hour: index);
                  } else {
                    final currentAmPm = selectedDateTime.hour >= 12 ? 1 : 0;
                    final hour24 = currentAmPm == 0 
                        ? (index + 1 == 12 ? 0 : index + 1)
                        : (index + 1 == 12 ? 12 : index + 1 + 12);
                    _updateSelectedTime(hour: hour24);
                  }
                },
                children: List.generate(widget.use24hFormat ? 24 : 12, (index) {
                  final displayHour = widget.use24hFormat 
                      ? index 
                      : index + 1;
                  return Center(
                    child: Text(
                      displayHour.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
    
    // Separator
    children.add(
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
    
    // Minute
    children.add(
      Expanded(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(0),
              child: Text(
                'Dakika',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: minuteController,
                itemExtent: 40,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: widget.buttonColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  _updateSelectedTime(minute: index * widget.minuteInterval);
                },
                children: List.generate(60 ~/ widget.minuteInterval, (index) {
                  final minute = index * widget.minuteInterval;
                  return Center(
                    child: Text(
                      minute.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
    
    // AM/PM for 12-hour format
    if (!widget.use24hFormat) {
      children.add(
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: amPmController,
                  itemExtent: 40,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: widget.buttonColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    final currentHour12 = selectedDateTime.hour % 12;
                    final newHour = index == 0 ? currentHour12 : currentHour12 + 12;
                    _updateSelectedTime(hour: newHour);
                  },
                  children: const [
                    Center(child: Text('AM', style: TextStyle(fontSize: 18))),
                    Center(child: Text('PM', style: TextStyle(fontSize: 18))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(children: children);
  }

  void _updateSelectedDate({int? day, int? month, int? year}) {
    try {
      final newDateTime = DateTime(
        year ?? selectedDateTime.year,
        month ?? selectedDateTime.month,
        day ?? selectedDateTime.day,
        selectedDateTime.hour,
        selectedDateTime.minute,
      );
      
      if (_isValidDate(newDateTime)) {
        setState(() {
          selectedDateTime = newDateTime;
        });
        widget.onChange?.call(selectedDateTime);
      }
    } catch (e) {
      // Invalid date, ignore
    }
  }

  void _updateSelectedTime({int? hour, int? minute}) {
    final newDateTime = DateTime(
      selectedDateTime.year,
      selectedDateTime.month,
      selectedDateTime.day,
      hour ?? selectedDateTime.hour,
      minute ?? selectedDateTime.minute,
    );
    
    if (_isValidTime(newDateTime)) {
      setState(() {
        selectedDateTime = newDateTime;
      });
      widget.onChange?.call(selectedDateTime);
    }
  }

  bool _isValidDate(DateTime date) {
    if (widget.minDateTime != null && date.isBefore(widget.minDateTime!)) {
      return false;
    }
    if (widget.maxDateTime != null && date.isAfter(widget.maxDateTime!)) {
      return false;
    }
    return true;
  }

  bool _isValidTime(DateTime time) {
    if (widget.minTime != null) {
      final minDateTime = DateTime(
        time.year, time.month, time.day,
        widget.minTime!.hours, widget.minTime!.minutes,
      );
      if (time.isBefore(minDateTime)) return false;
    }
    if (widget.maxTime != null) {
      final maxDateTime = DateTime(
        time.year, time.month, time.day,
        widget.maxTime!.hours, widget.maxTime!.minutes,
      );
      if (time.isAfter(maxDateTime)) return false;
    }
    return true;
  }
}

/// Custom Time class to match the bottom_picker Time class
class CustomTime {
  final int hours;
  final int minutes;

  const CustomTime({
    required this.hours,
    required this.minutes,
  });

  static CustomTime now() {
    final now = DateTime.now();
    return CustomTime(hours: now.hour, minutes: now.minute);
  }

  DateTime get toDateTime {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hours, minutes);
  }
}

/// Enum for picker types
enum CustomBottomPickerType {
  date,
  time,
}