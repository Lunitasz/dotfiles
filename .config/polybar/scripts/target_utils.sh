settarget() {
    echo "$1 $2" > "$HOME/.config/polybar/scripts/target"
}

cleartarget() {
    : > "$HOME/.config/polybar/scripts/target"
}
