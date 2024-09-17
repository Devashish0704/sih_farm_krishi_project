import 'package:flutter/material.dart';

import 'components/body.dart';

class EditAddressScreen extends StatelessWidget {
  final String addressIdToEdit;

  const EditAddressScreen({this.addressIdToEdit = ""});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(addressIdToEdit: addressIdToEdit),
    );
  }
}
