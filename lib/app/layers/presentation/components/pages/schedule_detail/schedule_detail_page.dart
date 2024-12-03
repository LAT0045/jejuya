import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jejuya/app/common/ui/svg/svg_local.dart';
import 'package:jejuya/app/common/utils/extension/build_context/app_color.dart';
import 'package:jejuya/app/common/utils/extension/num/adaptive_size.dart';
import 'package:jejuya/app/common/utils/extension/string/string_to_color.dart';
import 'package:jejuya/app/core_impl/di/injector_impl.dart';
import 'package:jejuya/app/layers/data/sources/local/model/destination/destination_detail.dart';
import 'package:jejuya/app/layers/data/sources/local/model/language/language_supported.dart';
import 'package:jejuya/app/layers/presentation/components/pages/schedule_detail/mockup/schedule.dart';
import 'package:jejuya/app/layers/presentation/components/pages/schedule_detail/schedule_detail_controller.dart';
import 'package:jejuya/app/layers/presentation/components/widgets/button/bounces_animated_button.dart';
import 'package:jejuya/app/layers/presentation/global_controllers/setting/setting_controller.dart';
import 'package:jejuya/app/layers/presentation/nav_predefined.dart';
import 'package:jejuya/core/arch/presentation/controller/controller_provider.dart';

/// Page widget for the Schedule detail feature
///
class ScheduleDetailPage extends StatefulWidget
    with
        ControllerProvider<ScheduleDetailController>,
        GlobalControllerProvider {
  /// Default constructor for the ScheduleDetailPage.
  const ScheduleDetailPage({super.key});

  @override
  _ScheduleDetailPageState createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller(context);
    if (ctrl.schedule == null) {
      print("object");
      return const Center(child: CircularProgressIndicator());
    }
    ;
    return Scaffold(
        body: Column(
      children: [
        _headerBtn,
        _headerTxt,
        _day,
        Expanded(
          child: Observer(builder: (BuildContext context) {
            int itemCount = ctrl.scheduleItemsByDate.values
                .elementAt(ctrl.selectedDayIndex.value)
                .length;
            return ListView.builder(
              controller: ctrl.scrollController,
              // itemCount: itemCount + 1,
              itemCount: ctrl.destinationDetails.length + 1,
              itemBuilder: (context, index) {
                // if (index < itemCount) {
                if (index < ctrl.destinationDetails.length) {
                  return _destinationItem(
                      ctrl.destinationDetails[index]!, index);
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.color.primaryColor,
                    ),
                  );
                }
              },
            );
          }),
        )
      ],
    )).paddingSymmetric(
      vertical: 10.hMin,
      horizontal: 16.wMin,
    );
  }

  Widget get _headerBtn => Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BouncesAnimatedButton(
                width: 30.rMin,
                height: 30.rMin,
                leading: IconButton(
                  onPressed: nav.back,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: context.color.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              BouncesAnimatedButton(
                width: 40.rMin,
                height: 40.rMin,
                leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    LocalSvgRes.copy,
                    colorFilter: ColorFilter.mode(
                      context.color.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ).paddingSymmetric(vertical: 8.hMin, horizontal: 10.wMin),
                ),
              ).paddingOnly(right: 10.rMin),
              BouncesAnimatedButton(
                width: 40.rMin,
                height: 40.rMin,
                onPressed: () {
                  nav.toCreateSchedule();
                },
                leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    LocalSvgRes.edit,
                    colorFilter: ColorFilter.mode(
                      context.color.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ).paddingSymmetric(vertical: 8.hMin, horizontal: 10.wMin),
                ),
              ),
            ],
          );
        },
      );

  Widget get _headerTxt => Builder(
        builder: (context) {
          return Center(
            child: Text(
              "Jeju-si Trip",
              style: TextStyle(
                fontSize: 20.spMin,
                color: context.color.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ).paddingOnly(top: 5.hMin, bottom: 10.hMin);

  Widget get _day => Observer(
        builder: (context) {
          final ctrl = widget.controller(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${DateFormat('dd/MM/yyyy').format(ctrl.schedule!.startTime!)} - ${DateFormat('dd/MM/yyyy').format(ctrl.schedule!.endTime!)}",
                style: TextStyle(
                  fontSize: 14.spMin,
                  color: context.color.black,
                ),
              ),
              _listDay,
              _info,
            ],
          );
        },
      );

  Widget get _listDay => Observer(
        builder: (context) {
          final ctrl = widget.controller(context);
          final listDay = ctrl.scheduleItemsByDate;
          return SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: listDay.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return BouncesAnimatedButton(
                  width: 70.rMin,
                  height: 70.hMin,
                  onPressed: () {
                    ctrl.updateSelectedDay(index);
                  },
                  // leading: _dayItem(listDay[index].date, index),
                  leading: _dayItem(
                      DateFormat('dd/MM/yyy')
                          .format(DateTime.parse(listDay.keys.elementAt(index)))
                          .toString(),
                      index),
                );
              },
            ),
          );
        },
      );

  Widget _dayItem(String date, int index) => Observer(
        builder: (context) {
          final ctrl = widget.controller(context);
          final formattedDay = ctrl.formatDate(date);
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: index != ctrl.selectedDayIndex.value
                      ? context.color.white
                      : context.color.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.rMin),
                  border: Border.all(
                    color: context.color.primaryColor,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDay['monthAb'] ?? '',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: context.color.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      formattedDay['day'] ?? '',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: context.color.black,
                      ),
                    ),
                    Text(
                      formattedDay['dayOfWeek'] ?? '',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: context.color.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 10.rMin, vertical: 5.hMin),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5.rMin,
                    height: 5.rMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: context.color.primaryLight,
                    ),
                  ).paddingOnly(right: 5.hMin),
                  Container(
                    width: 5.rMin,
                    height: 5.rMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: '#C8D6F4'.toColor,
                    ),
                  ).paddingOnly(right: 5.hMin),
                  Container(
                    width: 5.rMin,
                    height: 5.rMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: '#FCA2A3'.toColor,
                    ),
                  ),
                ],
              ).paddingOnly(top: 4.hMin),
            ],
          ).paddingOnly(right: 20.wMin, top: 10.hMin);
        },
      );

  Widget get _info => Observer(
        builder: (context) {
          final ctrl = widget.controller(context);
          final currentDate = DateFormat('dd/MM/yyy')
              .format(DateTime.parse(ctrl.scheduleItemsByDate.keys
                  .elementAt(ctrl.selectedDayIndex.value)))
              .toString();
          final formattedDay = ctrl.formatDate(currentDate);
          final settingCtrl = widget.globalController<SettingController>();

          final dayRank = settingCtrl.language.value != LanguageSupported.korean
              ? "${tr("destination_detail.day")} ${ctrl.selectedDayIndex.value + 1}"
              : "${ctrl.selectedDayIndex.value + 1} ${tr("destination_detail.day")} ";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.rMin,
                    height: 10.rMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: context.color.primaryLight,
                    ),
                  ).paddingOnly(right: 10.rMin, left: 2.rMin),
                  Expanded(
                    child: Text(
                      "$dayRank  - ${formattedDay['dayOfWeek']}, ${formattedDay['day']}/${formattedDay['month']}/${formattedDay['year']}",
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: context.color.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ).paddingOnly(bottom: 5.hMin),
              _iconText(
                LocalSvgRes.marker,
                ctrl.schedule!.accommodation!,
                true,
              ),
            ],
          );
        },
      );

  Widget _destinationItem(DestinationDetail destination, int index) => Observer(
        builder: (context) {
          final ctrl = widget.controller(context);
          return Container(
            decoration: BoxDecoration(
              color: ctrl.selectedDestinationIndex.value == index
                  ? context.color.primaryColor.withValues(alpha: 0.1)
                  : context.color.white,
              borderRadius: BorderRadius.circular(20.rMin),
              border: Border(
                top: BorderSide(width: 1, color: context.color.primaryLight),
                left: BorderSide(width: 13, color: context.color.primaryLight),
                right: BorderSide(width: 1, color: context.color.primaryLight),
                bottom: BorderSide(width: 1, color: context.color.primaryLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _iconText(
                        LocalSvgRes.node,
                        destination.businessNameEnglish,
                        //location.name,
                        true,
                      ).paddingOnly(
                        bottom: 16.hMin,
                      ),
                      _iconText(
                        LocalSvgRes.marker,
                        destination.locationEnglish,
                        //location.address,
                        false,
                      ).paddingOnly(
                        bottom: 16.hMin,
                      ),
                      _iconText(
                        LocalSvgRes.clock,
                        destination.operatingHoursEnglish,
                        // location.time,
                        false,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 31.rMin,
                      height: 31.rMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.rMin),
                        color:
                            context.color.primaryLight.withValues(alpha: 0.3),
                      ),
                      child: SvgPicture.asset(
                        LocalSvgRes.clock,
                        colorFilter: ColorFilter.mode(
                          context.color.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ).paddingAll(7.rMin),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.rMin),
                        color:
                            context.color.primaryLight.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        "Experience",
                        style: TextStyle(
                          color: context.color.primaryColor,
                          fontSize: 12.spMin,
                        ),
                      ).paddingAll(5.rMin),
                    ).paddingOnly(top: 30.hMin),
                  ],
                )
              ],
            ).paddingOnly(
              left: 20.wMin,
              right: 10.wMin,
              top: 16.hMin,
              bottom: 16.hMin,
            ),
          );
        },
      ).paddingSymmetric(vertical: 10.hMin);

  Widget _iconText(String image, String text, bool isTitle) => Builder(
        builder: (context) {
          return Row(
            children: [
              SvgPicture.asset(
                image,
                colorFilter: ColorFilter.mode(
                  context.color.primaryColor,
                  BlendMode.srcIn,
                ),
              ).paddingOnly(right: 7.hMin),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: context.color.black,
                    fontWeight: isTitle ? FontWeight.normal : FontWeight.w300,
                  ),
                  textAlign: TextAlign.start,
                  softWrap: true,
                ),
              ),
            ],
          );
        },
      );
}
