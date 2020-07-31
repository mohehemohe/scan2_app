import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WardRounds',
      initialRoute: '/',
      routes: {
        '/': (_) => new MyHomePage(),
        '/LineChartSample1': (_) => new LineChartSample1()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key key, this.title}) : super(key: key);

  // final String title;

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  ScanResult scanResult;

  Future _scan() async {
    try {
      var result = await BarcodeScanner.scan();
      result.rawContent = "00000001"; // あとで消す

      //データ取得開始

      //患者基本データ
      DocumentSnapshot docSnapshotBASIC =
      await Firestore.instance.collection(result.rawContent).document("BASIC").get();
      Map<String, dynamic> record = docSnapshotBASIC.data;
      var basiclist = [record["name"],record["year"],record["month"],record["day"],record["bloodtype"]];

      //バイタルデータ
      DocumentSnapshot docSnapshotvitalA1 =
      await Firestore.instance.collection(result.rawContent).document("20200712").get();
      Map<String, dynamic> recordA1 = docSnapshotvitalA1.data;
      var datalistA1 = [recordA1["temp"],recordA1["pulse"],recordA1["pressure1"],recordA1["pressure2"]];

      DocumentSnapshot docSnapshotvitalA2 =
      await Firestore.instance.collection(result.rawContent).document("20200713").get();
      Map<String, dynamic> recordA2 = docSnapshotvitalA2.data;
      var datalistA2 = [recordA2["temp"],recordA2["pulse"],recordA2["pressure1"],recordA2["pressure2"]];

      DocumentSnapshot docSnapshotvitalA3 =
      await Firestore.instance.collection(result.rawContent).document("20200714").get();
      Map<String, dynamic> recordA3 = docSnapshotvitalA1.data;
      var datalistA3 = [recordA3["temp"],recordA3["pulse"],recordA3["pressure1"],recordA3["pressure2"]];

      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => LineChartSample1(patientNo: result.rawContent, basiclist:basiclist,datalistA1: datalistA1,datalistA2: datalistA2,datalistA3: datalistA3))
      );
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'カメラへのアクセスが許可されていません!';
        });
      } else {
        result.rawContent = 'エラー: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var contentList = <Widget>[
      ListTile(
        title: Text("ボタンを押してカメラを起動してください"),
        subtitle: Text("カメラをQRコードに向けてください"),
      ),
    ];
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text("QR Reader"),
          ),
          body: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: contentList,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _scan,
            tooltip: 'Scan',
            child: Icon(Icons.camera),
          ),
        )
    );
  }
}

class LineChartSample1 extends StatefulWidget {
  final String patientNo;
  final basiclist;
  final datalistA1;
  final datalistA2;
  final datalistA3;
  LineChartSample1({Key key, this.patientNo,this.basiclist,this.datalistA1,this.datalistA2,this.datalistA3}): super(key: key);

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    String patientName = widget.basiclist[0];
    DateTime birthday = DateTime(widget.basiclist[1], widget.basiclist[2], widget.basiclist[3]);
    var age = yearToAge(birthday.year, birthday.month, birthday.day);
    String bloodType = widget.basiclist[4];

    var contentList = <Widget>[
      const SizedBox(
        height: 5,
      ),
      new Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey
          ),
          height: 70.0,
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("　" + widget.patientNo,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text("　" + patientName,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ]
                ),
                new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("　生年月日：" + birthday.year.toString() + "年" + birthday.month.toString() + "月" + birthday.day.toString() + "日 (" + age.toString() + "歳)",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text("　血液型：" + bloodType + "型",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ]
                )
              ]
          )
      ),
      const SizedBox(
        height: 5,
      ),
      new  AspectRatio(
        aspectRatio: 1.23,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
              colors: const [
                Color(0xff2c274c),
                Color(0xff46426c),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 37,
                  ),
                  const Text(
                    'Vital',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 37,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                      child: LineChart(
                        isShowingMainData ? sampleData1() : sampleData2(),
                        swapAnimationDuration: const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    ];
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('カルテ'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: contentList,
      ),
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return '7/12';
              case 7:
                return '7/13';
              case 12:
                return '7/14';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '35.5℃';
              case 2:
                return '36.0℃';
              case 3:
                return '36.5℃';
              case 4:
                return '37.0℃';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
        rightTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '50mmHg';
              case 2:
                return '60mmHg';
              case 3:
                return '70mmHg';
              case 4:
                return '80mmHg';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 0,
      maxX: 14,
      maxY: 110,
      minY: 0,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: [
        FlSpot(1, double.parse(widget.datalistA1[0])),
        FlSpot(7, double.parse(widget.datalistA2[0])),
        FlSpot(13, double.parse(widget.datalistA3[0])),
      ],
      isCurved: true,
      colors: [
        const Color(0xff4af699),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    final LineChartBarData lineChartBarData2 = LineChartBarData(
      spots: [
        FlSpot(1, double.parse(widget.datalistA1[1])),
        FlSpot(7, double.parse(widget.datalistA2[1])),
        FlSpot(13, double.parse(widget.datalistA3[1])),
      ],
      isCurved: true,
      colors: [
        const Color(0xffaa4cfc),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(show: false, colors: [
        const Color(0x00aa4cfc),
      ]),
    );
    final LineChartBarData lineChartBarData3 = LineChartBarData(
      spots: [
        FlSpot(1, double.parse(widget.datalistA1[2])),
        FlSpot(7, double.parse(widget.datalistA2[2])),
        FlSpot(13, double.parse(widget.datalistA3[2])),
      ],
      isCurved: true,
      colors: const [
        Color(0xff27b6fc),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    final LineChartBarData lineChartBarData4 = LineChartBarData(
      spots: [
        FlSpot(1, double.parse(widget.datalistA1[3])),
        FlSpot(7, double.parse(widget.datalistA2[3])),
        FlSpot(13, double.parse(widget.datalistA3[3])),
      ],
      isCurved: true,
      colors: const [
        Color(0xff27b6fc),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    return [
      lineChartBarData1,
      lineChartBarData2,
      lineChartBarData3,
      lineChartBarData4,
    ];
  }

  LineChartData sampleData2() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: false,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'SEPT';
              case 7:
                return 'OCT';
              case 12:
                return 'DEC';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1m';
              case 2:
                return '2m';
              case 3:
                return '3m';
              case 4:
                return '5m';
              case 5:
                return '6m';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
        rightTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1m';
              case 2:
                return '2m';
              case 3:
                return '3m';
              case 4:
                return '5m';
              case 5:
                return '6m';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(
              color: Color(0xff4e4965),
              width: 4,
            ),
            left: BorderSide(
              color: Colors.transparent,
            ),
            right: BorderSide(
              color: Colors.transparent,
            ),
            top: BorderSide(
              color: Colors.transparent,
            ),
          )),
      minX: 0,
      maxX: 14,
      maxY: 6,
      minY: 0,
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
    return [
      LineChartBarData(
        spots: [
          FlSpot(1, 1),
          FlSpot(3, 4),
          FlSpot(5, 1.8),
          FlSpot(7, 5),
          FlSpot(10, 2),
          FlSpot(12, 2.2),
          FlSpot(13, 1.8),
        ],
        isCurved: true,
        curveSmoothness: 0,
        colors: const [
          Color(0x444af699),
        ],
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
      LineChartBarData(
        spots: [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
        ],
        isCurved: true,
        colors: const [
          Color(0x99aa4cfc),
        ],
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(show: true, colors: [
          const Color(0x33aa4cfc),
        ]),
      ),
      LineChartBarData(
        spots: [
          FlSpot(1, 3.8),
          FlSpot(3, 1.9),
          FlSpot(6, 5),
          FlSpot(10, 3.3),
          FlSpot(13, 4.5),
        ],
        isCurved: true,
        curveSmoothness: 0,
        colors: const [
          Color(0x4427b6fc),
        ],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ];
  }
}

num yearToAge(num year, num month, num day) {
  //今日
  var now = new DateTime.now();

  // 生年月日
  var birthday = new DateTime(year, month, day);

  // 今年の誕生日
  var thisYearBirthday = new DateTime(now.year, month, day);

  //今年-誕生年
  var age = now.year - birthday.year;

  //今年の誕生日を迎えていなければage-1を返す
  if (thisYearBirthday.isAfter(now)) {
    age = age - 1;
  }
  return age;
}