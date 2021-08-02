import 'package:envel_flutter/account_list/account_list_page.dart';
import 'package:envel_flutter/auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'models/acount_model.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyFutureBuilder(),
    );
  }
}

class MyFutureBuilder extends StatefulWidget {
  const MyFutureBuilder({Key? key}) : super(key: key);

  @override
  State createState() => _MyFutureBuilderState();
}

class _MyFutureBuilderState extends State<MyFutureBuilder> {
  Future<dynamic>? _future;

  @override
  void initState() {
    super.initState();

    _future = Auth().getClient();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String token = snapshot.data!.credentials.accessToken;
            return MyHomePage(title: 'Envel Account App', token: token);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title, required this.token}) : super(key: key);
  final String title;
  final String token;

  final String queryAccounts = """
      query getAccounts {
        accounts {
          id
          balance
        }
      } 
    """;

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      '/graphql',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    final Link link = authLink.concat(httpLink);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Query(
          options: QueryOptions(
            document: gql(queryAccounts),
          ),
          builder: (QueryResult result, {refetch, fetchMore}) {
            if (result.data == null && !result.hasException) {
              return const Text(
                'Loading has completed, but both data and errors are null. '
                'This should never be the case – please open an issue',
              );
            }

            if (result.hasException) {
              return const Text("Something went wrong");
            } else {
              // result.data can be either a [List<dynamic>] or a [Map<String, dynamic>]
              final accounts = (result.data!['accounts'] as List<dynamic>);

              return AccountListPage(
                  accounts.map((dAccount) => AccountModel(dAccount!['id'], dAccount!['balance'])).toList(),
                  () => refetch!());
            }
          },
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
