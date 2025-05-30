import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true; // ✅ Estado para alternar visibilidad

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso')),
        );
        // Aquí puedes navegar a otra pantalla

        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error desconocido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Parte superior con la imagen
          Expanded(
            flex: 1,
            child: SizedBox.expand(
              child: SizedBox(
                width: 50, // Ancho deseado
                height: 50,
                child: Image.asset(
                  'assets/images/app_icon.png', // Asegúrate de tener esta imagen en tu proyecto
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Parte inferior con el formulario
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    'L O G I N',
                    style: TextStyle(
                      fontSize: 32, // Tamaño de letra
                      color: AppColors.primary, // Color del texto
                      fontWeight:
                          FontWeight.bold, // Opcional: para hacerlo más grueso
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),

                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ), // Color cuando está activo
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),

                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ), // Color cuando no está enfocado
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    obscureText:
                        _isObscured, // ✅ Controla la visibilidad de la contraseña
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off
                              : Icons.visibility, // ✅ Alterna icono de ojo
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured =
                                !_isObscured; // ✅ Cambia el estado al presionar el botón
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        AppColors.primary,
                      ), // Color de fondo
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Bordes redondeados
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all(Size(300, 50)),
                    ),

                    onPressed: _signIn,

                    child: const Text(
                      'Ingresar',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
