class StringUtils {
  static String stripTags(String html) {
    html = html.replaceAll('</p><p>', '\n');
    while(html.contains('<')) {
      if(html.indexOf('<') < html.length && html.indexOf('>') < html.length) {
        html = html.replaceRange(html.indexOf('<'), html.indexOf('>')+1, '');
      }
    }
    html = html.replaceAll('&lt;', '<').replaceAll('&gt;', '>');
    html = html.replaceAll('&amp;', '&').replaceAll('&nbsp;', ' ');
    html = html.replaceAll('&quot;', '"').replaceAll("&apos;", "'");
    return html;
  }
}   