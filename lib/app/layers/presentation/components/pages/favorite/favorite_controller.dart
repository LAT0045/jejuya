import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jejuya/app/core_impl/di/injector_impl.dart';
import 'package:jejuya/app/layers/data/sources/local/model/destination/destination.dart';
import 'package:jejuya/app/layers/data/sources/local/model/destination/destination_detail.dart';
import 'package:jejuya/app/layers/data/sources/local/model/schedule/schedule.dart';
import 'package:jejuya/app/layers/data/sources/local/model/userDetail/userDetail.dart';
import 'package:jejuya/app/layers/domain/usecases/destination/destination_detail_usecase.dart';
import 'package:jejuya/app/layers/domain/usecases/userdetail/fetch_user_detail_usecase_usecase.dart';
import 'package:jejuya/app/layers/presentation/components/pages/destination_detail/enum/info_enum.dart';
import 'package:jejuya/app/layers/presentation/components/pages/favorite/enum/favorite_state.dart';
import 'package:jejuya/core/arch/domain/usecase/usecase_provider.dart';
import 'package:jejuya/core/arch/presentation/controller/base_controller.dart';
import 'package:jejuya/core/reactive/dynamic_to_obs_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for the Favorite page
class FavoriteController extends BaseController with UseCaseProvider {
  /// Default constructor for the FavoriteController.
  FavoriteController() {
    notShow();
    initialize();
  }

  // --- Member Variables ---

  /// Search Controller
  final TextEditingController searchController = TextEditingController();

  // --- Computed Variables ---
  // --- State Variables ---
  // --- State Computed ---
  final notShowAgain = listenableStatus<bool>(false);
  final isDetination = listenableStatus<bool>(false);
  final userDetail = listenableStatus<UserDetail?>(null);
  final fetchDetailState = listenable<FavoriteState>(FavoriteState.none);
  late final _fetchUserDetail = usecase<FetchUserDetailUsecaseUseCase>();
  final destinationDetail = listenableStatus<DestinationDetail?>(null);
  final fetchDestinationDetailState =
      listenable<DestinationDetailState>(DestinationDetailState.none);

  late final _fetchDestinationDetail = usecase<DestinationDetailUseCase>();

  List<DestinationDetail> favoriteSpot = listenableList<DestinationDetail>([]);
  // --- Usecases ---
  // --- Methods ---

  @override
  Future<void> initialize() async {
    super.initialize();
    await fetchUserDetail();
    await fetchFavoriteSpots();
  }

  Future<void> fetchFavoriteSpots() async {
    try {
      for (Destination item in userDetail.value?.favoriteSpots ?? []) {
        await fetchDestinationDetail(item.id)
            .then((value) => favoriteSpot.add(value!));
      }
    } catch (e, s) {
      log.error(
        '[DestinationDetailController] Failed to fetch detail:',
        error: e,
        stackTrace: s,
      );
      nav.showSnackBar(error: e);
    }
  }

  Future<void> fetchUserDetail() async {
    try {
      fetchDetailState.value = FavoriteState.loading;

      await _fetchUserDetail
          .execute(FetchUserDetailUsecaseRequest())
          .then((response) => response.userDetail)
          .assignTo(userDetail);
      fetchDetailState.value = FavoriteState.done;
    } catch (e, s) {
      log.error(
        '[DestinationDetailController] Failed to fetch detail:',
        error: e,
        stackTrace: s,
      );
      nav.showSnackBar(error: e);
    }
  }

  Future<DestinationDetail?> fetchDestinationDetail(
      String destinationId) async {
    try {
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

  Future<void> notShow() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getBool('notShowAgain') ?? false;
    notShowAgain.value = savedValue;
  }

  @override
  FutureOr<void> onDispose() async {}
}
