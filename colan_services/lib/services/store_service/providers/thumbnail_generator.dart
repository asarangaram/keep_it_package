import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:mutex/mutex.dart';

import '../extensions/global_preference.dart';
import '../models/media_with_details.dart';
import '../store_service.dart';
import 'media_provider.dart';

Logger logger = Logger(
  printer: PrettyPrinter(methodCount: 0, noBoxingByDefault: true),
);

class PreviewGenerator {
  PreviewGenerator(this.ref, this.storeManager);
  final Queue<MediaWithDetails> _jobQueue = Queue();
  final Mutex _mutex = Mutex();
  bool _isGenerating = false;
  StoreManager storeManager;
  Ref ref;

  Future<void> addAllToQueue(List<MediaWithDetails> media) async {
    final filtered = media
        .where(
          (e) => !e.status.isPreviewCached && (e.status.previewError == null),
        )
        .toList();
    logger.i('Adding ${filtered.length} media into preview generation queue.');

    await _mutex.protect(() async {
      _jobQueue.addAll(filtered);
    });

    if (!_isGenerating) {
      logger.i('Starting preview generation.');
      unawaited(_processNextJob());
    } else {
      logger.i('Preview generation already in progress.');
    }
  }

  Future<void> generatePreview(MediaWithDetails media) async {
    if (!media.status.isPreviewCached && (media.status.previewError == null)) {
      logger.i('Adding a media into preview generation queue.');
      await _mutex.protect(() async {
        _jobQueue.add(media);
      });
    }

    if (!_isGenerating) {
      logger.i('Starting preview generation.');
      unawaited(_processNextJob());
    } else {
      logger.i('Preview generation already in progress.');
    }
  }

  Future<void> cancelAllJobs() async {
    await _mutex.protect(() async => _jobQueue.clear());
  }

  Future<MediaWithDetails?> fetchJob() async {
    return _mutex.protect(() async {
      if (_jobQueue.isNotEmpty) {
        return _jobQueue.removeFirst();
      }
      return null;
    });
  }

  Future<void> _processNextJob() async {
    _isGenerating = true;

    final globalPref = await StoreExtOnDownloadMediaGlobalPreference.load();

    while (true) {
      final job = await fetchJob();

      // If no jobs left, break the loop
      if (job == null) {
        logger.i('No more jobs to process.');
        break;
      }
      logger.i('start preview generation for media ID: ${job.media.id!}');

      final mediaPath = storeManager.getMediaAbsolutePath(job.media);
      final previewPath = storeManager.getPreviewAbsolutePath(job.media);

      final success = await UtilsOnStoreManager.generatePreview(
        inputFile: mediaPath,
        outputFile: previewPath,
        type: job.media.type,
        dimension: globalPref.previewDimension,
      );

      if (success) {
        logger.i('Preview generated for media ID: ${job.media.id}');
        await ref.read(mediaProvider.notifier).markPreviewCached(job.media.id!);
      } else {
        logger.w('Failed to generate preview for media ID: ${job.media.id}');
      }
    }
    logger.i('Preview generation complete.');
    _isGenerating = false;
  }
}

final previewCacheManagerProvider =
    Provider.family<PreviewGenerator, StoreManager>((ref, storeManager) {
  logger.i('Cancelling all jobs in the queue.');
  return PreviewGenerator(ref, storeManager);
});
