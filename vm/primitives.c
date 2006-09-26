#include "factor.h"

void* primitives[] = {
	undefined,
	docol,
	dosym,
	primitive_execute,
	primitive_call,
	primitive_ifte,
	primitive_dispatch,
	primitive_vector,
	primitive_rehash_string,
	primitive_sbuf,
	primitive_to_fixnum,
	primitive_to_bignum,
	primitive_to_float,
	primitive_from_fraction,
	primitive_str_to_float,
	primitive_float_to_str,
	primitive_float_bits,
	primitive_double_bits,
	primitive_bits_float,
	primitive_bits_double,
	primitive_from_rect,
	primitive_fixnum_add,
	primitive_fixnum_add_fast,
	primitive_fixnum_subtract,
	primitive_fixnum_subtract_fast,
	primitive_fixnum_multiply,
	primitive_fixnum_divint,
	primitive_fixnum_divfloat,
	primitive_fixnum_mod,
	primitive_fixnum_divmod,
	primitive_fixnum_and,
	primitive_fixnum_or,
	primitive_fixnum_xor,
	primitive_fixnum_not,
	primitive_fixnum_shift,
	primitive_fixnum_less,
	primitive_fixnum_lesseq,
	primitive_fixnum_greater,
	primitive_fixnum_greatereq,
	primitive_bignum_eq,
	primitive_bignum_add,
	primitive_bignum_subtract,
	primitive_bignum_multiply,
	primitive_bignum_divint,
	primitive_bignum_divfloat,
	primitive_bignum_mod,
	primitive_bignum_divmod,
	primitive_bignum_and,
	primitive_bignum_or,
	primitive_bignum_xor,
	primitive_bignum_not,
	primitive_bignum_shift,
	primitive_bignum_less,
	primitive_bignum_lesseq,
	primitive_bignum_greater,
	primitive_bignum_greatereq,
	primitive_float_add,
	primitive_float_subtract,
	primitive_float_multiply,
	primitive_float_divfloat,
	primitive_float_mod,
	primitive_float_less,
	primitive_float_lesseq,
	primitive_float_greater,
	primitive_float_greatereq,
	primitive_word,
	primitive_update_xt,
	primitive_word_compiledp,
	primitive_drop,
	primitive_2drop,
	primitive_3drop,
	primitive_dup,
	primitive_2dup,
	primitive_3dup,
	primitive_rot,
	primitive__rot,
	primitive_dupd,
	primitive_swapd,
	primitive_nip,
	primitive_2nip,
	primitive_tuck,
	primitive_over,
	primitive_pick,
	primitive_swap,
	primitive_to_r,
	primitive_from_r,
	primitive_eq,
	primitive_getenv,
	primitive_setenv,
	primitive_stat,
	primitive_read_dir,
	primitive_data_gc,
	primitive_code_gc,
	primitive_gc_time,
	primitive_save_image,
	primitive_datastack,
	primitive_retainstack,
	primitive_callstack,
	primitive_set_datastack,
	primitive_set_retainstack,
	primitive_set_callstack,
	primitive_exit,
	primitive_data_room,
	primitive_code_room,
	primitive_os_env,
	primitive_millis,
	primitive_type,
	primitive_tag,
	primitive_cwd,
	primitive_cd,
	primitive_add_compiled_block,
	primitive_dlopen,
	primitive_dlsym,
	primitive_dlclose,
	primitive_byte_array,
	primitive_displaced_alien,
	primitive_alien_signed_cell,
	primitive_set_alien_signed_cell,
	primitive_alien_unsigned_cell,
	primitive_set_alien_unsigned_cell,
	primitive_alien_signed_8,
	primitive_set_alien_signed_8,
	primitive_alien_unsigned_8,
	primitive_set_alien_unsigned_8,
	primitive_alien_signed_4,
	primitive_set_alien_signed_4,
	primitive_alien_unsigned_4,
	primitive_set_alien_unsigned_4,
	primitive_alien_signed_2,
	primitive_set_alien_signed_2,
	primitive_alien_unsigned_2,
	primitive_set_alien_unsigned_2,
	primitive_alien_signed_1,
	primitive_set_alien_signed_1,
	primitive_alien_unsigned_1,
	primitive_set_alien_unsigned_1,
	primitive_alien_float,
	primitive_set_alien_float,
	primitive_alien_double,
	primitive_set_alien_double,
	primitive_alien_to_char_string,
	primitive_string_to_char_alien,
	primitive_alien_to_u16_string,
	primitive_string_to_u16_alien,
	primitive_throw,
	primitive_char_string_to_memory,
	primitive_memory_to_char_string,
	primitive_alien_address,
	primitive_slot,
	primitive_set_slot,
	primitive_integer_slot,
	primitive_set_integer_slot,
	primitive_char_slot,
	primitive_set_char_slot,
	primitive_resize_array,
	primitive_resize_string,
	primitive_hashtable,
	primitive_array,
	primitive_tuple,
	primitive_begin_scan,
	primitive_next_object,
	primitive_end_scan,
	primitive_size,
	primitive_die,
	primitive_finalize_compile,
	primitive_fopen,
	primitive_fgetc,
	primitive_fwrite,
	primitive_fflush,
	primitive_fclose,
	primitive_expired,
	primitive_wrapper,
	primitive_clone,
	primitive_array_to_tuple,
	primitive_tuple_to_array,
	primitive_array_to_vector,
	primitive_string,
	primitive_quotation
};

CELL primitive_to_xt(CELL primitive)
{
	return (CELL)primitives[primitive];
}
