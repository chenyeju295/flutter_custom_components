import 'package:flutter/material.dart';

class LinkTag {
  final int? id;
  final String? tag;
  final List<LinkTag>? child;
  late final GlobalKey tagKey;
  LinkTag({this.id, this.child, this.tag}) {
    tagKey = GlobalKey(debugLabel: id.toString() + tag.toString());
  }
}

class LinkageListProvider extends ChangeNotifier {
  List<LinkTag> linkageList = [
    LinkTag(
      id: 1,
      tag: 'Tag1',
      child: [
        LinkTag(
          id: 2,
          tag: 'Tag1-1',
          child: [
            LinkTag(
              id: 3,
              tag: 'Tag1-1-1',
            ),
            LinkTag(
              id: 4,
              tag: 'Tag1-1-2',
            ),
          ],
        ),
        LinkTag(
          id: 5,
          tag: 'Tag1-2',
        ),
      ],
    ),
    LinkTag(
      id: 6,
      tag: 'Tag2',
      child: [
        LinkTag(
          id: 7,
          tag: 'Tag2-1',
        ),
      ],
    ),
    LinkTag(
      id: 8,
      tag: 'Tag3',
    ),
    LinkTag(
      id: 9,
      tag: 'Tag3-1',
    ),
    LinkTag(
      id: 10,
      tag: 'Tag3-2',
    ),
    LinkTag(id: 11, tag: 'Tag3-3', child: [
      LinkTag(
        id: 12,
        tag: 'Tag3-3-1',
      ),
      LinkTag(
        id: 13,
        tag: 'Tag3-3-2',
      )
    ]),
    LinkTag(id: 14, tag: 'Tag3-4', child: [
      LinkTag(
        id: 15,
        tag: 'Tag3-4-1',
      )
    ]),
  ];
}
