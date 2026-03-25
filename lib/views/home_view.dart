import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/tarjeta_service.dart';
import 'agregar_tarjeta_view.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final tarjetas = Provider.of<TarjetaService>(context);

    return Scaffold(
            backgroundColor: const Color(0xFF101722),
            appBar: AppBar(
              backgroundColor: const Color(0xFF101722),
              elevation: 0,
              title: const Text(
                'finBrain',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await authService.signOut();
                  },
                  child: const Text(
                    'Salir',
                    style: TextStyle(
                      color: Color(0xFF8FE9DD),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis tarjetas',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (tarjetas.tarjetas.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No hay tarjetas aún. Agrega una con el botón +',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: tarjetas.tarjetas.length,
                        itemBuilder: (context, index) {
                          final tarjeta = tarjetas.tarjetas[index];
                          return Card(
                            color: const Color(0xFF213047),
                            child: ListTile(
                              title: Text('${tarjeta.banco} • ${tarjeta.tipo.toUpperCase()}', style: const TextStyle(color: Colors.white)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Titular: ${tarjeta.titular}', style: const TextStyle(color: Colors.white70)),
                                  Text('Numero: ${tarjeta.numeroEnmascarado}', style: const TextStyle(color: Colors.white70)),
                                  Text('Vence: ${tarjeta.mesVencimiento}/${tarjeta.anioVencimiento}', style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => tarjetas.borrarTarjeta(tarjeta.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgregarTarjetaView()),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
  }
}
