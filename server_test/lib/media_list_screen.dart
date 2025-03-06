// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server_test/providers/server_media.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'registerred_server_view.dart';
import 'server_selector_view.dart';
import 'providers/server.dart';

class MediaListScreen extends ConsumerStatefulWidget {
  const MediaListScreen({super.key});

  @override
  ConsumerState<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends ConsumerState<MediaListScreen> {
  late final ScrollController _scrollController;

  bool enabled = true;
  var autovalidateMode = ShadAutovalidateMode.alwaysAfterFirstValidation;

  Map<Object, dynamic> formValue = {};
  final formKey = GlobalKey<ShadFormState>();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 300) {
      ref.read(serverMediaProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final server = ref.watch(serverProvider);

    if ((server.isRegistered)) {
      return const RegisterredServerView();
    } else {
      return ServerSelectorView();
    }
  }
}

/**
 * dd
 * 
 RefreshIndicator(
        onRefresh: ref.read(serverMediaProvider.notifier).refresh,
 ScanForServer(),
            Text(scanner.toString()),
            Text(server.toString()),
            if (server.canSync)
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: serverMedia.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == serverMedia.items.length) {
                      if (serverMedia.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (serverMedia.metaInfo.pagination.hasNext) {
                        return TextButton(
                            onPressed: ref
                                .read(serverMediaProvider.notifier)
                                .fetchNextPage,
                            child: const Text('Load More'));
                      } else {
                        return const Center(
                            child: Text('No more data on Server'));
                      }
                    }
                    return ListTile(
                      title: Text(serverMedia.items[index].name),
                      subtitle: Text(
                          'ID: ${serverMedia.items[index].serverUID ?? ''}'),
                    );
                  },
                ),
              ),
 */
