import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class TickerBuilder extends StatefulWidget {
  const TickerBuilder({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  State<TickerBuilder> createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
