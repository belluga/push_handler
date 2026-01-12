import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PushStepBody extends StatelessWidget {
  const PushStepBody({
    super.key,
    required this.body,
    this.textColor,
  });

  final String body;
  final Color? textColor;
  static const Set<String> _allowedHtmlTags = {
    'html',
    'body',
    'p',
    'br',
    'strong',
    'em',
    'u',
    'span',
    'ul',
    'ol',
    'li',
    'img',
  };

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final resolvedColor = textColor ?? theme.colorScheme.onSurface;

    if (_looksLikeHtml(body)) {
      return Html(
        data: body,
        onlyRenderTheseTags: _allowedHtmlTags,
        style: {
          'body': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            color: resolvedColor,
          ),
          'p': Style(
            margin: Margins.only(bottom: 12),
            color: resolvedColor,
          ),
          'h1': Style(color: resolvedColor),
          'h2': Style(color: resolvedColor),
          'h3': Style(color: resolvedColor),
          'a': Style(color: resolvedColor),
        },
      );
    }

    final styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyMedium?.copyWith(color: resolvedColor),
      h1: theme.textTheme.headlineSmall?.copyWith(color: resolvedColor),
      h2: theme.textTheme.titleLarge?.copyWith(color: resolvedColor),
      h3: theme.textTheme.titleMedium?.copyWith(color: resolvedColor),
      a: theme.textTheme.bodyMedium?.copyWith(color: resolvedColor),
      textAlign: WrapAlignment.center,
      h1Align: WrapAlignment.center,
      h2Align: WrapAlignment.center,
      h3Align: WrapAlignment.center,
      h4Align: WrapAlignment.center,
      h5Align: WrapAlignment.center,
      h6Align: WrapAlignment.center,
      unorderedListAlign: WrapAlignment.center,
      orderedListAlign: WrapAlignment.center,
    );

    return SizedBox(
      width: double.infinity,
      child: MarkdownBody(
        data: body,
        fitContent: false,
        styleSheet: styleSheet,
        sizedImageBuilder: (config) => Image.network(
          config.uri.toString(),
          width: config.width,
          height: config.height,
        ),
      ),
    );
  }

  bool _looksLikeHtml(String value) {
    return RegExp(r'<[^>]+>').hasMatch(value);
  }
}
