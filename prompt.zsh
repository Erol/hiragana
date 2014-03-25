hiragana() {
  ruby ~/Projects/hiragana/prompt.rb $COLUMNS $PWD 2>/dev/null
}

PROMPT='
$(hiragana)
 → '

RPROMPT=''
