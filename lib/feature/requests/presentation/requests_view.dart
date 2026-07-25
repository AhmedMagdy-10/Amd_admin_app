import 'package:flutter/material.dart';
import 'widgets/requests_body.dart';

/// Simple shell — BlocProvider lives at the app root (main.dart),
/// so this widget just renders the body directly.
class RequestsView extends StatelessWidget {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) => const RequestsBody();
}
