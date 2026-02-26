// OntarioTechPlus - supabase_provider.dart

// Provides the Supabase client to the entire app using Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global Supabase client provider.
// Allows other providers and services to access Supabase.
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
