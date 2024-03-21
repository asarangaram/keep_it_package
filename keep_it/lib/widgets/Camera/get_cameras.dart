import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GetCameras extends ConsumerWidget {
  const GetCameras({required this.builder, super.key});
  final Widget Function(List<CameraDescription> cameras) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(camearasProvider);

    try {
      return camerasAsync.when(
        data: builder,
        error: (e, st) => CameraError(errorMessage: e.toString()),
        loading: CameraLoading.new,
      );
    } catch (e) {
      return CameraError(errorMessage: e.toString());
    }
  }
}

class CameraLoading extends ConsumerWidget {
  const CameraLoading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CLLoadingView(),
          const SizedBox(
            height: 8,
          ),
          CLButtonText.large(
            'Go Back',
            onTap: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            color: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }
}

class CameraError extends ConsumerWidget {
  const CameraError({required this.errorMessage, super.key});
  final String errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CLErrorView(
          errorMessage: errorMessage,
        ),
        CLButtonText.large(
          'Go Back',
          onTap: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          color: Colors.blue.shade600,
        ),
      ],
    );
  }
}

final camearasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return availableCameras();
});
