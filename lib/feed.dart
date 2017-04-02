import 'package:intl/intl.dart' show DateFormat;
import 'package:xml/xml.dart';

class Person {
  String email;
  Uri link;
  String name;

  Person(this.name, {this.email, this.link});
}

class Item {
  List<Person> authors = [];
  List<Person> contributors = [];
  String title;
  String link;
  String description;
  DateTime date;
  DateTime published;
  Uri image;
  String guid;
  String id;
  String content;
  String copyright;
}

enum FeedRenderer { atom, rss2 }

class Feed {
  List<Person> authors = [];
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

  Feed(this.title, {this.description});

  XmlNode _renderAtom() {
    XmlBuilder builder = new XmlBuilder();

    // Utility function for building an xml element describing the properties of
    // a [Person].
    void buildPerson(String element, Person person) {
      builder.element(element, nest: () {
        builder.element('name', nest: person.name);

        if (person.email != null)
          builder.element('email', nest: person.email);

        if (person.link != null)
          builder.element('uri', nest: person.link.toString());
      });
    }

    // Utility function for converting all [DateTime] objects to UTC timezones
    // and to an ISO 8601 formatted [String].
    String standardiseDateTime(DateTime dateTime) =>
        dateTime.toUtc().toIso8601String();

    builder
      ..processing('xml', 'version="1.0" encoding="utf-8"')
      ..element('feed', attributes: {'xmlns': 'http://www.w3.org/2005/Atom'},
          nest: () {
        // Build required elements.
        builder
          ..element('id', nest: id.toString())
          ..element('title', nest: title)
          ..element('link', attributes: {
            'rel': 'alternate',
            'href': link.toString()
          })
          ..element('updated', nest: standardiseDateTime(
              updated == null ? new DateTime.now() : updated));

        // Build recommended elements.
        for (Person author in authors) buildPerson('author', author);

        if (feed != null) {
          builder.element('link', attributes: {
            'rel': 'self',
            'href': feed.toString()
          });
        }

        if (hub != null) {
          builder.element('link', attributes: {
            'rel': 'hub',
            'href': hub.toString()
          });
        }

        // Build optional elements.
        if (description != null) builder.element('subtitle', nest: description);
        if (image != null) builder.element('logo', nest: image.toString());
        if (copyright != null) builder.element('rights', nest: copyright);

        for (String category in categories)
          builder.element('category', attributes: {'term': category});

        for (Person contributor in contributors)
          buildPerson('contributor', contributor);

        for (Item item in items) {
          builder.element('entry', nest: () {
            // Build required item elements.
            builder
              ..element('title', attributes: {'type': 'html'}, nest: () {
                builder.cdata(item.title);
              })
              ..element('id', nest: item.id ?? item.link)
              ..element('link', attributes: {'href': item.link})
              ..element('updated', nest: standardiseDateTime(item.date));

            // Build recommended item elements.
            if (item.description != null) {
              builder.element('summary', attributes: {'type': 'html'},
                  nest: () {
                builder.cdata(item.content);
              });
            }

            if (item.content != null) {
              builder.element('content', attributes: {'type': 'html'},
                  nest: () {
                builder.cdata(item.content);
              });
            }

            for (Person author in item.authors) buildPerson('author', author);

            // Build optional item elements.
            for (Person contributor in item.contributors)
              buildPerson('contributor', contributor);

            if (item.published != null) {
              builder.element('published',
                  nest: standardiseDateTime(item.published));
            }

            if (item.copyright != null)
              builder.element('rights', nest: item.copyright);
          });
        }
      });

    return builder.build();
  }

  XmlNode _renderRSS2() {
    XmlBuilder builder = new XmlBuilder();

    // Utility function for converting all [DateTime] objects to UTC timezones
    // and to an RFC 822 formatted [String].
    String standardiseDateTime(DateTime dateTime) {
      return new DateFormat('EEE, dd MMMM yyyy HH:mm:ss +0000')
          .format(dateTime.toUtc());
    }

    builder
      ..processing('xml', 'version="1.0" encoding="utf-8"')
      ..element('rss', attributes: {'version': '2.0'}, nest: () {
        builder.element('channel', nest: () {
          // Build required channel elements.
          if (description == null) {
            throw new Exception(
                'Property `description` is required when rendering to RSS2.');
          }
          builder
            ..element('title', nest: title)
            ..element('description', nest: description)
            ..element('link', nest: link.toString())
            ..element('lastBuildDate',
                nest: standardiseDateTime(updated ?? new DateTime.now()))
            ..element('docs', nest: 'http://blogs.law.harvard.edu/tech/rss');

          // Build recommended channel elements.
          
        });
      });

    return builder.build();
  }

  String toXmlString({renderer: FeedRenderer.atom, bool pretty: false,
      String indent: '  '}) {
    XmlNode xml = renderer == FeedRenderer.atom ? _renderAtom() : _renderRSS2();
    return xml.toXmlString(pretty: pretty, indent: indent);
  }
}

void main() {
  var feed = new Feed('Steven\'s Blog')
    ..id = 'https://stwupton.test.io/'
    ..link = Uri.parse('https://stwupton.github.io/')
    ..description = 'test'
    ..items = [
      new Item()
        ..title = 'Testing blog post'
        ..link = 'https://stwupton.test.io/post'
        ..date = new DateTime.now()
    ];
  print(feed.toXmlString(renderer: FeedRenderer.rss2, pretty: true));
}
