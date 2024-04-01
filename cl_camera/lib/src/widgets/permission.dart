import 'package:flutter/material.dart';

class RequestPermission extends StatelessWidget {
  const RequestPermission({required this.getPermissionStatus, super.key});
  final void Function() getPermissionStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(),
        const Text(
          'Permission denied',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: getPermissionStatus,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Give permission',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
