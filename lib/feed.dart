import 'package:xml/xml.dart';

class Item {
  String title;
  String link;
  String description;
  DateTime date;
  DateTime published;
  Uri image;
  String author;
  String contributor;
  String guid;
  String id;
  String content;
  String copyright;
}

enum FeedRenderer { atom, rss2 }

class Feed {
  static Map<FeedRenderer, Function> _renderers = {
    FeedRenderer.atom: _renderAtom,
    FeedRenderer.rss2: _renderRSS2
  };

  static XmlNode _renderAtom(Feed feed) {
    XmlBuilder builder = new XmlBuilder();
    builder
      ..processing('xml', 'version="1.0"')
      ..element(
          'feed',
          attributes: {'xmlns': 'http://www.w3.org/2005/Atom'},
          nest: () {

        // Build required elements.
        builder
          ..element('id', nest: feed.id.toString())
          ..element('title', nest: feed.title);

        // Build recommended elements.
        if (feed.link != null) {
          builder.element(
              'link',
              attributes: {'rel': 'alternate'},
              nest: feed.link.toString());
        }

        if (feed.feed != null) {
          builder.element(
              'link',
              attributes: {'rel': 'self'},
              nest: feed.feed.toString());
        }

        if (feed.hub != null) {
          builder.element(
              'link',
              attributes: {'rel': 'hub'},
              nest: feed.hub.toString());
        }

      });
    return builder.build();
  }

  static XmlNode _renderRSS2(Feed feed) => '';

  String id;
  String title;
  String description;
  Uri link;
  Uri image;
  String copyright;
  String feed;
  String hub;
  DateTime updated;
  String author;
  List<Item> items = [];
  List<String> catagories = [];
  List<String> contributors = [];

  String toXmlString({
      renderer: FeedRenderer.atom,
      bool pretty: false,
      String indent: '  '}) =>
    _renderers[renderer](this).toXmlString(pretty: pretty, indent: indent);
}

void main() {
  var feed = new Feed();
  print(feed.toXmlString(pretty: true));
}
