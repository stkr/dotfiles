if [ -d ~/.terminfo/.src/ ]; then
    for f in ~/.terminfo/.src/*.info; do 
        echo "Installing $f"
        tic -x $f
    done
fi
