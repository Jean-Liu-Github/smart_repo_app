import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';
// import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Repo~',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginPage(title: 'Smart Repo'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 用户名/密码输入框焦点控制
  final _usernameFN= FocusNode();
  final _passwordFN = FocusNode();

  // 用户名/密码文本控制
  final _usernameTEC = TextEditingController();
  final _passwordTEC = TextEditingController();

  // 抖动动画控制器
  final _usernameSAC = ShakeAnimationController();
  final _passwordSAC = ShakeAnimationController();

  // Stream 更新操作控制器
  final _usernameSC = StreamController<String?>();
  final _passwordSC = StreamController<String?>();


  @override
  Widget build(BuildContext context) {
    //手势识别点击空白隐藏键盘
    return GestureDetector(
      onTap: () {
        hindKeyBoarder();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.indigo,
        ),
        //登录页面的主体
        body: buildLoginWidget(),
      ),
    );
  }

  void hindKeyBoarder() {
    //输入框失去焦点
    _usernameFN.unfocus();
    _passwordFN.unfocus();

    //隐藏键盘
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  //登录页面的主体
  Widget buildLoginWidget() {
    return Container(
      margin: const EdgeInsets.all(30.0),
      //线性布局
      child: Column(
        children: [
          //用户名输入框
          buildUserNameWidget(),
          const SizedBox(
            height: 20,
          ),
          //用户密码输入框
          buildPasswordWidget(),
          const SizedBox(
            height: 40,
          ),
          //登录按钮
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              child: const Text("登录"),
              // TODO(style)
              onPressed: () {
                checkLoginFunction();
              },
            ),
          )
        ],
      ),
    );
  }

  ///用户名输入框 Stream 局部更新 error提示
  ///     ShakeAnimationWidget 抖动动画
  ///
  StreamBuilder<String?> buildUserNameWidget() {
    return StreamBuilder<String?>(
      stream: _usernameSC.stream,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        return ShakeAnimationWidget(
          //微左右的抖动
          shakeAnimationType: ShakeAnimationType.LeftRightShake,
          //设置不开启抖动
          isForward: false,
          //抖动控制器
          shakeAnimationController: _usernameSAC,
          child: TextField(
            //焦点控制
            focusNode: _usernameFN,
            //文本控制器
            controller: _usernameTEC,
            //键盘回车键点击回调
            onSubmitted: (String value) {
              //点击校验，如果有内容输入 输入焦点跳入下一个输入框
              if (checkUsername()) {
                _usernameFN.unfocus();
                FocusScope.of(context).requestFocus(_passwordFN);
              } else {
                FocusScope.of(context).requestFocus(_usernameFN);
              }
            },
            //边框样式设置
            decoration: InputDecoration(
              //红色的错误提示文本
              errorText: snapshot.data,
              labelText: "用户名",
              //设置上下左右 都有边框
              //设置四个角的弧度
              border: const OutlineInputBorder(
                //设置边框四个角的弧度
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        );
      },
    );
  }

  StreamBuilder<String?> buildPasswordWidget() {
    return StreamBuilder<String?>(
      stream: _passwordSC.stream,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        return ShakeAnimationWidget(
          //微左右的抖动
          shakeAnimationType: ShakeAnimationType.LeftRightShake,
          //设置不开启抖动
          isForward: false,
          //抖动控制器
          shakeAnimationController: _passwordSAC,
          child: TextField(
            focusNode: _passwordFN,
            controller: _passwordTEC,
            onSubmitted: (String value) {
              if (checkPassword()) {
                loginFunction();
              } else {
                FocusScope.of(context).requestFocus(_passwordFN);
              }
            },
            //隐藏输入的文本
            obscureText: true,
            //最大可输入1行
            maxLines: 1,
            //边框样式设置
            decoration: InputDecoration(
              labelText: "密码",
              errorText: snapshot.data,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        );
      },
    );
  }

  bool checkUsername() {
    //获取输入框中的输入文本
    String username = _usernameTEC.text;
    if (username.isEmpty) {
      //Stream 事件流更新提示文案
      _usernameSC.add("请输入用户名");
      //抖动动画开启
      _usernameSAC.start();
      return false;
    } else {
      //清除错误提示
      _usernameSC.add(null);
      return true;
    }
  }

  bool checkPassword() {
    String password = _passwordTEC.text;
    if (password.length < 6) {
      _passwordSC.add("请输入标准密码");
      _passwordSAC.start();
      return false;
    } else {
      _passwordSC.add(null);
      return true;
    }
  }

  void checkLoginFunction() {
    var hasUserName = checkUsername();
    var hasPassword = checkPassword();
      if(!hasUserName) {
        FocusScope.of(context).requestFocus(_usernameFN);
        return;
      }
      if (!hasPassword) {
        FocusScope.of(context).requestFocus(_passwordFN);
        return;
      }
      // TODO("登录逻辑")
  }

  void loginFunction() {

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have clicked the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
