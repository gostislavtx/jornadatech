/// Conexão com o Supabase.
///
/// A chave abaixo é a **publishable** (pública): pode ficar no código, porque
/// quem protege os dados são as regras de segurança (RLS) do banco. A chave
/// secreta (service_role / secret) NUNCA entra no app nem no GitHub.
///
/// Para rodar sem banco, com os dados de exemplo em memória:
///   flutter run -d chrome --dart-define=USE_MOCK=true
class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zkokigbhbfuddczxrzth.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'sb_publishable_C2C_lJBFsmgWb50S0qD2zA_c0ti68Xi',
  );

  static const useMock = bool.fromEnvironment('USE_MOCK');
}
