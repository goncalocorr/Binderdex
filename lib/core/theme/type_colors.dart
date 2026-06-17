import 'package:flutter/material.dart';

import '../../domain/entities/pokemon.dart';

/// Cores oficiais (aproximadas) por tipo de Pokémon, usadas nos chips e cartões.
const Map<PokemonType, Color> typeColors = {
  PokemonType.normal: Color(0xFFA8A77A),
  PokemonType.fire: Color(0xFFEE8130),
  PokemonType.water: Color(0xFF6390F0),
  PokemonType.electric: Color(0xFFF7D02C),
  PokemonType.grass: Color(0xFF7AC74C),
  PokemonType.ice: Color(0xFF96D9D6),
  PokemonType.fighting: Color(0xFFC22E28),
  PokemonType.poison: Color(0xFFA33EA1),
  PokemonType.ground: Color(0xFFE2BF65),
  PokemonType.flying: Color(0xFFA98FF3),
  PokemonType.psychic: Color(0xFFF95587),
  PokemonType.bug: Color(0xFFA6B91A),
  PokemonType.rock: Color(0xFFB6A136),
  PokemonType.ghost: Color(0xFF735797),
  PokemonType.dragon: Color(0xFF6F35FC),
  PokemonType.dark: Color(0xFF705746),
  PokemonType.steel: Color(0xFFB7B7CE),
  PokemonType.fairy: Color(0xFFD685AD),
};

Color colorForType(PokemonType t) => typeColors[t] ?? const Color(0xFFA8A77A);
