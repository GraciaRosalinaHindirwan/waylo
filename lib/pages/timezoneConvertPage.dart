import 'package:flutter/material.dart';
import 'package:waylo/layouts/subPageLayout.dart';
import 'package:waylo/theme/appColors.dart';

import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/components/timezoneCard.dart';
import 'package:waylo/components/JakartaTimeConvert.dart';

import 'package:waylo/models/timezone.dart';
import 'package:waylo/factories/timezone_repository_factory.dart';
import 'package:waylo/service/timezone_service.dart';


class Timezoneconvertpage extends StatefulWidget {
  const Timezoneconvertpage({
    super.key, 
  });

  @override
  State<Timezoneconvertpage> createState() =>
      _TimezoneconvertpageState();
}

class _TimezoneconvertpageState extends State<Timezoneconvertpage> {
  final repository = TimezoneRepositoryFactory.create();
  late final TimezoneService service; 

  List<Timezone> timezones = [];
  List<Timezone?> selectedTimezones = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    service = TimezoneService(
      timezoneRepository: TimezoneRepositoryFactory.create(),
    );

    loadTimezones();
  }

    Future<void> loadTimezones() async {
    try {
      final availableTimezones =
          await service.getAvailableTimezones();

      final selected =
          service.getDefaultTimezones(availableTimezones);

      if (!mounted) return;

      setState(() {
        timezones = availableTimezones;
        selectedTimezones = selected;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SubPageLayout(
        title: 'Time Convert',
        content: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 40,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Gagal memuat zona waktu',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });
                              loadTimezones();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : !service.hasAvailableTimezones(
                  timezones: timezones, 
                  selectedTimezones: selectedTimezones,
                  )
                    ? const Center(
                        child: Text(
                          'Zona waktu tidak tersedia',
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        children: [
                          const JakartaTimezoneCard(),

                          const SizedBox(height: 24),

                          if (selectedTimezones[0] != null)
                            TimezoneCard(
                              key: const ValueKey('timezone_1'),
                              timezones: timezones,
                              selectedTimezone: selectedTimezones[0]!,
                              onChanged: (timezone) {
                                setState(() {
                                  selectedTimezones[0] = timezone;
                                });
                              },
                            ),

                          const SizedBox(height: 16),

                          if (selectedTimezones[1] != null)
                            TimezoneCard(
                              key: const ValueKey('timezone_2'),
                              timezones: timezones,
                              selectedTimezone: selectedTimezones[1]!,
                              onChanged: (timezone) {
                                setState(() {
                                  selectedTimezones[1] = timezone;
                                });
                              },
                            ),

                          const SizedBox(height: 16),

                          if (selectedTimezones[2] != null)
                            TimezoneCard(
                              key: const ValueKey('timezone_3'),
                              timezones: timezones,
                              selectedTimezone: selectedTimezones[2]!,
                              onChanged: (timezone) {
                                setState(() {
                                  selectedTimezones[2] = timezone;
                                });
                              },
                            ),
                        ],
                      ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => HomePage(user: widget.user,),
                //   ),
                // );
                break;
              case 1:
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => Explorepage(user: widget.user,),
                //   ),
                // );
                break;
              case 2:
                // halaman ini ada di profile 
                break;
            }
          },
        ),
      ),
    );
  }
}