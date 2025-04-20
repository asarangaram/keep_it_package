import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResizablePage extends StatefulWidget {
  const ResizablePage({super.key, this.top, this.bottom});
  final Widget? top;
  final Widget? bottom;

  @override
  State<ResizablePage> createState() => _ResizablePageState();
}

class _ResizablePageState extends State<ResizablePage> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: theme.radius,
        border: Border.all(
          color: theme.colorScheme.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: theme.radius,
        child: ShadResizablePanelGroup(
          axis: Axis.vertical,
          showHandle: true,
          handleDecoration: const ShadDecoration(color: Colors.red),
          dividerColor: Colors.red,
          children: [
            ShadResizablePanel(
              defaultSize: 0.4,
              child: widget.top ??
                  Center(
                    child: Text('Empty', style: theme.textTheme.large),
                  ),
            ),
            ShadResizablePanel(
              defaultSize: 0.6,
              child: widget.bottom ??
                  Center(
                    child: Text('Three', style: theme.textTheme.large),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
