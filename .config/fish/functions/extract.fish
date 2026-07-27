function extract --description "Extract common archive formats"
    if test (count $argv) -eq 0
        echo "Usage: extract <file>"
        return 1
    end

    set file $argv[1]

    if not test -f $file
        echo "'$file' is not a valid file"
        return 1
    end

    switch $file
        case '*.tar.bz2'
            tar xjf $file
        case '*.tar.gz'
            tar xzf $file
        case '*.tar.xz'
            tar xJf $file
        case '*.bz2'
            bunzip2 $file
        case '*.rar'
            unrar x $file
        case '*.gz'
            gunzip $file
        case '*.tar'
            tar xf $file
        case '*.zip'
            unzip $file
        case '*.7z'
            7z x $file
        case '*'
            echo "'$file': unrecognized archive format"
    end
end
