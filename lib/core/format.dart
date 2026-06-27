/// Formata um valor em euros à portuguesa (ex.: "12,34 €").
String euro(double v) => '${v.toStringAsFixed(2).replaceAll('.', ',')} €';
