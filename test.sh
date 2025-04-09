command="java -cp chocopy-ref.jar:target/assignment.jar chocopy.ChocoPy --pass=s --dir src/test/data/pa1/sample"

if [ -z "$1" ]; then
    $command
elif [ "$1" == "--help" ]; then
    echo this is the help i want to print put eventually
elif [ "$1" == "--passed" ]; then
    $command $2 | grep +
elif [ "$1" == "--failed" ]; then
    $command $2 | grep -
elif [ "$1" == "--ask" ]; then
    for file in src/test/data/pa1/sample/*.py; do
        read -p "Read file '$file'?[y]: " answer
        if [ "$answer" == "y" ]; then
            java -cp "chocopy-ref.jar:target/assignment.jar" \
                chocopy.ChocoPy \
                --pass=s \
                $file \
                > $file.generated
            break
        fi
    done
else
    $command $1
fi
