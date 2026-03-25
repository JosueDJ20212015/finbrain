import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Sección (encabezado de grupo) ────────────────────────────────────────────
class SeccionFormulario extends StatelessWidget {
  final String titulo;
  const SeccionFormulario({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Selector de tipo (crédito/débito) ────────────────────────────────────────
class SelectorTipoTarjeta extends StatelessWidget {
  final String seleccionado;
  final ValueChanged<String> alCambiar;

  const SelectorTipoTarjeta({
    super.key,
    required this.seleccionado,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChipTipoTarjeta(
          etiqueta: 'Crédito',
          valor: 'credito',
          icono: Icons.credit_card_rounded,
          seleccionado: seleccionado == 'credito',
          alTocar: () => alCambiar('credito'),
        ),
        const SizedBox(width: 12),
        ChipTipoTarjeta(
          etiqueta: 'Débito',
          valor: 'debito',
          icono: Icons.account_balance_wallet_rounded,
          seleccionado: seleccionado == 'debito',
          alTocar: () => alCambiar('debito'),
        ),
      ],
    );
  }
}

class ChipTipoTarjeta extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback alTocar;

  const ChipTipoTarjeta({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    required this.seleccionado,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: alTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: seleccionado
                ? const Color(0xFF35D6C8).withOpacity(0.15)
                : const Color(0xFF1A2535),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? const Color(0xFF35D6C8)
                  : const Color(0xFF2A3A50),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icono,
                color: seleccionado
                    ? const Color(0xFF35D6C8)
                    : const Color(0xFF8899AA),
              ),
              const SizedBox(height: 6),
              Text(
                etiqueta,
                style: TextStyle(
                  color: seleccionado
                      ? const Color(0xFF35D6C8)
                      : const Color(0xFF8899AA),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Selector de red de tarjeta ────────────────────────────────────────────────
class SelectorRedTarjeta extends StatelessWidget {
  final String seleccionada;
  final ValueChanged<String> alCambiar;

  const SelectorRedTarjeta({
    super.key,
    required this.seleccionada,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BotonRedTarjeta(
          nombre: 'Visa',
          valor: 'visa',
          seleccionado: seleccionada == 'visa',
          alTocar: () => alCambiar('visa'),
          hijo: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        BotonRedTarjeta(
          nombre: 'Mastercard',
          valor: 'mastercard',
          seleccionado: seleccionada == 'mastercard',
          alTocar: () => alCambiar('mastercard'),
          hijo: SizedBox(
            width: 34,
            height: 20,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEB001B),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF79E1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        BotonRedTarjeta(
          nombre: 'Amex',
          valor: 'amex',
          seleccionado: seleccionada == 'amex',
          alTocar: () => alCambiar('amex'),
          hijo: const Text(
            'AMEX',
            style: TextStyle(
              color: Color(0xFF006FCF),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class BotonRedTarjeta extends StatelessWidget {
  final String nombre;
  final String valor;
  final bool seleccionado;
  final VoidCallback alTocar;
  final Widget hijo;

  const BotonRedTarjeta({
    super.key,
    required this.nombre,
    required this.valor,
    required this.seleccionado,
    required this.alTocar,
    required this.hijo,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: alTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: seleccionado
                ? const Color(0xFF35D6C8).withOpacity(0.12)
                : const Color(0xFF1A2535),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? const Color(0xFF35D6C8)
                  : const Color(0xFF2A3A50),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              hijo,
              const SizedBox(height: 6),
              Text(
                nombre,
                style: TextStyle(
                  color: seleccionado
                      ? const Color(0xFF35D6C8)
                      : const Color(0xFF8899AA),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Selector de color ─────────────────────────────────────────────────────────
class SelectorColorTarjeta extends StatelessWidget {
  final List<int> colores;
  final int seleccionado;
  final ValueChanged<int> alCambiar;

  const SelectorColorTarjeta({
    super.key,
    required this.colores,
    required this.seleccionado,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colores.map((colorInt) {
        final estaSeleccionado = seleccionado == colorInt;
        return GestureDetector(
          onTap: () => alCambiar(colorInt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Color(colorInt),
              shape: BoxShape.circle,
              border: estaSeleccionado
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.transparent, width: 3),
              boxShadow: estaSeleccionado
                  ? [
                      BoxShadow(
                        color: Color(colorInt).withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: estaSeleccionado
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ─── Campo de texto reutilizable ──────────────────────────────────────────────
InputDecoration _decoracionCampo({
  required String etiqueta,
  required IconData icono,
  Widget? sufijo,
}) {
  return InputDecoration(
    labelText: etiqueta,
    labelStyle: const TextStyle(color: Color(0xFF8899AA)),
    prefixIcon: Icon(icono, color: const Color(0xFF35D6C8), size: 20),
    suffixIcon: sufijo,
    filled: true,
    fillColor: const Color(0xFF1A2535),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2A3A50), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF35D6C8), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
    ),
  );
}

class CampoTextoTarjeta extends StatelessWidget {
  final TextEditingController controlador;
  final String etiqueta;
  final IconData icono;
  final String? Function(String?)? validador;
  final ValueChanged<String>? alCambiar;
  final TextInputType teclado;
  final bool textoCapital;

  const CampoTextoTarjeta({
    super.key,
    required this.controlador,
    required this.etiqueta,
    required this.icono,
    this.validador,
    this.alCambiar,
    this.teclado = TextInputType.text,
    this.textoCapital = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: teclado,
      onChanged: alCambiar,
      textCapitalization:
          textoCapital ? TextCapitalization.words : TextCapitalization.none,
      style: const TextStyle(color: Colors.white),
      decoration: _decoracionCampo(etiqueta: etiqueta, icono: icono),
      validator: validador,
    );
  }
}

// ─── Campo número con formato automático ──────────────────────────────────────
class FormateadorNumeroTarjeta extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue valorAnterior,
    TextEditingValue nuevoValor,
  ) {
    final digitos = nuevoValor.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitos.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitos[i]);
    }
    final formateado = buffer.toString();
    return nuevoValor.copyWith(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }
}

class CampoNumeroTarjeta extends StatelessWidget {
  final TextEditingController controlador;
  final ValueChanged<String>? alCambiar;

  const CampoNumeroTarjeta({
    super.key,
    required this.controlador,
    this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, letterSpacing: 2),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        FormateadorNumeroTarjeta(),
      ],
      onChanged: alCambiar,
      decoration: _decoracionCampo(
        etiqueta: 'Número de tarjeta',
        icono: Icons.credit_card_rounded,
      ),
      validator: (v) {
        final limpio = v?.replaceAll(' ', '') ?? '';
        if (limpio.length < 13 || limpio.length > 19) return 'Número inválido';
        return null;
      },
    );
  }
}

// ─── Formateador de vencimiento ────────────────────────────────────────────────
class FormateadorVencimiento extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue valorAnterior,
    TextEditingValue nuevoValor,
  ) {
    final digitos = nuevoValor.text.replaceAll('/', '');
    if (digitos.length > 2) {
      final formateado = '${digitos.substring(0, 2)}/${digitos.substring(2)}';
      return nuevoValor.copyWith(
        text: formateado,
        selection: TextSelection.collapsed(offset: formateado.length),
      );
    }
    return nuevoValor;
  }
}

class CampoVencimientoTarjeta extends StatelessWidget {
  final TextEditingController controlador;
  final ValueChanged<String>? alCambiar;

  const CampoVencimientoTarjeta({
    super.key,
    required this.controlador,
    this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        FormateadorVencimiento(),
      ],
      onChanged: alCambiar,
      decoration: _decoracionCampo(
        etiqueta: 'MM/AA',
        icono: Icons.calendar_month_rounded,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Formato MM/AA';
        final partes = v.split('/');
        if (partes.length != 2) return 'Formato MM/AA';
        final mes = int.tryParse(partes[0]);
        final anio = int.tryParse(partes[1]);
        if (mes == null || anio == null || mes < 1 || mes > 12) {
          return 'Formato MM/AA';
        }
        return null;
      },
    );
  }
}

// ─── Campo CVV ─────────────────────────────────────────────────────────────────
class CampoCVVTarjeta extends StatefulWidget {
  final TextEditingController controlador;

  const CampoCVVTarjeta({super.key, required this.controlador});

  @override
  State<CampoCVVTarjeta> createState() => _CampoCVVTarjetaState();
}

class _CampoCVVTarjetaState extends State<CampoCVVTarjeta> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controlador,
      keyboardType: TextInputType.number,
      obscureText: _oculto,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      style: const TextStyle(color: Colors.white),
      decoration: _decoracionCampo(
        etiqueta: 'CVV',
        icono: Icons.lock_rounded,
        sufijo: IconButton(
          icon: Icon(
            _oculto ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: const Color(0xFF8899AA),
            size: 18,
          ),
          onPressed: () => setState(() => _oculto = !_oculto),
        ),
      ),
      validator: (v) {
        if (v == null || v.length < 3) return 'CVV inválido';
        return null;
      },
    );
  }
}

// ─── Selector de día ───────────────────────────────────────────────────────────
class SelectorDiaTarjeta extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final int? valor;
  final ValueChanged<int?> alCambiar;

  const SelectorDiaTarjeta({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.valor,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3A50), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: valor,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A2535),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF8899AA),
          ),
          hint: Row(
            children: [
              Icon(icono, color: const Color(0xFF35D6C8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  etiqueta,
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('—', style: TextStyle(color: Color(0xFF8899AA))),
            ),
            ...List.generate(31, (i) => i + 1).map(
              (dia) => DropdownMenuItem<int?>(
                value: dia,
                child: Text(
                  'Día $dia',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
          onChanged: alCambiar,
        ),
      ),
    );
  }
}

// ─── Constantes de colores disponibles ────────────────────────────────────────
const List<int> coloresDisponiblesTarjeta = [
  0xFF1A237E,
  0xFF006064,
  0xFF1B5E20,
  0xFF4A148C,
  0xFF880E4F,
  0xFFBF360C,
  0xFF37474F,
  0xFF212121,
  0xFF1976D2,
  0xFF00897B,
  0xFF43A047,
  0xFF8E24AA,
  0xFFE91E63,
  0xFFFF5722,
];
