#include QMK_KEYBOARD_H
#include "quantum.h"

#define _LAYER0 0
#define _LAYER1 1
#define _LAYER2 2
#define _LAYER3 3
#define _LAYER4 4
#define _LAYER5 5

enum custom_keycodes {
    LAYER0 = SAFE_RANGE,
    LAYER1,
    LAYER2,
    LAYER3,
    LAYER4,
    LAYER5,
};

 const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

 [_LAYER0] = LAYOUT(
         LT(3,KC_Q), KC_W, KC_E, KC_R, KC_T, KC_Y, KC_U, KC_I, KC_O, KC_P,
         KC_A, KC_S, KC_D, KC_F, KC_G, KC_H, KC_J, KC_K, KC_L, KC_SCLN,
         LSFT_T(KC_Z), LCTL_T(KC_X), LALT_T(KC_C), LGUI_T(KC_V), KC_B, KC_N, KC_M, LALT_T(KC_COMM), LCTL_T(KC_DOT), LSFT_T(KC_SLSH),
         LT(2,KC_DEL), LT(1,KC_ENT), LT(1,KC_SPC), LT(2,KC_BSPC)
         ),

[_LAYER1] = LAYOUT(
        KC_PSCR, KC_TRNS, KC_DEL, KC_GRV, KC_TILD, KC_CIRC, KC_LPRN, KC_RPRN, KC_LBRC, KC_RBRC,
        KC_EXLM, KC_AT, KC_HASH, KC_DLR, KC_PERC, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_QUOT,
        KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_BSLS, KC_PIPE, KC_AMPR, KC_LCBR, KC_RCBR,
        KC_TAB, KC_ESC, KC_QUOT, KC_DQUO
        ),

[_LAYER2] = LAYOUT(
        LGUI(KC_1), LGUI(KC_2), LGUI(KC_3), LGUI(KC_4), LGUI(KC_5), KC_PLUS, KC_7, KC_8, KC_9, KC_0,
        LALT(KC_1), LALT(KC_2), LALT(KC_3), LALT(KC_4), LALT(KC_5), KC_EQL, KC_4, KC_5, KC_6, KC_PAST,
        KC_LSFT, KC_NO, KC_NO, KC_NO, KC_NO, KC_MINS, KC_1, KC_2, KC_3, KC_UNDS,
        KC_TRNS, KC_NO, KC_TRNS, KC_TRNS
        ),

[_LAYER3] = LAYOUT(
        KC_BRIU, KC_NO, KC_MFFD, KC_MNXT, KC_VOLU, KC_HOME, KC_PGDN, KC_PGUP, KC_END, KC_INS,
        LGUI_T(KC_TRNS), LALT_T(KC_TRNS), LCTL_T(KC_MSTP), LSFT_T(KC_MPLY), KC_MUTE, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_DEL,
        KC_BRID, KC_NO, KC_MRWD, KC_MPRV, KC_VOLD, KC_UNDO, KC_CUT, KC_COPY, KC_PSTE, KC_FIND,
        KC_TRNS, KC_NO, KC_SPC, KC_TAB
        ),

[_LAYER4] = LAYOUT(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, MS_WHLL, MS_WHLD, MS_WHLU, MS_WHLR, KC_APP,
        LGUI_T(KC_TRNS), LALT_T(KC_TRNS), LCTL_T(KC_TRNS), LSFT_T(KC_TRNS), KC_NO, MS_LEFT, MS_DOWN, MS_UP, MS_RGHT, MS_BTN3,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_NO, KC_TRNS, MS_BTN1, MS_BTN2
        ),

[_LAYER5] = LAYOUT(
        KC_PSCR, KC_F7, KC_F8, KC_F9, KC_F10, KC_NO, KC_NO, KC_NO, KC_NO, KC_TRNS,
        KC_SCRL, KC_F4, KC_F5, KC_F6, KC_F11, KC_NO, LSFT_T(KC_TRNS), LCTL_T(KC_TRNS), LALT_T(KC_TRNS), LGUI_T(KC_TRNS),
        KC_PAUS, KC_F1, KC_F2, KC_F3, KC_F12, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_ENT, KC_BSPC, KC_NO, KC_NO
        )

};

const uint16_t PROGMEM lbrc_combo[] = {KC_E, KC_R, COMBO_END};
const uint16_t PROGMEM rbrc_combo[] = {KC_U, KC_I, COMBO_END};
const uint16_t PROGMEM lcbr_combo[] = {LALT_T(KC_C), LGUI_T(KC_V), COMBO_END};
const uint16_t PROGMEM rcbr_combo[] = {KC_M, LALT_T(KC_COMM), COMBO_END};

const uint16_t PROGMEM esc_combo[] = {KC_J, KC_K, COMBO_END};
const uint16_t PROGMEM bspc_combo[] = {KC_K, KC_L, COMBO_END};
const uint16_t PROGMEM caps_combo[] = {KC_D, KC_F, COMBO_END};
const uint16_t PROGMEM layer5_combo[] = {LT(1,KC_SPC), LT(2,KC_BSPC), COMBO_END};

combo_t key_combos[] = {
    COMBO(lbrc_combo, KC_LBRC),
    COMBO(rbrc_combo, KC_RBRC),
    COMBO(lcbr_combo, KC_LCBR),
    COMBO(rcbr_combo, KC_RCBR),
    COMBO(esc_combo, KC_ESC),
    COMBO(bspc_combo, KC_BSPC),
    COMBO(caps_combo, KC_CAPS),
    COMBO(layer5_combo, LT(5,KC_0)),
};
