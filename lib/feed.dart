import 'package:xml/xml.dart';

class Person {
  String name;
  String email;
  Uri link;

  Person(this.name, {this.email, this.link});
}

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
      ..element('feed', attributes: {'xmlns': 'http://www.w3.org/2005/Atom'},
          nest: () {
        // Build required elements.
        builder
          ..element('id', nest: feed.id.toString())
          ..element('title', nest: feed.title);

        // Build recommended elements.
        if (feed.author != null) {
          builder.element('author', nest: () {
            builder.element('name', nest: feed.author.name);

            if (feed.author.email != null)
              builder.element('email', nest: feed.author.email);

            if (feed.author.link != null)
              builder.element('uri', nest: feed.author.link.toString());
          });
        }

        if (feed.link != null) {
          builder.element('link', attributes: {
            'rel': 'alternate',
            'href': feed.link.toString()
          });
        }

        if (feed.feed != null) {
          builder.element('link', attributes: {
            'rel': 'self',
            'href': feed.feed.toString()
          });
        }

        if (feed.hub != null) {
          builder.element('link', attributes: {
            'rel': 'hub',
            'href': feed.hub.toString()
          });
        }

        // Build optional elements.
        if (feed.description != null)
          builder.element('subtitle', nest: feed.description);

        if (feed.image != null)
          builder.element('logo', nest: feed.image.toString());

        if (feed.copyright != null)
          builder.element('rights', nest: feed.copyright);

        for (String catagory in feed.catagories)
          builder.element('catagory', attributes: {'term': catagory});

        for (Person contributor in feed.contributors) {
          builder.element('contributor', nest: () {
            builder.element('name', nest: contributor.name);

            if (contributor.email != null)
              builder.element('email', nest: contributor.email);

            if (contributor.link != null)
              builder.element('uri', nest: contributor.link.toString());
          });
        }
      });
    return builder.build();
  }

  static XmlNode _renderRSS2(Feed feed) => '';

  Person author;
  String id;
  String title;
  String description;
  Uri link;
  Uri image;
  String copyright;
  Uri feed;
  Uri hub;
  DateTime updated;
  List<Item> items = [];
  List<String> catagories = [];
  List<Person> contributors = [];

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
