# -*- coding: utf8 -*-
import string

greek = [
    ('a', u'α' u'Α', u'', u''),
    ('b', u'β' u'Β', u'', u''),
    ('c', u'χ' u'Χ', u'', u''),
    ('d', u'δ' u'Δ', u'', u''),
    ('e', u'ε' u'Ε', u'', u''),
    ('f', u'φ' u'Φ', u'', u''),
    ('g', u'γ' u'Γ', u'', u''),
    ('h', u'η' u'Η', u'', u''),
    ('i', u'ι' u'Ι', u'', u''),
    ('j', u'ϑ' u'Θ', u'', u''),
    ('k', u'κ' u'Κ', u'', u''),
    ('l', u'λ' u'Λ', u'', u''),
    ('m', u'μ' u'Μ', u'', u''),
    ('n', u'ν' u'Ν', u'', u''),
    ('o', u'ο' u'Ο', u'', u''),
    ('p', u'π' u'Π', u'', u''),
    ('q', u'θ' u'Θ', u'', u''),
    ('r', u'ρ' u'Ρ', u'', u''),
    ('s', u'σ' u'Σ', u'', u''),
    ('t', u'τ' u'Τ', u'', u''),
    ('u', u'υ' u'Υ', u'', u''),
    ('v', u'ς' u'Σ', u'', u''),
    ('w', u'ω' u'Ω', u'', u''),
    ('x', u'ξ' u'Ξ', u'', u''),
    ('y', u'ψ' u'Ψ', u'', u''),
    ('z', u'ζ' u'Ζ', u'', u''),
]

math = [
    ('a',     u'∧', u'ℵ', u'', u''),
    ('c',     u'∘', u'ℂ', u'', u''),
    ('e',     u'∈', u'∉', u'', u''),
    ('f',     u'∫', u'',  u'', u''),
    ('i',     u'∩', u'∞', u'', u''),
    ('n',     u'' , u'ℕ', u'', u''),
    ('o',     u'∨', u'',  u'', u''),
    ('r',     u'√', u'ℝ', u'', u''),
    # ('t',     u'⊢', u'⊥', u'', u''),
    ('u',     u'∪', u'',  u'', u''),
    ('x',     u'⊻', u'',  u'', u''),
    ('z',     u'' , u'ℤ', u'', u''),
    ('-',     u'¬', u'',  u'', u''),
    ('=',     u'≠', u'±', u'', u''),
    ('/',     u'÷', u'',  u'', u''),
    (',',     u'' , u'≤', u'', u''),
    ('.',     u'·', u'≥', u'', u''),
    ('0',     u'∅', u'',  u'', u''),
    ('8',     u'' , u'×', u'', u''),
    ('`',     u'' , u'≈', u'', u''),
    ('[',     u'⊂', u'⊄', u'⊆', u'⊈'),
    (']',     u'⊃', u'⊅', u'⊇', u'⊉'),
    ('right', u'→', u'↛', u'⇒', u'⇏'),
    ('left',  u'←', u'↚', u'⇐', u'⇍'),
    ('up',    u'↔', u'↮', u'⇔', u'⇎'),
    ('down',  u'↔', u'↮', u'⇔', u'⇎'),
]

def get_keycode(c):
    if c in string.letters:
        return c
    elif c in string.digits:
        return 'KEY_' + c
    else:
        return {
            '-': 'MINUS',
            '=': 'EQUAL',
            '/': 'SLASH',
            '\\': 'BACKSLASH',
            '.': 'DOT',
            ',': 'COMMA',
            "'": 'QUOTE',
            ';': 'SEMICOLON',
            '[': 'BRACKET_LEFT',
            ']': 'BRACKET_RIGHT',
            '`': 'BACKQUOTE',
            'left': 'CURSOR_LEFT',
            'right': 'CURSOR_RIGHT',
            'down': 'CURSOR_DOWN',
            'up': 'CURSOR_UP',
        }[c]

def get_line(c):
    line_template = r'''KeyCode::%s, ModifierFlag::OPTION_L,'''
    key = get_keycode(c)
    return line_template % key

def get_codepoint(c):
    r = repr(c)
    if len(r) == 7:
        return '00' + r[-3:-1].upper()
    else:
        return r[-5:-1].upper()

def get_chunk(source_key, dest_char, mod, buckies):
    modifier_chunks = ['ModifierFlag::EXTRA%d'% mod]
    modifier_chunks.extend(buckies)
    modifier = ' | '.join(modifier_chunks)

    codepoint = get_codepoint(dest_char)
    lines = '\n'.join(get_line(c) for c in codepoint)

    return r'''
        <autogen>
            --KeyToKey--
            KeyCode::%s, %s,
            %s
        </autogen>
    ''' % (source_key, modifier, lines)

def for_map(m, modifier):
    for k, bare, shift, ctrl, shiftctrl in m:
        k = get_keycode(k).upper()

        if shiftctrl:
            print get_chunk(k, shiftctrl, modifier, ['VK_CONTROL', 'VK_SHIFT'])

        if shift:
            print get_chunk(k, shift, modifier, ['VK_SHIFT'])

        if ctrl:
            print get_chunk(k, ctrl, modifier, ['VK_CONTROL'])

        if bare:
            print get_chunk(k, bare, modifier, [])

# for_map(greek, 4)
for_map(math, 3)
