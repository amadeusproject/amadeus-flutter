/// TODO - Use something more generic, that may cover any case

class StringUtils {
  static String stripTags(String html) {
    html = html.replaceAll('</p>', '').replaceAll('<p>', '');
    html = html.replaceAll('&lt;', '<').replaceAll('&gt;', '>');
    html = html.replaceAll('&amp;', '&');
    html = html.replaceAll('&quot;', '"').replaceAll("&apos;", "'");
    return html.replaceAll('<br>', '\n').replaceAll('&nbsp;', ' ');
  }
}