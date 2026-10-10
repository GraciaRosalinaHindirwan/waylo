
import 'package:flutter/material.dart';
import 'package:waylo/components/timezoneCard.dart';
import 'package:waylo/dummy/timezoneDummy.dart';
import 'package:waylo/models/timezone.dart';

class TimezoneTest extends StatefulWidget {
  const TimezoneTest({super.key});

  @override
  State<TimezoneTest> createState() => _TimezoneTestState();
}

class _TimezoneTestState extends State<TimezoneTest> {
  late Timezone selectedTimezone;

  @override
  void initState() {
    super.initState();
    selectedTimezone = timezoneDummy[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: TimezoneCard(
            timezones: timezoneDummy,
            selectedTimezone: selectedTimezone,
            onChanged: (timezone) {
              setState(() {
                selectedTimezone = timezone;
              });
            },
          ),
        ),
      ),
    );
  }
}
