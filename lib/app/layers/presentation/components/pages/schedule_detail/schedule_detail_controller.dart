import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:jejuya/app/core_impl/di/injector_impl.dart';
import 'package:jejuya/app/layers/data/sources/local/model/destination/destination_detail.dart';
import 'package:jejuya/app/layers/data/sources/local/model/language/language_supported.dart';
import 'package:jejuya/app/layers/data/sources/local/model/schedule/schedule.dart';
import 'package:jejuya/app/layers/data/sources/local/model/schedule/schedule_item.dart';
import 'package:jejuya/app/layers/domain/usecases/destination/destination_detail_usecase.dart';
import 'package:jejuya/app/layers/presentation/components/pages/schedule_detail/mockup/schedule.dart'
    as scheduleMockup;
import 'package:jejuya/app/layers/presentation/components/pages/schedule_detail/mockup/schedule_mockup_api.dart '
    as scheduleMockupApi;
import 'package:jejuya/app/layers/presentation/global_controllers/setting/setting_controller.dart';
import 'package:jejuya/app/layers/presentation/nav_predefined.dart';
import 'package:jejuya/core/arch/domain/usecase/usecase_provider.dart';
import 'package:jejuya/core/arch/presentation/controller/base_controller.dart';
import 'package:jejuya/core/arch/presentation/controller/controller_provider.dart';
import 'package:jejuya/core/reactive/dynamic_to_obs_data.dart';

/// Controller for the Schedule detail page
class ScheduleDetailController extends BaseController
    with UseCaseProvider, GlobalControllerProvider {
  /// Default constructor for the ScheduleDetailController.
  ScheduleDetailController({required this.schedule}) {
    scheduleItemsByDate = groupScheduleItemsByDate();

    _fetchData();
    initialize();
  }

  // --- Member Variables ---

  late List<scheduleMockup.Schedule> schedules;
  late Map<String, List<ScheduleItem>> scheduleItemsByDate;
  final Schedule? schedule;
  // --- State Variables ---
  final selectedDayIndex = listenable<int>(0);

  final selectedDestinationIndex = listenable<int>(0);

  bool _isLoadingPage = false;
  int _page = 1;
  ScrollController scrollController = ScrollController();
  List<DestinationDetail?> destinationDetails =
      listenableList<DestinationDetail?>([]);

  late final _fetchDestinationDetail = usecase<DestinationDetailUseCase>();
  // --- State Computed ---
  // --- Usecases ---
  // --- Computed Variables ---

  // --- Methods ---

  @override
  Future<void> initialize() async {
    super.initialize();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  void _fetchData() async {
    List<ScheduleItem> newItems = scheduleItemsByDate.values
        .elementAt(selectedDayIndex.value)!
        .skip(destinationDetails.length)
        .take(3)
        .toList();

    List<DestinationDetail?> temp = [];
    for (var item in newItems) {
      temp.add(await fetchDestinationDetail(item.id));
    }

    destinationDetails.addAll(temp);
  }

  Future<DestinationDetail?> fetchDestinationDetail(
      String? destinationId) async {
    try {
      if (destinationId == null) return null;
      DestinationDetail destinationDetail = await _fetchDestinationDetail
          .execute(
            DestinationDetailRequest(destinationId: destinationId),
          )
          .then((response) => response.destinationDetail);

      return destinationDetail;
    } catch (e, s) {
      log.error(
        '[DestinationDetailController] Failed to fetch detail:',
        error: e,
        stackTrace: s,
      );
      nav.showSnackBar(error: e);
    }
  }

  Map<String, List<ScheduleItem>> groupScheduleItemsByDate() {
    final Map<String, List<ScheduleItem>> groupedData = {};
    for (var entry in schedule!.scheduleItems!) {
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(entry.startTime!);

      // DateTime dateTime = DateTime.parse(formattedDate);
      if (!groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate] = [];
      }
      groupedData[formattedDate]!.add(entry);
    }
    return groupedData;
  }

  void updateSelectedDay(int index) {
    selectedDayIndex.value = index;
    print(
        "count: ${scheduleItemsByDate.values.elementAt(selectedDayIndex.value)!.length}");
    destinationDetails.clear();
    _fetchData();
  }

  Map<String, String> formatDate(String dateString) {
    final settingCtrl = globalController<SettingController>();

    var parts = dateString.split('/');

    if (parts.length != 3) {
      throw const FormatException("Invalid date format");
    }

    String formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
    DateTime dateTime = DateTime.parse(formattedDate);

    String dayOfWeek = _getWeekDayName(dateTime.weekday);
    String day = dateTime.day.toString();
    String monthAb = '';
    List<String> englishMonthAbbreviations = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    if (settingCtrl.language.value == LanguageSupported.korean) {
      monthAb = "${dateTime.month}월";
    }
    if (settingCtrl.language.value == LanguageSupported.vietnamese) {
      monthAb = "Th${dateTime.month}";
    }
    if (settingCtrl.language.value == LanguageSupported.english) {
      monthAb = englishMonthAbbreviations[dateTime.month - 1];
    }
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();

    return {
      'dayOfWeek': dayOfWeek,
      'day': day,
      'monthAb': monthAb,
      'month': month,
      'year': year,
    };
  }

  String _getWeekDayName(int weekday) {
    final settingCtrl = globalController<SettingController>();
    switch (weekday) {
      case 1:
        String day = '';
        if (settingCtrl.language.value == LanguageSupported.korean) {
          day = "월";
        }
        if (settingCtrl.language.value == LanguageSupported.vietnamese) {
          day = "T2";
        }
        if (settingCtrl.language.value == LanguageSupported.english) {
          day = "Mon";
        }
        return day;
      case 2:
        String day = '';
        if (settingCtrl.language.value == LanguageSupported.korean) {
          day = "화";
        }
        if (settingCtrl.language.value == LanguageSupported.vietnamese) {
          day = "T3";
        }
        if (settingCtrl.language.value == LanguageSupported.english) {
          day = "Tue";
        }
        return day;
      case 3:
        String day = '';
        if (settingCtrl.language.value == LanguageSupported.korean) {
          day = "수";
        }
        if (settingCtrl.language.value == LanguageSupported.vietnamese) {
          day = "T4";
        }
        if (settingCtrl.language.value == LanguageSupported.english) {
          day = "Wed";
        }
        return day;
      case 4:
        String day = '';
        if (settingCtrl.language.value == LanguageSupported.korean) {
          day = "목";
        }
        if (settingCtrl.language.value == LanguageSupported.vietnamese) {
          day = "T5";
        }
        if (settingCtrl.language.value == LanguageSupported.english) {
          day = "Thu";
        }
        return day;
      case 5:
        String day = '';
        if (settingCtrl.language.value == LanguageSupported.korean) {
          day = "금";
        }
        if (settingCtrl.language.value == LanguageSupported.vietnamese) {
          day = "T6";
        }
        if (settingCtrl.language.value == LanguageSupported.english) {
          day = "Fri";
        }
        return day;
      case 6:
        String day = '';
        if (settingCtrl.language.value == LanguageSupported.korean) {
          day = "토";
        }
        if (settingCtrl.language.value == LanguageSupported.vietnamese) {
          day = "T7";
        }
        if (settingCtrl.language.value == LanguageSupported.english) {
          day = "Sat";
        }
        return day;
      case 7:
        String day = '';
        if (settingCtrl.language.value == LanguageSupported.korean) {
          day = "일";
        }
        if (settingCtrl.language.value == LanguageSupported.vietnamese) {
          day = "CN";
        }
        if (settingCtrl.language.value == LanguageSupported.english) {
          day = "Sun";
        }
        return day;
      default:
        return '';
    }
  }

  @override
  FutureOr<void> onDispose() async {}
}
