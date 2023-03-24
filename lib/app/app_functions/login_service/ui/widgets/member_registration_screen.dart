// @dart=2.9

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/screen/attribute_editor_screen.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/blocs/attribute_editor_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/view_models/attribute_input_data.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/widgets/attribute_inputs.dart';
import 'package:carm2_base/app/app_functions/login_service/blocs/member_registration_screen_bloc.dart';
//import 'package:carm2_base/app/app_functions/login_service/ui/widgets/login_screen.dart';
import 'package:carm2_base/app/app_settings.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute_value.dart';
import 'package:carm2_base/app/resources/models/member/member_registration_payload.dart';
import 'package:carm2_base/app/ui/widgets/custom_input_label.dart';
import 'package:carm2_base/app/ui/widgets/custom_status_bar.dart';
import 'package:carm2_base/app/ui/widgets/loading_screen.dart';
import 'package:carm2_base/app/ui/widgets/stream_snack_bar.dart';
import 'package:carm2_base/app/util/navigator_state_carm2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carm2_app_project/app/app_functions/login_service/ui/widgets/login_screen.dart';

class MemberRegistrationScreen extends StatelessWidget {
  final LoginScreenData loginScreenData;

  const MemberRegistrationScreen({
    Key key,
    @required this.loginScreenData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavigatorStateCarm2.pop();
        return false;
      },
      child: CustomStatusBar(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  NavigatorStateCarm2.pop();
                }),
            centerTitle: true,
            title: Text(
              '会員登録',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: StreamSnackBar(
            title: '会員登録に失敗しました',
            stream: Provider.of<MemberRegistrationScreenBloc>(context,
                    listen: false)
                .messageStream,
            child: StreamBuilder<ProcessingStatus>(
              stream: Provider.of<MemberRegistrationScreenBloc>(context,
                      listen: false)
                  .processingStatus,
              initialData: ProcessingStatus.pending,
              builder: (context, snapshot) {
                final _status = snapshot.data;

                if (_status == ProcessingStatus.registrationDone) {
                  return RegistrationSuccess();
                }

                return RegistrationForm(
                  loginScreenData: loginScreenData,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0),
            child: Text(
              '会員登録が成功しました。',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ),
          RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero),
            ),
            color: Colors.grey.shade200,
            child: Text(
              '戻る',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            onPressed: () {
              NavigatorStateCarm2.pop();
            },
          ),
        ],
      ),
    );
  }
}

/// global variable [inputDataList] to get all input when updating
final List<AbstractAttributeInputData> _inputDataList = [];

class RegistrationForm extends StatefulWidget {
  final LoginScreenData loginScreenData;

  const RegistrationForm({
    Key key,
    @required this.loginScreenData,
  }) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailInputController = TextEditingController();
  // final _accountIdInputController = TextEditingController();
  final _passwordInputController = TextEditingController();
  final _passwordConfirmInputController = TextEditingController();

  final String _emailInputLabel = 'メール';
  // final String _accountIdInputLabel = '会員証カード番号 (半角数字)';
  final String _passwordInputLabel = 'パスワード';
  final String _passwordConfirmInputLabel = 'パスワード (確認)';

  final ScrollController scrollController = ScrollController();

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 5.0),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      hintText: hintText,
      filled: true,
      errorMaxLines: 3,
      fillColor: Colors.white,
    );
  }

  Future<void> _submitForm() async {
    final form = _formKey.currentState;
    if (form.validate() == false) {
      return;
    }

    final List<AttributeValue> _attributeValues = [];
    _inputDataList.forEach((inputData) {
      _attributeValues.addAll(inputData.getAttributeValues());
    });

    final attributesUpdatePayload = MemberRegistrationPayload((b) {
      b.appId = appSettings.appId;
      b.name = '<dummy name>';
      b.email = _emailInputController.text;
      // b.accountId = _accountIdInputController.text;
      b.password = _passwordInputController.text;
      b.passwordConfirmation = _passwordConfirmInputController.text;
      b.attributeValues = ListBuilder<AttributeValue>(_attributeValues);
      return b.build();
    });

    print('attributesUpdatePayload: ${attributesUpdatePayload.toJson()}');

    Provider.of<MemberRegistrationScreenBloc>(context, listen: false)
        .submit(attributesUpdatePayload);
  }

  bool _hasPasswordDescription() {
    return widget.loginScreenData?.passwordDescription != null &&
        widget.loginScreenData?.passwordDescription != '';
  }

  bool _hasEmailDescription() {
    return widget.loginScreenData?.emailDescription != null &&
        widget.loginScreenData?.emailDescription != '';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: scrollController,
          child: Theme(
            data: Theme.of(context).copyWith(errorColor: Colors.red),
            child: Builder(
              builder: (BuildContext context) => Form(
                key: _formKey,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 50.0, right: 50.0, top: 20.0, bottom: 65.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // email field
                        CustomInputLabel.white(
                          label: _emailInputLabel,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: TextFormField(
                              controller: _emailInputController,
                              validator: (input) {
                                return (input == null || input == '')
                                    ? '入力内容を再度お確かめください'
                                    : null;
                              },
                              keyboardType: TextInputType.text,
                              decoration: _getInputDecoration(_emailInputLabel),
                            ),
                          ),
                        ),

                        // account id field
                        // CustomInputLabel.black(
                        //   label: _accountIdInputLabel,
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(bottom: 20.0),
                        //     child: Column(
                        //       mainAxisSize: MainAxisSize.min,
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         TextFormField(
                        //           controller: _emailInputController,
                        //           validator: (input) {
                        //             return (input == null || input == '')
                        //                 ? '不正な入力'
                        //                 : null;
                        //           },
                        //           keyboardType: TextInputType.text,
                        //           decoration:
                        //               _getInputDecoration(_emailInputLabel),
                        //         ),
                        //         if (_hasEmailDescription())
                        //           Text(widget
                        //               .loginScreenData?.emailDescription)
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        // password field
                        CustomInputLabel.black(
                          label: _passwordInputLabel,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: TextFormField(
                              controller: _passwordInputController,
                              validator: (input) {
                                // .* は任意の文字0文字以上 *?は最短のマッチをとる(最長だと貪欲にとるため)
                                final RegExp validatePassword = RegExp(
                                    r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z0-9]{8,}$');
                                return (validatePassword.hasMatch(input) ==
                                        false)
                                    ? '英大文字小文字、数字をそれぞれ1文字以上含む8桁以上で入力してください'
                                    : null;
                              },
                              decoration:
                                  _getInputDecoration(_passwordInputLabel),
                            ),
                          ),
                        ),

                        CustomInputLabel.black(
                          label: _passwordConfirmInputLabel,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _passwordConfirmInputController,
                                  validator: (input) {
                                    if (input !=
                                        _passwordInputController.text) {
                                      return _passwordInputLabel + 'と一致しません';
                                    }

                                    return (input == null || input == '')
                                        ? '入力内容を再度お確かめください'
                                        : null;
                                  },
                                  decoration: _getInputDecoration(
                                      _passwordConfirmInputLabel),
                                ),

                                /// パスワード説明
                                if (_hasPasswordDescription())
                                  Text(widget
                                      .loginScreenData?.passwordDescription)
                              ],
                            ),
                          ),
                        ),

                        /// 属性の入力フィールド
                        MemberAttributeDisplayArea(
                          attributeDecoration: AttributeDecoration(
                            primaryColor: Theme.of(context).primaryColor,
                            fillColor: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                            labelTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ),

                        // submit button
                        // TODO: using hardcoded color values for submit button on member registration form
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Container(
                            width: double.infinity,
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              // loginではwidget.backgroundcolorを取っていたが、それがこっちになかったのでとりあえず固定にしました���
                              color: Color(0xff222f3d),
                              child: Text(
                                '登録',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {
                                _submitForm();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        /// 保存中にアニメーションを表示する
        StreamBuilder<ProcessingStatus>(
          stream:
              Provider.of<MemberRegistrationScreenBloc>(context, listen: false)
                  .processingStatus,
          initialData: ProcessingStatus.pending,
          builder: (context, snapshot) {
            if (snapshot.data != ProcessingStatus.processing) {
              return SizedBox();
            }

            return AbsorbPointer(
              child: Container(
                color: Colors.white.withOpacity(0.4),
                child: LoadingScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailInputController.dispose();
    // _accountIdInputController.dispose();
    _passwordInputController.dispose();
    _passwordConfirmInputController.dispose();
    // _messageStreamSubscription?.cancel();

    scrollController.dispose();
    super.dispose();
  }
}

class MemberAttributeDisplayArea extends StatefulWidget {
  /// 入力フィールドのデザイン設定
  final AttributeDecoration attributeDecoration;

  const MemberAttributeDisplayArea({
    Key key,
    this.attributeDecoration,
  }) : super(key: key);

  @override
  _MemberAttributeDisplayAreaState createState() =>
      _MemberAttributeDisplayAreaState();
}

class _MemberAttributeDisplayAreaState
    extends State<MemberAttributeDisplayArea> {
  ScrollController _scrollController = ScrollController();

  void _scrollDownABit() {
    // using timer to scroll down after build has completed
    Timer(Duration(milliseconds: 100), () {
      double scrollOffset = _scrollController.offset + 50.0;

      if (scrollOffset > _scrollController.position.maxScrollExtent) {
        scrollOffset = _scrollController.position.maxScrollExtent;
      }

      _scrollController.animateTo(scrollOffset,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AttributesDisplayData>(
      stream: Provider.of<MemberRegistrationScreenBloc>(context, listen: false)
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

        if (snapshot.data.hasGrown) {
          _scrollDownABit();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: AttributeList(
                attributes: snapshot.data.attributes,
                inputDataList: _inputDataList,
                attributeDecoration: widget.attributeDecoration,
                updateCallback: (Attribute attribute) {
                  Provider.of<MemberRegistrationScreenBloc>(context,
                          listen: false)
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
