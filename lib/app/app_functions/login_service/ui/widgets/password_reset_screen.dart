import 'package:carm2_base/app/app_functions/login_service/blocs/password_reset_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/login_service/ui/widgets/login_screen.dart';
import 'package:carm2_base/app/ui/widgets/custom_input_label.dart';
import 'package:carm2_base/app/ui/widgets/custom_status_bar.dart';
import 'package:carm2_base/app/ui/widgets/loading_screen.dart';
import 'package:carm2_base/app/ui/widgets/stream_snack_bar.dart';
import 'package:carm2_base/app/util/navigator_state_carm2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatelessWidget {
  /// ログイン画面から既にメールを入力した場合はリセット画面にも同じ入力を表示する
  final String? email;

  final LoginScreenData? loginScreenData;

  const PasswordResetScreen({
    Key? key,
    this.email,
    this.loginScreenData,
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  NavigatorStateCarm2.pop();
                }),
            centerTitle: true,
            title: Text(
              'パスワードを忘れた場合',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: StreamSnackBar(
            stream: Provider.of<PasswordResetScreenBloc>(context, listen: false)
                .messageStream,
            child: StreamBuilder<ProcessingStatus>(
              stream:
                  Provider.of<PasswordResetScreenBloc>(context, listen: false)
                      .processingStatus,
              initialData: ProcessingStatus.pending,
              builder: (context, snapshot) {
                final _status = snapshot.data;

                if (_status == ProcessingStatus.completed) {
                  return ResetCompleted();
                }

                return PasswordResetForm(
                    email: email, loginScreenData: loginScreenData);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ResetCompleted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 40.0,
              left: 20.0,
              right: 20.0,
            ),
            child: StreamBuilder<String>(
              stream:
                  Provider.of<PasswordResetScreenBloc>(context, listen: false)
                      .completedMessage,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return SizedBox();
                }

                return Text(
                  '${snapshot.data ?? ''}',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                );
              },
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

class PasswordResetForm extends StatefulWidget {
  final String? email;
  final LoginScreenData? loginScreenData;

  const PasswordResetForm({
    Key? key,
    this.email,
    this.loginScreenData,
  }) : super(key: key);

  @override
  _PasswordResetFormState createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _emailInputController;

  final String _emailInputLabel = 'メールアドレス';

  @override
  void initState() {
    super.initState();

    /// 渡されたメールアドレスがあればテキスト入力に入れる
    _emailInputController = TextEditingController(text: widget.email);
  }

  void _submitForm() {
    final form = _formKey.currentState;
    if (form!.validate() == false) {
      return;
    }

    final String email = _emailInputController.text;

    Provider.of<PasswordResetScreenBloc>(context, listen: false).submit(email);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Theme(
                data: Theme.of(context).copyWith(errorColor: Colors.red),
                child: Builder(
                  builder: (BuildContext context) => Form(
                    key: _formKey,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 50.0,
                          right: 50.0,
                          top: 20.0,
                          bottom: 40.0,
                        ),
                        child: Column(
                          children: <Widget>[
                            /// パスワードリセットのメールアドレス入力
                            CustomInputLabel.black(
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
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 5.0),
                                    border: const OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(12.0),
                                      ),
                                    ),
                                    hintText: _emailInputLabel,
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            /// パスワードリセットの説明文
                            Center(
                              child: Text(widget.loginScreenData
                                      ?.passwordResetDescription ??
                                  'ご登録時のメールアドレスを入力してください。'),
                            ),

                            Spacer(),

                            // TODO: パスワードリセット画面のデザインは固定
                            /// リセットボタン
                            Container(
                              width: double.infinity,
                              child: RaisedButton(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                color: const Color(0xFF222F3D),
                                child: const Text(
                                  '送信',
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        /// 保存中にアニメーションを表示する
        StreamBuilder<ProcessingStatus>(
          stream: Provider.of<PasswordResetScreenBloc>(context, listen: false)
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
    super.dispose();
  }
}
