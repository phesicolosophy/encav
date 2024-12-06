import 'package:flutter/material.dart';

/// Add new key and IV to store and dis^lay them in drop menu.
class AddKeyIV extends StatelessWidget {
  const AddKeyIV({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Add Key and IV encryption'),
        IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white))
      ],
    );
  }
}
