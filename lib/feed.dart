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
          ..element('title', nest: feed.title)
          ..element('link', attributes: {
            'rel': 'alternate',
            'href': feed.link.toString()
          })
          ..element('updated', nest: feed.updated == null ?
              new DateTime.now().toUtc().toString() :
              feed.updated.toUtc().toString());

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

        for (String category in feed.categories)
          builder.element('category', attributes: {'term': category});

        for (Person contributor in feed.contributors) {
          builder.element('contributor', nest: () {
            builder.element('name', nest: contributor.name);

            if (contributor.email != null)
              builder.element('email', nest: contributor.email);

            if (contributor.link != null)
              builder.element('uri', nest: contributor.link.toString());
          });
        }

        for (Item item in feed.items) {
          // Build required item elements.
          builder.element('entry', nest: () {
            builder
              ..element('title', attributes: {'type': 'html'}, nest: () {
                builder.cdata(item.title);
              })
              ..element('id', nest: item.id ?? item.link)
              ..element('link', attributes: {'href': item.link})
              ..element('updated', nest: item.date.toUtc().toString());
          });
        }
      });
    return builder.build();
  }

  static XmlNode _renderRSS2(Feed feed) => '';

  Person author;
  List<String> categories = [];
  List<Person> contributors = [];
  String copyright;
  String description;
  Uri feed;
  Uri hub;
  String id;
  Uri image;
  List<Item> items = [];
  Uri link;
  String title;
  DateTime updated;

  String toXmlString({
      renderer: FeedRenderer.atom,
      bool pretty: false,
      String indent: '  '}) =>
    _renderers[renderer](this).toXmlString(pretty: pretty, indent: indent);
}

void main() {
  var feed = new Feed()
    ..id = 'https://stwupton.test.io/'
    ..title = 'Steven\'s Blog'
    ..link = Uri.parse('https://stwupton.github.io/')
    ..items = [new Item()..title = 'Testing blog post'];
  print(feed.toXmlString(pretty: true));
}
