import 'package:flutter/material.dart';
import 'package:collection/collection.dart';


import '../../models/poll.dart';
import '../my_scaffold.dart';
import '../../services/api.dart';
import '../../etc/utils.dart';
import '../poll_results/poll_results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Poll>? _polls;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadData();
  }

  _loadData() async {
    // todo: Load list of polls here
    var apiClient = ApiClient();
    var res = await apiClient.callApi(HttpMethod.get, "/api/polls");
    var data = res.data;
    setState(() {
      _polls = data.map<Poll>((d) {
        return Poll.fromJson({
          'id': d['id'],
          'question': d['question'],
          'choices': d['choices']
        });
      }).toList();
      _isLoading = false;
    });
  }

  _getVoteResult(int questionId) async {
    var apiClient = ApiClient();
    var res = await apiClient.callApi(HttpMethod.get, "/api/polls/$questionId/results");
    return res.data;
  }

  _vote(int pollId, String ans) async {
    var apiClient = ApiClient();
    var params = {
      "answer": ans
    };
    setState(() {
      _isLoading = true;
    });
    var res = await apiClient.callApi(HttpMethod.post, "/api/polls/$pollId", params);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Column(
        children: [
          Image.network('https://cpsu-test-api.herokuapp.com/images/election.jpg'),
          Expanded(
            child: Stack(
              children: [
                if (_polls != null) _buildList(),
                if (_isLoading) _buildProgress(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _polls!.length,
      itemBuilder: (BuildContext context, int index) {
        // todo: Create your poll item by replacing this Container()
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_polls![index].id}. ${_polls![index].question}"),
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _polls![index].choices.map<Widget>((c) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: TextButton(
                        onPressed: () async {
                          await _vote(_polls![index].id, c);
                          if(!context.mounted) return;
                          showOkDialog(context, "SUCCESS", "โหวตตัวเลือก '$c' ของโพลคำถามช้อ ${_polls![index].id} สำเร็จ");
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.black12
                                ),
                                borderRadius: BorderRadius.circular(5),
                            ))
                        ),
                        child: Text(c),

                      ),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          var voteResult = await _getVoteResult(_polls![index].id);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PollResultsPage(question: _polls![index].question, vote: voteResult)),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: Text("ดูผลโหวต"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('รอสักครู่', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
