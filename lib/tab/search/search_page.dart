import 'package:flutter/material.dart';
import 'package:gomoph/create/create_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  final List<String> _urls = const [
    'https://cdn.cwoneconomy.com/news/photo/202307/817_768_4635.jpg',
    'https://ojsfile.ohmynews.com/STD_IMG_FILE/2017/0725/IE002193665_STD.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Bruce_Lee_1973.jpg/250px-Bruce_Lee_1973.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Bruce_Lee_1973.jpg/250px-Bruce_Lee_1973.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder:
             (context) => const CreatePage()),
          );
        },
        child: const Icon(Icons.create),
      ),
      appBar: AppBar(
        title: const Text('Instagram Clone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: GridView.builder(
            itemCount: _urls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            ), // 3열
            itemBuilder: (BuildContext context, int index) {
              final url = _urls[index];
              return Image.network(
                url,
                fit: BoxFit.cover,
              );
            },
        ),
      ),
    );
  }
}
