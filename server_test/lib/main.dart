// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server_test/server_media.dart';

class PaginatedListScreen extends ConsumerStatefulWidget {
  const PaginatedListScreen({super.key});

  @override
  ConsumerState<PaginatedListScreen> createState() =>
      _PaginatedListScreenState();
}

class _PaginatedListScreenState extends ConsumerState<PaginatedListScreen> {
  late final ScrollController _scrollController;

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
    final serverMedia = ref.watch(serverMediaProvider);
    if (serverMedia == null) {
      return SizedBox(); // Fixme
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ref.read(serverMediaProvider.notifier).refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ref.read(serverMediaProvider.notifier).refresh,
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
                    onPressed:
                        ref.read(serverMediaProvider.notifier).fetchNextPage,
                    child: const Text('Load More'));
              } else {
                return const Center(child: Text('No more data on Server'));
              }
            }
            return ListTile(
              title: Text(serverMedia.items[index].name),
              subtitle: Text('ID: ${serverMedia.items[index].serverUID ?? ''}'),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProviderScope(child: PaginatedListScreen()),
  ));
}
