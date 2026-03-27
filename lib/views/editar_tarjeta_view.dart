import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarjeta_model.dart';
import '../services/tarjeta_service.dart';
import '../widgets/tarjeta_visual.dart';
import '../widgets/formulario_tarjeta_widgets.dart';

class EditarTarjetaView extends StatefulWidget {
  final TarjetaModel tarjeta;

  const EditarTarjetaView({super.key, required this.tarjeta});

  @override
  State<EditarTarjetaView> createState() => _EditarTarjetaViewState();
}

class _EditarTarjetaViewState extends State<EditarTarjetaView> {
  final _claveFormulario = GlobalKey<FormState>();

  late final TextEditingController _bancoCtrl;
  late final TextEditingController _titularCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _vencimientoCtrl;
  late final TextEditingController _limiteCtrl;

  late String _tipo;
  late String _redTarjeta;
  late int _colorSeleccionado;
  late int? _diaCorte;
  late int? _diaPago;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tarjeta;
    _bancoCtrl = TextEditingController(text: t.banco);
    _titularCtrl = TextEditingController(text: t.titular);
    _numeroCtrl = TextEditingController(text: t.ultimos4);
    _vencimientoCtrl =
        TextEditingController(text: '${t.mesVencimiento}/${t.anioVencimiento}');
    _limiteCtrl = TextEditingController(
      text: t.limiteCredito != null ? t.limiteCredito!.toStringAsFixed(0) : '',
    );
    _tipo = t.tipo;
    _redTarjeta = t.redTarjeta;
    _colorSeleccionado = t.colorTarjeta;
    _diaCorte = t.diaCorte;
    _diaPago = t.diaPago;
  }

  @override
  void dispose() {
    _bancoCtrl.dispose();
    _titularCtrl.dispose();
    _numeroCtrl.dispose();
    _vencimientoCtrl.dispose();
    _limiteCtrl.dispose();
    super.dispose();
  }

  TarjetaModel get _tarjetaPrevia {
    final numero = _numeroCtrl.text.replaceAll(' ', '');
    final ultimos4 = numero.length >= 4
        ? numero.substring(numero.length - 4)
        : widget.tarjeta.ultimos4;
    final partes = _vencimientoCtrl.text.split('/');
    return widget.tarjeta.copyWith(
      banco: _bancoCtrl.text,
      tipo: _tipo,
      redTarjeta: _redTarjeta,
      titular: _titularCtrl.text,
      ultimos4: ultimos4,
      mesVencimiento: partes.isNotEmpty ? partes[0] : '',
      anioVencimiento: partes.length > 1 ? partes[1] : '',
      colorTarjeta: _colorSeleccionado,
      numeroEnmascarado: '**** **** **** $ultimos4',
    );
  }

  Future<void> _guardar() async {
    if (!_claveFormulario.currentState!.validate()) return;
    setState(() => _guardando = true);

    //final numero = _numeroCtrl.text.replaceAll(' ', '');
    final ultimos4 = widget.tarjeta.ultimos4;
    final partes = _vencimientoCtrl.text.split('/');

    final tarjetaActualizada = widget.tarjeta.copyWith(
      banco: _bancoCtrl.text.trim(),
      tipo: widget.tarjeta.tipo,
      redTarjeta: _redTarjeta,
      titular: _titularCtrl.text.trim(),
      ultimos4: ultimos4,
      mesVencimiento: partes[0],
      anioVencimiento: partes.length > 1 ? partes[1] : '',
      numeroEnmascarado: '**** **** **** $ultimos4',
      colorTarjeta: _colorSeleccionado,
      limiteCredito: _limiteCtrl.text.isNotEmpty
          ? double.tryParse(_limiteCtrl.text.replaceAll(',', ''))
          : null,
      diaCorte: _diaCorte,
      diaPago: _diaPago,
    );

    Provider.of<TarjetaService>(context, listen: false)
        .editarTarjeta(tarjetaActualizada);
    setState(() => _guardando = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101722),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101722),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar tarjeta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // ── Vista previa ──────────────────────────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([
                _bancoCtrl,
                _titularCtrl,
                _numeroCtrl,
                _vencimientoCtrl,
              ]),
              builder: (_, __) => Center(
                child: TarjetaVisual(
                  tarjeta: _tarjetaPrevia,
                  ancho: double.infinity,
                  alto: 190,
                ),
              ),
            ),

            const SizedBox(height: 28),

            const SeccionFormulario(titulo: 'Tipo de tarjeta'),
            const SizedBox(height: 10),
             Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text(
                      _tipo == 'credito' ? 'Tarjeta de crédito' : 'Tarjeta de débito',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),


            const SizedBox(height: 20),

            const SeccionFormulario(titulo: 'Red de pago'),
            const SizedBox(height: 10),
            SelectorRedTarjeta(
              seleccionada: _redTarjeta,
              alCambiar: (v) => setState(() => _redTarjeta = v),
            ),

            const SizedBox(height: 20),

            const SeccionFormulario(titulo: 'Color de tarjeta'),
            const SizedBox(height: 10),
            SelectorColorTarjeta(
              colores: coloresDisponiblesTarjeta,
              seleccionado: _colorSeleccionado,
              alCambiar: (c) => setState(() => _colorSeleccionado = c),
            ),

            const SizedBox(height: 20),

            const SeccionFormulario(titulo: 'Datos de la tarjeta'),
            const SizedBox(height: 10),

            CampoTextoTarjeta(
              controlador: _bancoCtrl,
              etiqueta: 'Nombre del banco',
              icono: Icons.account_balance_rounded,
              alCambiar: (_) => setState(() {}),
              validador: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa el nombre del banco' : null,
            ),
            const SizedBox(height: 14),

            CampoTextoTarjeta(
              controlador: _titularCtrl,
              etiqueta: 'Nombre del titular',
              icono: Icons.person_rounded,
              textoCapital: true,
              alCambiar: (_) => setState(() {}),
              validador: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa el nombre del titular' : null,
            ),
            const SizedBox(height: 14),

           Container(
  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Row(
    children: [
      const Icon(Icons.credit_card, color: Colors.white70),
      const SizedBox(width: 10),
      Text(
        '**** **** **** ${widget.tarjeta.ultimos4}',
        style: const TextStyle(color: Colors.white),
      ),
    ],
  ),
),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CampoVencimientoTarjeta(
                    controlador: _vencimientoCtrl,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                
              ],
            ),

            const SizedBox(height: 20),

            const SeccionFormulario(titulo: 'Control financiero'),
            const SizedBox(height: 10),

            CampoTextoTarjeta(
              controlador: _limiteCtrl,
              etiqueta: 'Límite de crédito (opcional)',
              icono: Icons.account_balance_wallet_rounded,
              teclado: TextInputType.number,
              validador: (v) {
                if (v == null || v.isEmpty) return null;
                if (double.tryParse(v.replaceAll(',', '')) == null) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

             if (_tipo == 'credito') 
              Row(
                children: [
                  Expanded(
                    child: SelectorDiaTarjeta(
                      etiqueta: 'Día de corte',
                      icono: Icons.calendar_today_rounded,
                      valor: _diaCorte,
                      alCambiar: (d) => setState(() => _diaCorte = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectorDiaTarjeta(
                      etiqueta: 'Día de pago',
                      icono: Icons.payments_rounded,
                      valor: _diaPago,
                      alCambiar: (d) => setState(() => _diaPago = d),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF35D6C8),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
