/// TOOD - Use something more generic, that may cover any case

class StringUtils {
  static String stripTags(String html) {
    html = html.replaceAll('</p>', '').replaceAll('<p>', '');
    html = html.replaceAll('&lt;', '<').replaceAll('&gt;', '>');
    return html.replaceAll('<br>', '\n');
  }
}