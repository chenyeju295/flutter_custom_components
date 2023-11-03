import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'linkage_list_provider.dart';

class LinkageListPage extends StatefulWidget {
  const LinkageListPage({super.key});

  @override
  State<LinkageListPage> createState() => _LinkageListPageState();
}

class _LinkageListPageState extends State<LinkageListPage> {
  ScrollController leftController = ScrollController();
  ScrollController rightController = ScrollController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => LinkageListProvider(),
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final provider = context.read<LinkageListProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SizedBox(
        height: 500,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 80,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey, width: 1))),
            child: SingleChildScrollView(
                controller: leftController,
                child: Column(children: [
                  ...provider.linkageList.asMap().entries.map((v) => GestureDetector(
                        onTap: () {
                          rightController.jumpTo(
                            rightController.position.maxScrollExtent,
                          );
                        },
                        child: Container(
                          key: v.value.tagKey,
                          color: currentIndex == v.key ? Colors.red.withOpacity(.2) : Colors.white,
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            style: TextStyle(fontSize: 16),
                            v.value.tag ?? '',
                          ),
                        ),
                      ))
                ])),
          ),
          Expanded(
              child: ListViewObserver(
            onObserve: (_) {
              currentIndex = _.firstChild?.index ?? 0;
              setState(() {});
            },
            child: ListView.separated(
              controller: rightController,
              itemCount: provider.linkageList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = provider.linkageList[index];
                return Container(
                  padding: EdgeInsets.all(28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      item.tag ?? '',
                      style: TextStyle(fontSize: 16),
                    ),
                    Wrap(
                      children: [
                        ...?item.child?.map((e) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                e.tag ?? '',
                              ),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: provider.linkageList.length == index + 1 ? 400 : 0,
                    )
                  ]),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          ))
        ]),
      ),
    );
  }
}
