import 'package:content_store/src/stores/builders/get_nw_scanner.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchServers extends ConsumerWidget {
  const SearchServers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetNetworkScanner(errorBuilder: (p0, p1) {
      throw UnimplementedError();
    }, loadingBuilder: () {
      throw UnimplementedError();
    }, builder: (scanner) {
      if (scanner.servers == null) {
        return const CircularProgressIndicator.adaptive();
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Available Servers '
                        '\u00A0\u00A0\u00A0\u00A0',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '\u21BA Refresh',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      //fontSize: CLScaleType.small.fontSize,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = scanner.search,
                  ),
                ],
              ),
            ),
          ),

          //CLIconLabelled.large(clIcons.serversList, 'Servers'),
          for (final candidate in scanner.servers!)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${candidate.identifier} '
                            '[${candidate.storeURL.uri}]'
                            ' \u00A0\u00A0\u00A0\u00A0',
                      ),
                      TextSpan(
                        text: '\u2295Register',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            throw UnimplementedError();
                          },
                      )
                      /* else
                        TextSpan(
                          text: 'Registered',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: CLScaleType.small.fontSize,
                          ),
                        ), */
                    ],
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
        ],
      );
    });
  }
}
