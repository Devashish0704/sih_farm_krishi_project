import 'package:flutter/material.dart';

/// This code is an extension to the package flutter_progress_dialog (https://pub.dev/packages/future_progress_dialog)

const _DefaultDecoration = BoxDecoration(
  color: Colors.white,
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class AsyncProgressDialog extends StatefulWidget {
  /// Dialog will be closed when [future] task is finished.
  final Future future;

  /// [BoxDecoration] of [AsyncProgressDialog].
  final BoxDecoration? decoration;

  /// Opacity of [AsyncProgressDialog]
  final double opacity;

  /// If you want to use a custom progress widget set [progress].
  final Widget? progress;

  /// If you want to use a message widget set [message].
  final Widget? message;

  /// On error handler
  final Function? onError;

  AsyncProgressDialog(
    this.future, {
    Key? key,
    this.decoration,
    this.opacity = 1.0,
    this.progress,
    this.message,
    this.onError,
  }) : super(key: key);

  @override
  State<AsyncProgressDialog> createState() => _AsyncProgressDialogState();
}

class _AsyncProgressDialogState extends State<AsyncProgressDialog> {
  @override
  void initState() {
    super.initState();
    widget.future.then((val) {
      if (mounted) {
        Navigator.of(context).pop(val);
      }
    }).catchError((e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (widget.onError != null) {
        widget.onError?.call(e);
      } else {
        throw e;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: _buildDialog(context),
    );
  }

  Widget _buildDialog(BuildContext context) {
    var content;
    if (widget.message == null) {
      content = Center(
        child: Container(
          height: 100,
          width: 100,
          alignment: Alignment.center,
          decoration: widget.decoration ?? _DefaultDecoration,
          child: widget.progress ?? const CircularProgressIndicator(),
        ),
      );
    } else {
      content = Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: widget.decoration ?? _DefaultDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.progress ?? const CircularProgressIndicator(),
            const SizedBox(width: 20),
            _buildText(context)
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Opacity(
        opacity: widget.opacity,
        child: content,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    if (widget.message == null) {
      return const SizedBox.shrink();
    }
    return Expanded(
      flex: 1,
      child: widget.message!,
    );
  }
}
