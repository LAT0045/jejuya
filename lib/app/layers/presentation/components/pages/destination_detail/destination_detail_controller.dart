import 'dart:async';

import 'package:jejuya/app/layers/data/sources/local/model/destination/destination_detail.dart';
import 'package:jejuya/app/layers/presentation/components/pages/destination_detail/enum/info_enum.dart';
import 'package:jejuya/core/arch/domain/usecase/usecase_provider.dart';
import 'package:jejuya/core/arch/presentation/controller/base_controller.dart';
import 'package:jejuya/core/reactive/dynamic_to_obs_data.dart';

/// Controller for the Destination detail page
class DestinationDetailController extends BaseController with UseCaseProvider {
  /// Default constructor for the DestinationDetailController.
  DestinationDetailController({
    required this.destinationDetail,
  }) {
    //fetchDestinationDetail();
  }
  // --- Member Variables ---
  DestinationDetail? destinationDetail;

  // --- Member Variables ---
  // DestinationDetail? destinationDetail;
  // --- Computed Variables ---
  //final destinationDetail = listenableStatus<DestinationDetail?>(null);

  // --- State Computed ---
  // --- Usecases ---
  // --- Methods ---

  final fetchDetailState =
      listenable<DestinationDetailState>(DestinationDetailState.none);

  List<String> categoryConvert(String category) {
    final list = category.split('/');
    return list;
  }

  List<String> categoryDetailConvert(String categoryDetail) {
    final list = categoryDetail.split(', ');
    return list;
  }

  @override
  FutureOr<void> onDispose() async {}
}
