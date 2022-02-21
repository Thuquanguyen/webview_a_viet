import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_play/widget/item_navigation.dart';

const String KEY_ID = 'ID';
const String KEY_PASSWORD = 'PASSWORD';
const String CHANEL_NAME = 'USERNAME';
const String CHECK_LOGIN = 'CHECKLOGIN';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({Key? key}) : super(key: key);

  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _webViewController;
  late WebViewController _webViewEduController;
  String url = "https://edu.playcoding.ac/login/";
  String urlHome = "https://edu.playcoding.ac/login/";
  String urlWebEdu = 'https://www.24h.com.vn';
  bool isShowLoading = false;
  bool isShowWebEduLoading = false;
  bool isAutoLogin = false;
  bool isLoginSuccess = true;
  final storage = const FlutterSecureStorage();
  String id = "";
  String password = "";
  int tab = 0;
  int index = 0;
  bool isEduWeb = false;
  bool isShowWebEdu = false;

  @override
  void initState() {
    // TODO: implement initState
    getLocal();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    } // <<== THIS
    super.initState();
  }

  @override
  void activate() {
    // TODO: implement activate
    _webViewController.clearCache();
    super.activate();
  }

  void getLocal() async {
    String iD = await storage.read(key: KEY_ID) ?? '';
    String passWord = await storage.read(key: KEY_PASSWORD) ?? '';
    setState(() {
      id = iD;
      password = passWord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Expanded(
            child: Stack(
          children: [
            WebView(
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                  _webViewController = webViewController;
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.url
                      .startsWith('https://edu-code.playcoding.ac/') && !request.url
                      .startsWith('https://edu-code.playcoding.ac/pca-login')) {
                    setState(() {
                      urlWebEdu = request.url;
                      isShowWebEduLoading = true;
                      isShowWebEdu = true;
                    });
                    return NavigationDecision.prevent;
                  }
                  
                  return NavigationDecision.navigate;
                },
                onPageStarted: (a) {
                  setState(() {
                    isShowLoading = true;
                  });
                },
                onPageFinished: (a) {
                  _webViewController.evaluateJavascript(
                      "document.getElementsByClassName('ft_menus')[0].style.display = 'none';");
                  if (a.contains("https://edu.playcoding.ac/login/")) {
                    _webViewController.evaluateJavascript(
                        "document.getElementsByName('login')[0].onclick=function(){localStorage.setItem('userpass', document.getElementById('username').value+'|'+document.getElementById('password').value);};");
                    if (id.isNotEmpty &&
                        id != "<null>" &&
                        password != "<null>" &&
                        password.isNotEmpty &&
                        !isAutoLogin) {
                      _webViewController.evaluateJavascript(
                          "document.getElementById('username').value = \"$id\";document.getElementById('password').value = \"$password\";document.getElementsByName('login')[0].click();");
                    }
                    _webViewController.evaluateJavascript(
                        "$CHANEL_NAME.postMessage(localStorage.getItem('userpass'));");
                  }
                  _webViewController.evaluateJavascript(
                      "$CHECK_LOGIN.postMessage(document.getElementsByName('login').length > 0);");
                  setState(() {
                    isShowLoading = false;
                    index = index + 1;
                  });
                },
                javascriptChannels: <JavascriptChannel>{
                  _getPInfoChannel(),
                  _checkLogin()
                }),
            if (isShowWebEdu)
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 75,
                  color: Colors.white,
                  child: WebView(
                      initialUrl: urlWebEdu,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        // _controllerEdu.complete(webViewController);
                        _webViewEduController = webViewController;
                      },
                      onPageStarted: (a) {
                        setState(() {
                          isShowWebEduLoading = true;
                        });
                      },
                      onPageFinished: (a) {
                        setState(() {
                          isShowWebEduLoading = false;
                        });
                      })),
            Visibility(
              child: Container(
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
              ),
              visible: isShowLoading,
            ),
          ],
        )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              children: [
                ItemNavigation(
                    iconData: Icons.home,
                    title: "Home",
                    callBack: () {
                      setState(() {
                        isAutoLogin = false;
                        tab = 0;
                        _webViewController.loadUrl(urlHome);
                      });
                    }),
                if (!isLoginSuccess)
                  ItemNavigation(
                      iconData: Icons.login,
                      title: "Login",
                      callBack: () {
                        setState(() {
                          tab = -1;
                          url = "https://edu.playcoding.ac/login/";
                          _webViewController.loadUrl(url);
                        });
                      }),
                ItemNavigation(
                    iconData: Icons.add_shopping_cart,
                    title: "Shopping",
                    callBack: () {
                      setState(() {
                        tab = 1;
                        url = "https://edu.playcoding.ac/courses/";
                        _webViewController.loadUrl(url);
                      });
                    }),
                favoriteButton(
                    iconData: Icons.arrow_back, title: "Back", index: 0),
                favoriteButton(
                    iconData: Icons.arrow_forward, title: "Forward", index: 1),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            height: 75,
            color: Colors.white,
          ),
        )
      ],
    ));
  }

  Widget favoriteButton(
      {required IconData iconData, required String title, required int index}) {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return ItemNavigation(
                iconData: iconData,
                title: title,
                callBack: () {
                  if (index == 0) {
                    if (isShowWebEdu) {
                      print('1111111111111111111');
                      setState(() {
                        isShowWebEdu = false;
                        isShowWebEduLoading = false;
                        urlWebEdu = '';
                        _webViewEduController.loadUrl(urlWebEdu);
                      });
                    } else {
                      print('2222222222222222');
                      controller.data?.goBack();
                    }
                  } else {
                    controller.data?.goForward();
                  }
                  setState(() {
                    tab = 2;
                  });
                });
          }
          return Container();
        });
  }

  JavascriptChannel _getPInfoChannel() {
    return JavascriptChannel(
        name: CHANEL_NAME,
        onMessageReceived: (JavascriptMessage message) async {
          String data = message.message;
          if (data.length >= 3) {
            await storage.write(key: KEY_ID, value: data.split('|')[0]);
            await storage.write(key: KEY_PASSWORD, value: data.split('|')[1]);
            print("ID: ${data.split('|')[0]} - Pass: ${data.split('|')[1]}");
          }
        });
  }

  JavascriptChannel _checkLogin() {
    return JavascriptChannel(
        name: CHECK_LOGIN,
        onMessageReceived: (JavascriptMessage message) async {
          String data = message.message;
          print("CHEKC CHECK ${data.contains("1")} - index : $index");
          if (!isAutoLogin) {
            setState(() {
              if (data.contains("1")) {
                isLoginSuccess = false;
              } else {
                isLoginSuccess = true;
              }
            });

            if (data.contains("1") && index >= 2) {
              print("VAO DAY DAY DAY ");
              setState(() {
                isShowLoading = true;
                urlHome = "https://edu.playcoding.ac/";
                _webViewController.loadUrl(urlHome);
                isLoginSuccess = false;
                isAutoLogin = true;
                index = 0;
              });
            } else {
              setState(() {
                isLoginSuccess = true;
                isAutoLogin = false;
              });
            }
          } else {
            if (data.contains("0") && tab == -1) {
              setState(() {
                isLoginSuccess = true;
                index = 0;
                tab = 1;
              });
            }
          }
          if (index >= 2) {
            setState(() {
              isAutoLogin = true;
            });
          }
        });
  }
}
