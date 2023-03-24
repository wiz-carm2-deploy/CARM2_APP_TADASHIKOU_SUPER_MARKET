// @dart=2.9
import 'package:carm2_base/app/app_functions/attributes_editor/blocs/attribute_editor_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/screen/attribute_editor_screen.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/view_models/attribute_input_data.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/widgets/attribute_inputs.dart';
import 'package:carm2_base/app/app_functions/login_service/blocs/login_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/login_service/blocs/member_registration_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/login_service/blocs/password_reset_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/login_service/models/credentials.dart';
// import 'package:carm2_base/app/app_functions/login_service/ui/widgets/member_registration_screen.dart';
// import 'package:carm2_base/app/app_functions/login_service/ui/widgets/password_reset_screen.dart';
import 'package:carm2_base/app/app_settings.dart';
import 'package:carm2_base/app/blocs/navigation_bloc.dart';
import 'package:carm2_base/app/resources/models/app_func.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute_value.dart';
import 'package:carm2_base/app/resources/models/attributes/attributes.dart';
import 'package:carm2_base/app/resources/models/main_widgets.dart';
import 'package:carm2_base/app/ui/widgets/custom_input_label.dart';
import 'package:carm2_base/app/ui/widgets/custom_status_bar.dart';
import 'package:carm2_base/app/ui/widgets/loading_screen.dart';
import 'package:carm2_base/app/ui/widgets/stream_snack_bar.dart';
import 'package:carm2_base/app/util/navigator_state_carm2.dart';
import 'package:carm2_base/app/util/kyoroman_colors.dart';
import 'package:carm2_base/app/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:carm2_app_project/app/app_functions/login_service/ui/widgets/member_registration_screen.dart';
import 'package:carm2_app_project/app/app_functions/login_service/ui/widgets/password_reset_screen.dart';

class LoginScreenData {
  /// ID, パスワード入力
  final List<LoginInput> inputs;

  /// ログインボタン
  final LoginInput submitButton;

  /// 新規登録可能フラグ
  final bool canSignUp;

  /// 新規会員の登録画面に表示する会員属性入力
  final Attributes attributes;

  /// ログインせずに進むボタン
  final LoginInput continueWithoutLoginButton;

  final bool displayBackButton;

  final bool displayPasswordResetButton;

  /// 新規会員登録画面に表示するパスワード説明
  final String passwordDescription;

  /// 新規会員登録画面に表示するパスワード説明
  final String emailDescription;

  final String passwordResetDescription;

  LoginScreenData({
    @required this.inputs,
    @required this.submitButton,
    @required this.canSignUp,
    this.attributes,
    this.continueWithoutLoginButton,
    this.displayBackButton,
    @required this.displayPasswordResetButton,
    this.passwordDescription,
    this.emailDescription,
    this.passwordResetDescription,
  });

  factory LoginScreenData.fromAppFunc(AppFunc appFunc) {
    /// test, get [LoginInput] fields from all [TextWidget] in [mainWidget]
    final MainWidgets mainWidgets = appFunc.screenLayout.mainWidgets;
    final List<LoginInput> _inputs = mainWidgets.textWidgets
        .map((textWidget) => LoginInput(
            label: textWidget.content,
            inputType: appFunc.useLoginIdColumn == 'account_id'
                ? LoginInputType.accountId
                : LoginInputType.email))
        .toList();

    /// ログインアプリ機能にテキストWidgetが設定されていなかったら
    /// 下記のでデフォルトラベルを使う
    if (_inputs.isEmpty) {
      _inputs.addAll([
        LoginInput(
            label: appFunc.useLoginIdColumn == 'account_id' ? 'ID' : 'EMAIL',
            inputType: appFunc.useLoginIdColumn == 'account_id'
                ? LoginInputType.accountId
                : LoginInputType.email),
        LoginInput(
          label: 'PASSWORD',
          inputType: LoginInputType.password,
        )
      ]);
    }

    /// test, get login button label from first button in [mainWidgets]
    final _submitButton = LoginInput(
      inputType: LoginInputType.submit,
      label: mainWidgets.buttonWidgets.first.content,
      backgroundColor: WidgetUtil.hexToColor(
          mainWidgets.buttonWidgets.first.backgroundColor),
    );

    LoginInput _continueButton;
    if (mainWidgets.buttonWidgets.length > 1) {
      _continueButton = LoginInput(
        inputType: LoginInputType.submit,
        label: mainWidgets.buttonWidgets.last.content,
        backgroundColor: WidgetUtil.hexToColor(
            mainWidgets.buttonWidgets.last.backgroundColor),
      );
    }

    return LoginScreenData(
      inputs: _inputs,
      submitButton: _submitButton,
      canSignUp: appFunc.canSignUp,
      attributes: appFunc.memberRegistrationAttributes,
      continueWithoutLoginButton: _continueButton,

      /// 一旦はヘッダーが設定されていれば、戻るボタンのAppBarを表示する
      displayBackButton: appFunc.screenLayout.hasHeader,
      // パスワードリセットボタンの表示、設定されていなければ表示しない
      displayPasswordResetButton:
          appFunc?.loginOptions?.isDisplayPasswordReset ?? false,
      passwordDescription: appFunc?.loginOptions?.passwordDescription,
      emailDescription: appFunc?.loginOptions?.emailDescription,
      passwordResetDescription: appFunc?.loginOptions?.passwordResetDescription,
    );
  }
}

enum LoginInputType {
  accountId,
  email,
  password,
  submit,
}

class LoginInput {
  final String label;
  final Color backgroundColor;
  final LoginInputType inputType;

  LoginInput({
    @required this.label,
    this.backgroundColor,
    @required this.inputType,
  });
}

class LoginScreen extends StatelessWidget {
  final LoginScreenData loginScreenData;

  const LoginScreen({
    Key key,
    this.loginScreenData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationBloc>(context, listen: false).pop();
        return false;
      },
      child: CustomStatusBar(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: loginScreenData.displayBackButton
              ? AppBar(
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Provider.of<NavigationBloc>(context, listen: false)
                            .pop();
                      }),
                )
              : null,
          body: StreamSnackBar(
            stream: Provider.of<LoginScreenBloc>(context, listen: false)
                .messageStream,
            title: 'ログインに失敗しました',
            backgroundColor: KyoromanColors.lightPurple,
            child: LoginForm(
              loginScreenData: loginScreenData,
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final LoginScreenData loginScreenData;

  const LoginForm({
    Key key,
    this.loginScreenData,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final String _keepLoggedInLabel = '次回から自動ログインする';
  final String _newMemberSubmitButtonLabel = 'アプリ会員登録';

  final _idInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  bool _obscurePassword = true;

  final List<AbstractAttributeInputData> _inputDataList = [];

  _submitForm() {
    final form = _formKey.currentState;
    if (form.validate() == false) {
      return;
    }

    //TODO: AppUser.idはわざわざNavigationBlocから取得するじゃなくて login_screen_bloc で準備した方がいい？
    final int _appUserId =
        Provider.of<NavigationBloc>(context, listen: false).appUser.id;

    final LoginInputType loginInputType =
        widget.loginScreenData.inputs.first.inputType;

    String _accountId;
    String _email;
    if (loginInputType == LoginInputType.accountId) {
      _accountId = _idInputController.text;
      _email = '';
    } else {
      _accountId = '';
      _email = _idInputController.text;
    }

    final List<AttributeValue> _attributeValues = [];
    _inputDataList.forEach((inputData) {
      _attributeValues.addAll(inputData.getAttributeValues());
    });

    final credentials = MemberApiCredentials(
      accountId: _accountId,
      email: _email,
      password: _passwordInputController.text,
      appUserId: _appUserId,
      appId: appSettings.appId,
      attributeValues: _attributeValues,
      apiToken: null,
    );

    print('credentials: ${credentials.toMap().toString()}');
    Provider.of<LoginScreenBloc>(context, listen: false).submit(credentials);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Provider.of<LoginScreenBloc>(context, listen: false).isLoggingIn,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return LoadingScreen();
        } else {
          return SingleChildScrollView(
            child: Builder(
              builder: (BuildContext context) => Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 50.0,
                          right: 50.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Image.asset(
                                    'assets/icon/top.png',
                                  ),
                                ),
                              ),
                            ),
                            // LoginAttributeDisplayArea(
                            //   inputDataList: _inputDataList,
                            //   attributeDecoration: AttributeDecoration(
                            //     primaryColor: Theme.of(context).primaryColor,
                            //     fillColor: Colors.white,
                            //     borderRadius: BorderRadius.all(
                            //       Radius.circular(12.0),
                            //     ),
                            //     labelTextStyle: TextStyle(
                            //       color: Colors.black,
                            //       fontSize: 18.0,
                            //     ),
                            //   ),
                            // ),

                            // account id field
                            CustomInputLabel(
                              label: widget.loginScreenData.inputs.first.label,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: TextFormField(
                                  controller: _idInputController,
                                  validator: (input) {
                                    final loginInputType = widget
                                        .loginScreenData.inputs.first.inputType;

                                    if (loginInputType ==
                                        LoginInputType.accountId) {
                                      // prevent japanese input
                                      final RegExp validCharacters =
                                          RegExp(r'^[a-zA-Z0-9-_]+$');
                                      if (validCharacters.hasMatch(input) ==
                                          false) {
                                        return '英文字を入力してください';
                                      }
                                    }

                                    return (input == null || input == '')
                                        ? '入力内容を再度お確かめください'
                                        : null;
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(left: 5.0),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      hintText: widget
                                          .loginScreenData.inputs.first.label,
                                      filled: true,
                                      fillColor: Colors.white54),
                                ),
                              ),
                            ),

                            // password field
                            CustomInputLabel(
                              label: widget.loginScreenData.inputs.last.label,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: _passwordInputController,
                                      obscureText: _obscurePassword,
                                      validator: (input) {
                                        return (input == null || input == '')
                                            ? '入力内容を再度お確かめください'
                                            : null;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(left: 5.0),
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        hintText: widget
                                            .loginScreenData.inputs.last.label,
                                        filled: true,
                                        fillColor: Colors.white54,
                                        suffixIcon: GestureDetector(
                                          child: Icon(
                                            Icons.lock,
                                            color: _obscurePassword
                                                ? Colors.black
                                                : Colors.black45,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),

                                    /// パスワード忘れた場合のリセットボタン
                                    if (widget.loginScreenData
                                        .displayPasswordResetButton)
                                      Container(
                                        width: double.infinity,
                                        child: FlatButton(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            'パスワードを忘れた場合',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          onPressed: () {
                                            WidgetEvent event = WidgetEvent(
                                              fromWidgetId: -1,
                                              fromWidgetName:
                                                  "PasswordResetButton",
                                              toScreenName:
                                                  "PasswordResetScreen",
                                            );

                                            NavigatorStateCarm2.push(
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) {
                                                  return Provider(
                                                    create: (BuildContext
                                                            context) =>
                                                        PasswordResetScreenBloc(),
                                                    dispose: (_, _bloc) =>
                                                        _bloc.dispose(),
                                                    child: PasswordResetScreen(
                                                        email:
                                                            _idInputController
                                                                .text),
                                                  );
                                                },
                                              ),
                                              event,
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // stay logged in checkbox
                            StreamBuilder(
                              stream: Provider.of<LoginScreenBloc>(context,
                                      listen: false)
                                  .keepLoggedIn,
                              initialData: false,
                              builder: (context, snapshot) {
                                return Row(
                                  children: <Widget>[
                                    Checkbox(
                                      value: snapshot.data,
                                      onChanged: (value) {
                                        Provider.of<LoginScreenBloc>(context,
                                                listen: false)
                                            .changeKeepLoggedIn(value);
                                      },
                                      focusColor: Colors.white,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    FlatButton(
                                      child: Text(
                                        _keepLoggedInLabel,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Provider.of<LoginScreenBloc>(context,
                                                listen: false)
                                            .changeKeepLoggedIn(!snapshot.data);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),

                            // submit button
                            Container(
                              width: double.infinity,
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                color: widget.loginScreenData.submitButton
                                    .backgroundColor,
                                child: Text(
                                  widget.loginScreenData.submitButton.label,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () {
                                  _submitForm();
                                },
                              ),
                            ),

                            // Padding(
                            //   padding: const EdgeInsets.only(top: 8.0),
                            //   child: Text(
                            //     '※パスワードを忘れた場合は\n近畿大学アカデミックシアター事務室へ\nお申し出ください。',
                            //     style: TextStyle(color: Colors.black),
                            //   ),
                            // ),

                            // 会員登録ボタンはログインアプリ機能のcanSignUpフラグによって表示される
                            if (widget.loginScreenData.canSignUp)
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Container(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    color: widget.loginScreenData.submitButton
                                        .backgroundColor,
                                    child: Text(
                                      _newMemberSubmitButtonLabel,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () {
                                      WidgetEvent event = WidgetEvent(
                                        fromWidgetId: -1,
                                        fromWidgetName:
                                            "MemberRegistrationButton",
                                        toScreenName:
                                            "MemberRegistrationScreen",
                                      );

                                      NavigatorStateCarm2.push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return Provider(
                                              create: (BuildContext context) =>
                                                  MemberRegistrationScreenBloc(
                                                      initialAttributes: widget
                                                          .loginScreenData
                                                          .attributes),
                                              dispose: (_, _bloc) =>
                                                  _bloc.dispose(),
                                              child: MemberRegistrationScreen(
                                                loginScreenData:
                                                    widget.loginScreenData,
                                              ),
                                            );
                                          },
                                        ),
                                        event,
                                      );
                                    },
                                  ),
                                ),
                              ),

                            /// ログインせずに利用するボタン
                            if (widget.loginScreenData
                                    .continueWithoutLoginButton !=
                                null)
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Container(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    color: widget
                                        .loginScreenData
                                        .continueWithoutLoginButton
                                        .backgroundColor,
                                    child: Text(
                                      widget.loginScreenData
                                          .continueWithoutLoginButton.label,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () {
                                      Provider.of<LoginScreenBloc>(context,
                                              listen: false)
                                          .continueWithoutLogin();
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _idInputController.dispose();
    _passwordInputController.dispose();
    super.dispose();
  }
}


class LoginAttributeDisplayArea extends StatefulWidget {
  final AttributeDecoration attributeDecoration;

  final List<AbstractAttributeInputData> inputDataList;

  const LoginAttributeDisplayArea({
    Key key,
    this.attributeDecoration,
    this.inputDataList,
  }) : super(key: key);

  @override
  _LoginAttributeDisplayAreaState createState() =>
      _LoginAttributeDisplayAreaState();
}

class _LoginAttributeDisplayAreaState
    extends State<LoginAttributeDisplayArea> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AttributesDisplayData>(
      stream: Provider.of<LoginScreenBloc>(context, listen: false)
          .attributeStream,
      builder: (BuildContext context,
          AsyncSnapshot<AttributesDisplayData> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            child: Center(
              child: LoadingScreen(),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: AttributeList(
                attributes: snapshot.data.attributes,
                inputDataList: widget.inputDataList,
                attributeDecoration: widget.attributeDecoration,
                updateCallback: (Attribute attribute) {
                  Provider.of<LoginScreenBloc>(context, listen: false)
                      .updatedAttributeSink
                      .add(attribute);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
