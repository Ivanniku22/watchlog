import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/models/tmdb_models/popular.dart';
import '../../../data/repositories/tmdb_repostiory.dart';
import 'package:flutter/foundation.dart';

class ExploreController extends GetxController {
  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();

  final popularTvShows = Rxn<Popular>();
  final topRatedTvShows = Rxn<Popular>();
  final isLoading = false.obs;
  final visibleCount = 6.obs;
  final currentPage = 1.obs;
  final isLoadingMore = false.obs;
  final topRatedVisibleCount = 6.obs;

  final popularAnime = Rxn<Popular>();
  final topRatedAnime = Rxn<Popular>();
  final newAnime = Rxn<Popular>();

  final popularAnimeVisibleCount = 6.obs;
  final topRatedAnimeVisibleCount = 6.obs;
  final newAnimeVisibleCount = 6.obs;



  @override
  void onInit() {
    super.onInit();
    fetchPopularTvShows();
    fetchTopRatedTvShows();
    fetchPopularAnime();
    fetchTopRatedAnime();
    fetchNewAnime();
  }

  Future<void> fetchPopularTvShows() async {
    try {
      isLoading.value = true;

      popularTvShows.value = await tmdbRepository.getPopularTvShows();
    } catch (e) {
      print('Error details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTopRatedTvShows() async {
    try {
      topRatedTvShows.value = await tmdbRepository.getTopRatedTvShows();
    } catch (e) {
      print('Error details: $e');
    }
  }


  Future<void> fetchPopularAnime() async {
    try {
      popularAnime.value =
      await tmdbRepository.getPopularAnime();
    } catch (e , stackTrace) {
      debugPrint('Popular Anime Error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> fetchTopRatedAnime() async {
    try {
      topRatedAnime.value =
      await tmdbRepository.getTopRatedAnime();
    } catch (e) {
      print('Error details: $e');
    }
  }

  Future<void> fetchNewAnime() async {
    try {
      newAnime.value =
      await tmdbRepository.getNewAnime();
    } catch (e) {
      print('Error details: $e');
    }
  }



}