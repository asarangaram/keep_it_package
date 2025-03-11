import 'package:cl_entity_viewers/cl_entity_models.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server/server.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../common/base_scaffold.dart';

class RegisterredServerView extends ConsumerStatefulWidget {
  const RegisterredServerView({super.key});

  @override
  ConsumerState<RegisterredServerView> createState() =>
      _RegisterredServerViewState();
}

class _RegisterredServerViewState extends ConsumerState<RegisterredServerView> {
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
    final server = ref.watch(serverProvider);
    /* return Scaffold(
      body: ServerMediaList(),
    ); */
    final textTheme = ShadTheme.of(context).textTheme;
    return BaseScaffold(
        appBarTitleWidget: RefreshIndicator(
          onRefresh: ref.read(serverMediaProvider.notifier).refresh,
          child: ListTile(
            leading: SizedBox.shrink(),
            title: Text('KeepIt Media Viewer'),
            titleTextStyle: textTheme.h4,
            isThreeLine: true,
            subtitle: Text(
              '${server.identity!.identifier}@${server.identity!.address}:${server.identity!.port}',
              style: textTheme.small,
            ),
            trailing: ShadButton.secondary(
              onPressed: () => ref.read(serverProvider.notifier).deregister(),
              backgroundColor: textTheme.blockquote.backgroundColor,
              child: Text("Deregister"),
            ),
          ),
        ),
        wrapChildrenInScrollable: false,
        wrapSingleChildInColumn: false,
        children: [ServerMediaList()]);
  }
}

class ServerMediaList extends ConsumerStatefulWidget {
  const ServerMediaList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ServerMediaListState();
}
//

class _ServerMediaListState extends ConsumerState<ServerMediaList> {
  @override
  Widget build(BuildContext context) {
    final serverMedia = ref.watch(serverMediaProvider);
    if (serverMedia.items.isEmpty) {
      return Text('No more data on Server');
    }
    return SizedBox(
      child: CLEntityGridView(
        viewIdentifier: ViewIdentifier(parentID: "server", viewId: "mediaview"),
        numColumns: 5,
        entities: serverMedia.items,
        itemBuilder: (BuildContext context, CLEntity entity) {
          return Center(child: Text("entity"));
        },
        labelBuilder: (BuildContext context,
            List<GalleryGroupCLEntity<CLEntity>> galleryMap,
            GalleryGroupCLEntity<CLEntity> gallery) {
          return null;
        },
        headerWidgetsBuilder: (BuildContext context,
            List<GalleryGroupCLEntity<CLEntity>> galleryMap) {
          return [];
        },
        footerWidgetsBuilder: (BuildContext context,
            List<GalleryGroupCLEntity<CLEntity>> galleryMap) {
          return [
            if (serverMedia.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (serverMedia.metaInfo.pagination.hasNext)
              TextButton(
                  onPressed:
                      ref.read(serverMediaProvider.notifier).fetchNextPage,
                  child: const Text('Load More'))
            else
              const Center(child: Text('No more data on Server'))
          ];
        },
      ),
    );
  }
}



/**
 * 
ListView.builder(
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
      )
 */