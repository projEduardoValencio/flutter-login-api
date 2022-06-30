import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:login_page/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formkey,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "e-mail"),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return "Insira um e-mail";
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(_emailController.text)) {
                        return 'Por favor, digite um e-mail correto';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "senha"),
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    validator: (senha) {
                      if (senha == null || senha.isEmpty) {
                        return "Por favor insira uma senha";
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      //verificar se o estado das validações esta valido
                      if (_formkey.currentState!.validate()) {
                        bool confirm = await login();
                        //Escondendo o teclado
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (confirm) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        } else {
                          _passwordController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    child: Text("ENTER"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> login() async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    //INSERIR A URL DE LOGIN
    var url = Uri.parse('');

    //SUBSTITUIR O USUARIO E SENHA PARA OS CORRESPONDENTES DO JSON NA PAGINA DE LOGIN
    var resposta = await post(url, body: {
      'usuario': _emailController.text,
      'password': _passwordController.text,
    });

    //VERIFICAR SE O TOKEN VEM NOMEADO COMO TOKEN
    if (resposta.statusCode == 200) {
      //SALVANDO O TOKEN DE USUARIO NO APARELHO
      await sharedPreference.setString(
          'token', "Token ${jsonDecode(resposta.body)['token']}");
      //Mostrando o token
      print(jsonDecode(resposta.body)['token']);
      return true;
    } else {
      print(jsonDecode(resposta.body));
      return false;
    }
  }

  final snackBar = SnackBar(
    content: Text(
      "e-mail ou senha invalidos",
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.amber,
  );
}
