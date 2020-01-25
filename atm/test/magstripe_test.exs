defmodule Atm.MagstripeTest do
  use ExUnit.Case, async: true

  setup do
    :sys.replace_state(Atm.Magstripe, fn s -> %{s | path: "path"} end)
  end

  @events [
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_slash, 0}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_slash, 1}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_slash, 0}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_slash, 1}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_rightbrace, 0}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_rightbrace, 1}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_rightbrace, 0}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_rightbrace, 1}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_leftbrace, 0}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_leftbrace, 1}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_leftbrace, 0}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_leftbrace, 1}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_dot, 0}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_dot, 1}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_dot, 0}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_dot, 1}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_backslash, 0}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_backslash, 1}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_backslash, 0}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_backslash, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_a, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_a, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_a, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_a, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_b, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_b, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_b, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_b, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_c, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_c, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_c, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_c, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_d, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_d, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_d, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_d, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_e, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_e, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_e, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_e, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_f, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_f, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_f, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_f, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_g, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_g, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_g, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_g, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_h, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_h, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_h, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_h, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_i, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_i, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_i, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_i, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_j, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_j, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_j, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_j, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_k, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_k, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_k, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_k, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_l, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_l, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_l, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_l, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_m, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_m, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_m, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_m, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_n, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_n, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_n, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_n, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_o, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_o, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_o, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_o, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_p, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_p, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_p, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_p, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_q, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_q, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_q, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_q, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_r, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_r, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_r, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_r, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_s, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_s, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_s, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_s, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_t, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_t, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_t, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_t, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_u, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_u, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_u, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_u, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_v, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_v, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_v, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_v, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_w, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_w, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_w, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_w, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_x, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_x, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_x, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_x, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_y, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_y, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_y, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_y, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_z, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_z, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_z, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_z, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_0, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_0, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_0, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_0, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_1, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_1, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_1, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_1, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_2, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_2, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_2, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_2, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_3, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_3, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_3, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_3, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_4, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_4, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_4, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_4, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_5, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_5, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_5, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_5, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_6, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_6, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_6, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_6, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_7, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_7, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_7, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_7, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_8, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_8, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_8, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_8, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_9, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_9, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_9, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_9, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_apostrophe, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_apostrophe, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_apostrophe, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_apostrophe, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_comma, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_comma, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_comma, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_comma, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_equal, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_equal, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_equal, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_equal, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_minus, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_minus, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_minus, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_minus, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_semicolon, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_semicolon, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_leftshift, 1},
       {:ev_key, :key_semicolon, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_rightshift, 0},
       {:ev_key, :key_semicolon, 0}
     ]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_space, 1}]},
    {:input_event, "path", [{:ev_msc, :msc_scan, 458_792}, {:ev_key, :key_space, 0}]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_enter, 1}
     ]},
    {:input_event, "path",
     [
       {:ev_msc, :msc_scan, 458_792},
       {:ev_key, :key_enter, 0}
     ]}
  ]

  @result "?/}]{[>.|\\aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0)1!2@3#4$5%6^7&8*9('\",<=+-_;: "

  test "can read mag swipe data" do
    Enum.each(@events, &send(Atm.Magstripe, &1))
    assert :sys.get_state(Atm.Magstripe).last_read == @result
  end
end
