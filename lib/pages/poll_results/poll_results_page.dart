import 'package:election_2566_poll/pages/my_scaffold.dart';
import 'package:flutter/material.dart';
import '../../models/poll.dart';

class PollResultsPage extends StatelessWidget {
  final String question;
  final List vote;
  //const PollResultsPage({Key? key}) : super(key: key);
  const PollResultsPage({super.key, required this.question, required this.vote});

  @override
  Widget build(BuildContext context) {
    print(vote);

    var voteRowWidget = vote.map((v) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          //color: Colors.red,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.5,
                color: Colors.black12
              )
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(v['choice']),
              Text(
                  '${v['count']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
      );
    }).toList();

    return MyScaffold(
      appBar: AppBar(title: const Text('ผลโหวต')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // todo: Add your UI by replacing this Container()
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              child: Column(
                children: [
                  Text(question, style: TextStyle(
                    fontSize: 20
                  )),
                  const SizedBox(height: 20),
                  ...voteRowWidget
                ],
              ),
            )
          ]
        ),
      ),
    );
  }
}
