import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../label_viewer.dart';
import 'edit_collection_description.dart';
import 'pick_collection.dart';
import 'pick_tags.dart';

class CreateCollectionWizard extends StatefulWidget {
  const CreateCollectionWizard({
    required this.onDone,
    super.key,
  });

  final void Function({
    required Collection collection,
    required List<Tag> tags,
  }) onDone;

  @override
  State<StatefulWidget> createState() => PickCollectionState();
}

class PickCollectionState extends State<CreateCollectionWizard> {
  bool onEditLabel = true;
  Collection? collection;
  List<Tag>? selectedTags;
  late bool hasDescription;

  @override
  void initState() {
    collection = null;
    selectedTags = null;
    hasDescription = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (collection == null || onEditLabel) {
      return PickCollection(
        collection: collection,
        onDone: (collection) {
          setState(() {
            onEditLabel = false;
            this.collection = collection;
          });
        },
      );
    } else if (!hasDescription) {
      return Column(
        children: [
          LabelViewer(
            label: 'Collection: ${collection!.label}',
            icon: MdiIcons.pencil,
            onTap: () {
              setState(() {
                onEditLabel = true;
              });
            },
          ),
          Flexible(
            child: EditCollectionDescription(
              collection: collection!,
              onDone: (collection) {
                setState(() {
                  this.collection = collection;
                  hasDescription = true;
                });
              },
            ),
          ),
        ],
      );
    } else if (selectedTags == null) {
      return Column(
        children: [
          LabelViewer(
            label: 'Collection: ${collection!.label}',
            icon: MdiIcons.pencil,
            onTap: () {
              setState(() {
                onEditLabel = true;
                hasDescription = false;
              });
            },
          ),
          Flexible(
            child: PickTags(
              collection: collection!,
              onDone: (tags) {
                widget.onDone(collection: collection!, tags: tags);
              },
            ),
          ),
        ],
      );
    } else {
      return const Center(child: CLLoadingView(message: 'Saving...'));
    }
  }
}


/* 
    final pages = <PageBuilder>[
      page1,
      page2,
    ];
    return UpsertCollectionFormTheme(
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: pages.length,
        itemBuilder: (context, pageNum) {
          return pages[pageNum](
            context,
            onNext: () => changePage(pages.next(pageNum), pages.length),
            onPrevious: () => changePage(pages.previous(pageNum), pages.length),
          );
        },
      ),
    );
  }

  Widget page3(
    BuildContext context, {
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    return const Center(child: CLLoadingView(message: 'Saving...'));
  }

  Widget page2(
    BuildContext context, {
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    if (collection == null) {
      return const Text('Error in previous page');
    }
  }

  Widget page1(
    BuildContext contex, {
    void Function()? onPrevious,
    void Function()? onNext,
  }) {
    if (onEditLabel || collection == null) {
      return const Text('Error in previous page');
    }
    final menuItem = (collection!.id == null)
        ? CLMenuItem(
            title: 'Select Tags',
            icon: MdiIcons.arrowRight,
            onTap: () async {
              descriptionNode.unfocus();
              if (descriptionController.text.isNotEmpty) {
                if (collection?.description != descriptionController.text) {
                  setState(() {
                    collection = collection?.copyWith(
                      description: descriptionController.text,
                    );
                  });
                }
              }
              onNext?.call();
              return null;
            },
          )
        : CLMenuItem(
            title: 'Save',
            icon: Icons.save_rounded,
            onTap: () async {
              descriptionNode.unfocus();
              if (descriptionController.text.isNotEmpty) {
                if (collection?.description != descriptionController.text) {
                  setState(() {
                    collection = collection?.copyWith(
                      description: descriptionController.text,
                    );
                  });
                }
              }
              widget.onDone(collection: collection!);
              return null;
            },
          );
    return Center(
      child: SizedBox(
        height: kMinInteractiveDimension * 4,
        child: Column(
          children: [
            LabelViewer(
              label: 'Collection: ${collection!.label}',
              icon: MdiIcons.pencil,
              onTap: () {
                setState(() {
                  onEditLabel = true;
                });
                descriptionNode.unfocus();
                onPrevious?.call();
              },
            ),
            Flexible(
              child: WizardItem(
                action: menuItem,
                child: CollectionEditor(
                  collection!,
                  controller: descriptionController,
                  focusNode: descriptionNode,
                  enabled: widget.allowUpdateDescription,
                ),
              ),
            ),
          ],
        ),
      ),
    );
   
  }
class UpsertCollectionFormTheme extends ConsumerWidget {
  const UpsertCollectionFormTheme({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = MaterialStateProperty.all(
      const Color.fromARGB(0, 0, 0, 0),
    );

    final themeData = Theme.of(context).copyWith(
      searchBarTheme: SearchBarThemeData(
        textStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.blue),
        ),
        textCapitalization: TextCapitalization.words,
        backgroundColor: color,
        shadowColor: color,
        surfaceTintColor: color,
        overlayColor: color,
        shape: MaterialStateProperty.all(
          const ContinuousRectangleBorder(),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(4),
      ),
    );
    return Theme(
      data: themeData,
      child: child,
    );
  }
}
 */
