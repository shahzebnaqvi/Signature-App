import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

void main() {
  runApp(MyApp());
}

HandSignatureControl control = HandSignatureControl(
  threshold: 0.01,
  smoothRatio: 0.65,
  velocityRange: 2.0,
);

ValueNotifier<String?> svg = ValueNotifier<String?>(null);

ValueNotifier<ByteData?> rawImage = ValueNotifier<ByteData?>(null);

ValueNotifier<ByteData?> rawImageFit = ValueNotifier<ByteData?>(null);

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool get scrollTest => false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Signature"),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints.expand(),
                        color: Colors.white,
                        child: HandSignaturePainterView(
                          control: control,
                          type: SignatureDrawType.shape,
                        ),
                      ),
                      CustomPaint(
                        painter: DebugSignaturePainterCP(
                          control: control,
                          cp: false,
                          cpStart: false,
                          cpEnd: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildImageView(),
                    _buildScaledImageView(),
                    _buildSvgView(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    padding: EdgeInsets.only(right: 70, left: 70),
                    onPressed: () {
                      control.clear();
                      svg.value = null;
                      rawImage.value = null;
                      rawImageFit.value = null;
                    },
                    child: Text('clear'),
                  ),
                  CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    padding: EdgeInsets.only(right: 70, left: 70),
                    onPressed: () async {
                      svg.value = control.toSvg(
                        color: Colors.black,
                        size: 2.0,
                        maxSize: 15.0,
                        type: SignatureDrawType.shape,
                      );

                      rawImage.value = await control.toImage(
                        color: Colors.blueAccent,
                        background: Colors.greenAccent,
                        fit: false,
                      );

                      rawImageFit.value = await control.toImage(
                        color: Colors.blueAccent,
                        background: Colors.greenAccent,
                      );
                    },
                    child: Text('export'),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageView() => Container(
        width: 120.0,
        height: 96.0,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white30,
        ),
        child: ValueListenableBuilder<ByteData?>(
          valueListenable: rawImage,
          builder: (context, data, child) {
            if (data == null) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Text(' png'),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.memory(data.buffer.asUint8List()),
              );
            }
          },
        ),
      );

  Widget _buildScaledImageView() => Container(
        width: 120.0,
        height: 96.0,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white30,
        ),
        child: ValueListenableBuilder<ByteData?>(
          valueListenable: rawImageFit,
          builder: (context, data, child) {
            if (data == null) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Text('zoom png'),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.memory(data.buffer.asUint8List()),
              );
            }
          },
        ),
      );

  Widget _buildSvgView() => Container(
        width: 120.0,
        height: 96.0,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white30,
        ),
        child: ValueListenableBuilder<String?>(
          valueListenable: svg,
          builder: (context, data, child) {
            return HandSignatureView.svg(
              data: data,
              padding: EdgeInsets.all(8.0),
              placeholder: Container(
                color: Colors.white,
                child: Center(
                  child: Text('svg'),
                ),
              ),
            );
          },
        ),
      );
}
