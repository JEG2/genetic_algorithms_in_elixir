#include <erl_nif.h>
#include <inttypes.h>
#include <stdint.h>

static uint32_t x = 123456789, y = 362436069, z = 521288629;

static ERL_NIF_TERM xor96(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  uint32_t t = (x^(x<<10));
  x = y;
  y = z;
  z = (z^(z>>26))^(t^(t>>5));
  return enif_make_int(env, z);
}

static ErlNifFunc nif_funcs[] = {
  {"xor96", 0, xor96}
};

ERL_NIF_INIT(Elixir.Genetic, nif_funcs, NULL, NULL, NULL, NULL);
