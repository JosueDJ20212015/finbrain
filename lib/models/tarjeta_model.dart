class TarjetaModel {
  final String id;
  final String banco;
  final String tipo; // credito o debito
  final String redTarjeta; // visa, mastercard, amex, etc.
  final String titular;
  final String ultimos4;
  final String mesVencimiento;
  final String anioVencimiento;
  final String numeroEnmascarado;
  final int colorTarjeta; // Color ARGB como int
  final double? limiteCredito;
  final int? diaCorte; 
  final int? diaPago; 
  final DateTime creadaEn;

  TarjetaModel({
    required this.id,
    required this.banco,
    required this.tipo,
    required this.redTarjeta,
    required this.titular,
    required this.ultimos4,
    required this.mesVencimiento,
    required this.anioVencimiento,
    required this.numeroEnmascarado,
    required this.colorTarjeta,
    required this.creadaEn,
    this.limiteCredito,
    this.diaCorte,
    this.diaPago,
  });

  TarjetaModel copyWith({
    String? id,
    String? banco,
    String? tipo,
    String? redTarjeta,
    String? titular,
    String? ultimos4,
    String? mesVencimiento,
    String? anioVencimiento,
    String? numeroEnmascarado,
    int? colorTarjeta,
    double? limiteCredito,
    int? diaCorte,
    int? diaPago,
    DateTime? creadaEn,
  }) {
    return TarjetaModel(
      id: id ?? this.id,
      banco: banco ?? this.banco,
      tipo: tipo ?? this.tipo,
      redTarjeta: redTarjeta ?? this.redTarjeta,
      titular: titular ?? this.titular,
      ultimos4: ultimos4 ?? this.ultimos4,
      mesVencimiento: mesVencimiento ?? this.mesVencimiento,
      anioVencimiento: anioVencimiento ?? this.anioVencimiento,
      numeroEnmascarado: numeroEnmascarado ?? this.numeroEnmascarado,
      colorTarjeta: colorTarjeta ?? this.colorTarjeta,
      limiteCredito: limiteCredito ?? this.limiteCredito,
      diaCorte: diaCorte ?? this.diaCorte,
      diaPago: diaPago ?? this.diaPago,
      creadaEn: creadaEn ?? this.creadaEn,
    );
  }
}
