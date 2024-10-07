import 'package:currency/models/Currency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dio/dio.dart';

import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

// MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa'), // Persian
      ],
      theme: ThemeData(
        fontFamily: 'dana',
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

// Home
class Home extends StatefulWidget {
  Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Currency> currency = [];
  String systemTime = "";

  Future getResponse(BuildContext context) async {
    var url =
        "https://sasansafari.com/flutter/api.php?access_key=flutter123456";
    var dio = Dio();
    var response = await dio.get(url);
    if (currency.isEmpty) {
      if (response.statusCode == 200) {
        _showSnackBar(context, "بروزرسانی اطلاعات با موفقیت انجام شد");
        List jsonList = response.data;

        if (jsonList.isNotEmpty) {
          for (int i = 0; i < jsonList.length; i++) {
            setState(() {
              currency.add(Currency(
                  id: jsonList[i]["id"],
                  title: jsonList[i]["title"],
                  price: jsonList[i]["price"],
                  changes: jsonList[i]["changes"],
                  status: jsonList[i]["status"]));
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResponse(context);
  }

  @override
  Widget build(BuildContext context) {
    systemTime = _getTime();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          const SizedBox(
            width: 12,
          ),
          Image.asset(
            "assets/images/money_bag.png",
            height: 40,
            width: 40,
          ),
          const SizedBox(
            width: 12,
          ),
          Text("قیمت بروز ارز", style: Theme.of(context).textTheme.titleLarge),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                "assets/images/menu2.png",
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/quest.png",
                  height: 32,
                  width: 32,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  "نرخ ارز آزاد چیست؟",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "نرخ ارز به زبان ساده عبارت است از مقدار پولی که باید در ازای دریافت یک واحد پولی خارجی پرداخت کنیم.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 130, 130, 130),
                  borderRadius: BorderRadius.circular(100),
                ),
                height: 30,
                width: double.infinity,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "نام آزاد ارز",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    Text(
                      "قیمت",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    Text(
                      "تغییر",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Box items
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height/2,
              // List Item
              child: buildListView()
            ),
            // Box Button
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                height: MediaQuery.of(context).size.height/16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height/16,
                        width: 120,
                        child: TextButton.icon(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.blue[200])),
                          icon: const Icon(
                            CupertinoIcons.refresh,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            currency.clear();
                            buildListView();

                            _showSnackBar(context, "بروزرسانی با موفقیت انجام شد");
                            setState(() {
                              getResponse(context);

                            });
                          },
                          label: const Text(
                            "بروزرسانی",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Text("آخرین بروزرسانی $systemTime"),
                      const SizedBox(
                        width: 4,
                      ),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // List View
  ListView buildListView() {
    return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: currency.length,
                    itemBuilder: (BuildContext context, int position) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: MyItem(currency, position),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      if (index % 9 == 0) {
                        return const Ads();
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.green,
    ));
  }

  String _getTime() {
    DateTime now = DateTime.now();
    return "${now.hour}:${now.minute}:${now.second}";
  }
}

// MyItem
class MyItem extends StatelessWidget {
  int position;
  List<Currency> currency;

  MyItem(this.currency, this.position);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1,
            ),
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(currency[position].title!),
          Text(currency[position].price!),
          Text(
            currency[position].changes!,
            style: currency[position].status == "p"
                ? const TextStyle(color: Colors.green)
                : const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

// Ads
class Ads extends StatelessWidget {
  const Ads({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 1,
              ),
            ]),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("تبلیغات"),
          ],
        ),
      ),
    );
  }
}
