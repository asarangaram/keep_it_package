import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'pure/wizard_item.dart';

class WizardFormPage extends StatefulWidget {
  const WizardFormPage({
    required this.onSubmit,
    required this.descriptor,
    super.key,
  });

  final void Function(CLFormFieldResult result) onSubmit;

  final CLFormFieldDescriptors descriptor;
  @override
  State<WizardFormPage> createState() => _WizardFormPageState();
}

class _WizardFormPageState extends State<WizardFormPage> {
  late CLFormSelectState state;
  final GlobalKey wrapKey = GlobalKey();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    state = CLFormSelectState(
      scrollController: ScrollController(),
      wrapKey: wrapKey,
      searchController: SearchController(),
      selectedEntities:
          (widget.descriptor as CLFormSelectDescriptors).initialValues,
    );

    super.initState();
  }

  @override
  void dispose() {
    state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: WizardItem(
        action: CLMenuItem(
          title: 'Save',
          icon: MdiIcons.floppy,
          onTap: () async {
            if (formKey.currentState?.validate() ?? false) {
              widget.onSubmit(
                CLFormSelectResult(state.selectedEntities),
              );
              return true;
            }
            return false;
          },
        ),
        child: SizedBox.expand(
          child: CLFormSelect(
            descriptors: widget.descriptor as CLFormSelectDescriptors,
            state: state,
            onRefresh: () {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}


/*
SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                key: wrapKey,
                spacing: 1,
                runSpacing: 1,
                children: [
                  ...selectedEntities.map(
                    (e) => Theme(
                      data: Theme.of(context).copyWith(
                        chipTheme: const ChipThemeData(
                          side: BorderSide.none,
                        ),
                        canvasColor: Colors.transparent,
                      ),
                      child: Chip(
                        label: Text(e.label),
                        onDeleted: () {
                          setState(() {
                            selectedEntities.remove(e);
                          });
                        },
                      ),
                    ),
                  ),
                  CreateOrSelectTags(
                    controller: controller,
                    onDone: onDone,
                    suggestedCollections: [
                      ...widget.entities,
                      ...widget.availableSuggestions.where((element) {
                        return !widget.entities
                            .map((e) => e.label)
                            .contains(element.label);
                      }),
                    ]
                        .where(
                          (element) => !selectedEntities
                              .map((e) => e.label)
                              .contains(element.label),
                        )
                        .toList(),
                    anchorBuilder: (
                      BuildContext context,
                      SearchController controller, {
                      required void Function(Tag) onDone,
                    }) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.transparent,
                        ),
                        child: ActionChip(
                          avatar: Icon(MdiIcons.plus),
                          label: Text(
                            selectedEntities.isEmpty
                                ? 'Add Tag'
                                : 'Add Another Tag',
                          ),
                          onPressed: controller.openView,
                          shape: const ContinuousRectangleBorder(
                            side: BorderSide(),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
 */