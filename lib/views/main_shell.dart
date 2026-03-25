import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dashboard_view.dart';
import 'tarjetas_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _paginaActual = 0;
  final AuthService _authService = AuthService();

  static const Color _colorFondo = Color(0xFF101722);
  static const Color _colorActivo = Color(0xFF35D6C8);
  static const Color _colorInactivo = Color(0xFF4A5568);

  final List<Widget> _pantallas = const [
    DashboardView(),
    TarjetasView(),
  ];

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _colorFondo,
      // AppBar superior
      appBar: AppBar(
        backgroundColor: _colorFondo,
        elevation: 0,
        titleSpacing: 20,
        title: Image.asset(
          'assets/logo.png',
          height: 32,
          errorBuilder: (_, __, ___) => const Text(
            'finBrain',
            style: TextStyle(
              color: _colorActivo,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 1,
            ),
          ),
        ),
        actions: [
          // Avatar del usuario
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _mostrarMenuSalir(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _colorActivo.withOpacity(0.2),
                backgroundImage: usuario?.photoURL != null
                    ? NetworkImage(usuario!.photoURL!)
                    : null,
                child: usuario?.photoURL == null
                    ? Text(
                        (usuario?.displayName?.isNotEmpty == true)
                            ? usuario!.displayName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: _colorActivo,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),

      // Contenido
      body: IndexedStack(
        index: _paginaActual,
        children: _pantallas,
      ),

      // Barra de navegación inferior
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2535),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BotonNav(
                  icono: Icons.grid_view_rounded,
                  etiqueta: 'Inicio',
                  activo: _paginaActual == 0,
                  colorActivo: _colorActivo,
                  colorInactivo: _colorInactivo,
                  alTocar: () => setState(() => _paginaActual = 0),
                ),
                _BotonNav(
                  icono: Icons.credit_card_rounded,
                  etiqueta: 'Tarjetas',
                  activo: _paginaActual == 1,
                  colorActivo: _colorActivo,
                  colorInactivo: _colorInactivo,
                  alTocar: () => setState(() => _paginaActual = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarMenuSalir(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones de cuenta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B)),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _authService.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Botón de navegación inferior personalizado ───────────────────────────────
class _BotonNav extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool activo;
  final Color colorActivo;
  final Color colorInactivo;
  final VoidCallback alTocar;

  const _BotonNav({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.colorActivo,
    required this.colorInactivo,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alTocar,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? colorActivo.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              color: activo ? colorActivo : colorInactivo,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: TextStyle(
                color: activo ? colorActivo : colorInactivo,
                fontSize: 11,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
