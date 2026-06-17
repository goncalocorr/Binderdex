/// Registo da coleção do utilizador para um dado Pokémon.
///
/// O [updatedAt] é o instante da última edição local. Na Etapa 2 (sync) será
/// complementado pelo *server timestamp* do Firestore para resolver conflitos.
class UserEntry {
  final int pokemonId;
  final bool caught;
  final bool shiny;
  final int quantity;
  final String notes;
  final DateTime updatedAt;

  const UserEntry({
    required this.pokemonId,
    this.caught = false,
    this.shiny = false,
    this.quantity = 0,
    this.notes = '',
    required this.updatedAt,
  });

  UserEntry copyWith({
    bool? caught,
    bool? shiny,
    int? quantity,
    String? notes,
    DateTime? updatedAt,
  }) =>
      UserEntry(
        pokemonId: pokemonId,
        caught: caught ?? this.caught,
        shiny: shiny ?? this.shiny,
        quantity: quantity ?? this.quantity,
        notes: notes ?? this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
