import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_overview_17/app_provider.dart';
import 'package:provider_overview_17/success_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppProvider>(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'addListener of ChangeNotifier',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  String? searchTerm;
  late final AppProvider appProvider;

  @override
  void initState() {
    super.initState();
    appProvider = context.read<AppProvider>();
    appProvider.addListener(appListener);
  }

  void appListener() {
    if (appProvider.state == AppState.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return SuccessPage();
          },
        ),
      );
    } else if (appProvider.state == AppState.error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Something went wrong'),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    appProvider.removeListener(appListener);
    super.dispose();
  }

  void submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    final form = formKey.currentState;

    if (form == null || !form.validate()) return;

    form.save();

    context.read<AppProvider>().getResult(searchTerm!);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) {
    //       return SuccessPage();
    //     },
    //   ),
    // );
    //
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       content: Text('Something went wrong'),
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>().state;

    // if (appState == AppState.success) {
    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) {
    //           return SuccessPage();
    //         },
    //       ),
    //     );
    //   });
    // } else if (appState == AppState.error) {
    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //     showDialog(
    //       context: context,
    //       builder: (context) {
    //         return AlertDialog(
    //           content: Text('Something went wrong'),
    //         );
    //       },
    //     );
    //   });
    // }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: formKey,
              autovalidateMode: autovalidateMode,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Search'),
                      prefixIcon: Icon(Icons.search),
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Search term required';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      searchTerm = value;
                    },
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    child: Text(
                      appState == AppState.loading
                          ? 'Loading...'
                          : 'Get Result',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    onPressed: appState == AppState.loading ? null : submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
